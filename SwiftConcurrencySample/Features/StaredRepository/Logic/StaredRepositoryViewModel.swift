//
//  StaredRepositoryViewModel.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/14.
//

import Foundation

@MainActor
final class StaredRepositoryViewModel: ObservableObject {
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
        var page: Int = 1
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
        case checkStar(Int, Repository)
        case pagination
        case updateUserStares
    }
    
    enum RouteType: Sendable {
        case repositoryDetail
    }
    
    func send(_ action: Action) {
        switch action {
        case .viewDidLoad:
            state.isLoading = true
            
            let request = StaredRepositoriesRequest(
                page: state.page
            )
            Task {
                do {
                    let response = try await environment.apiClient.send(request)
                    state.repositories.append(contentsOf: response.map {
                        RepositoryTranslator.translateToRepository(from: $0)
                    })
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

            let request = StaredRepositoriesRequest(
                page: state.page
            )

            Task {
                do {
                    let response = try await environment.apiClient.send(request)
                    state.repositories.append(contentsOf: response.map {
                        RepositoryTranslator.translateToRepository(from: $0)
                    })
                } catch {
                    print(error)
                }

                state.isLoading = false
            }
        case .updateUserStares:
            state.page = 1
            state.repositories = []
            state.isLoading = true
            
            let request = StaredRepositoriesRequest(
                page: state.page
            )
            Task {
                do {
                    let response = try await environment.apiClient.send(request)
                    state.repositories.append(contentsOf: response.map {
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
