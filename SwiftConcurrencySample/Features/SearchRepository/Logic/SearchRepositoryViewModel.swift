//
//  SearchRepositoryViewModel.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/10.
//

import Foundation

@MainActor
final class SearchRepositoryViewModel: ObservableObject {
    @Published var state: State
    private let environment: Environment
    
    init(
        state: State,
        environment: Environment
    ) {
        self.state = state
        self.environment = environment
    }
    
    struct State: Sendable {
        var keyword: String = ""
        var page: Int = 1
        var resultsCount: Int = 0
        var repositories: [Repository]
        var isLoading: Bool = false

        init(
            repositories: [Repository] = []
        ) {
            self.repositories = repositories
        }
    }
    
    struct Environment {
        let apiClient: APIClientProtocol
        let userDefaultsClient: UserDefaultsClientProtocol

        init(
            apiClient: APIClientProtocol,
            userDefaultsClient: UserDefaultsClientProtocol
        ) {
            self.apiClient = apiClient
            self.userDefaultsClient = userDefaultsClient
        }
    }
    
    enum Action: Sendable {
        case viewDidLoad
        case didTapStar(Int, Repository)
        case search(String)
        case checkStar(Int, Repository)
        case pagination
    }
    
    enum RouteType: Sendable {
        case repositoryDetail
    }
    
    func send(_ action: Action) {
        switch action {
        case .viewDidLoad:
            state.isLoading = true

            let request = SearchRepositoryRequest(
                keyword: "swift",
                page: state.page,
                sort: "updated"
            )
            Task {
                do {
                    let response = try await environment.apiClient.send(request)

                    state.resultsCount = response.totalCount
                    state.repositories = response.items.map {
                        RepositoryTranslator.translateToRepository(from: $0)
                    }
                } catch {
                    print(error)
                }
                state.isLoading = false
            }

        case let .didTapStar(index, repository):
            if let isStared = repository.isStared, isStared {
                let request = UnStarRequest(
                    ownerName: repository.owner.login,
                    repositoryName: repository.name
                )
                Task {
                    do {
                        _ = try await environment.apiClient.send(request)
                        state.repositories[index].isStared = false
                        state.repositories[index].stargazersCount -= 1
                    } catch {
                        print(error)
                    }
                }
            } else {
                let request = StarRepositoryRequest(
                    ownerName: repository.owner.login,
                    repositoryName: repository.name
                )
                Task {
                    do {
                        _ = try await environment.apiClient.send(request)
                        state.repositories[index].isStared = true
                        state.repositories[index].stargazersCount += 1
                    } catch {
                        print(error)
                    }
                }
            }
            
        case let .search(keyword):
            state.isLoading = true
            state.keyword = keyword
            state.repositories = []
            environment.userDefaultsClient.searchKeywordHistories.append(keyword)
            
            let request = SearchRepositoryRequest(
                keyword: state.keyword,
                page: state.page
            )
            Task {
                do {
                    let response = try await environment.apiClient.send(request)

                    state.resultsCount = response.totalCount
                    state.repositories = response.items.map {
                        RepositoryTranslator.translateToRepository(from: $0)
                    }
                } catch {
                    print(error)
                }
                state.isLoading = false
            }

        case let .checkStar(index, repository):
            guard repository.isStared == nil else { break }

            let request = CheckStarRequest(
                ownerName: repository.owner.login,
                repositoryName: repository.name
            )
            Task {
                do {
                    let response = try await environment.apiClient.send(request)
                    state.repositories[index].isStared = response
                } catch {
                    print(error)
                }
            }

        case .pagination:
            if state.isLoading { return } else { state.isLoading = true }
            state.page += 1

            Task {
                do {
                    let request = SearchRepositoryRequest(
                        keyword: state.keyword,
                        page: state.page
                    )
                    let response = try await environment.apiClient.send(request)

                    state.resultsCount = response.totalCount
                    state.repositories.append(contentsOf: response.items.map {
                        RepositoryTranslator.translateToRepository(from: $0)
                    })
                } catch {
                    print(error)
                }
                state.isLoading = false
            }
        }
    }


}
