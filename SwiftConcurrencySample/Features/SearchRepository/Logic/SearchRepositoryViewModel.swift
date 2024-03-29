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
        let notificationCenter: NotificationCenter

        init(
            apiClient: APIClientProtocol,
            userDefaultsClient: UserDefaultsClientProtocol,
            notificationCenter: NotificationCenter
        ) {
            self.apiClient = apiClient
            self.userDefaultsClient = userDefaultsClient
            self.notificationCenter = notificationCenter
        }
    }
    
    enum Action: Sendable {
        case viewDidLoad
        case didTapStar(Int, Repository)
        case search(String)
        case checkStar(Int, Repository)
        case pagination
        case _update(repositories: [Repository], pageNumber: Int?, resultsCount: Int?)
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
                page: self.state.page,
                sort: "updated"
            )

            Task.detached { [weak self] in
                guard let self = self else { return }

                do {
                    let response = try await self.environment.apiClient.send(request)

                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        
                        self.send(
                            ._update(
                                repositories: response.items.map {
                                    RepositoryTranslator.translateToRepository(from: $0)
                                },
                                pageNumber: nil,
                                resultsCount: response.totalCount
                            )
                        )
                    }
                } catch {
                    print(error)
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        self.state.isLoading = false
                    }
                }
            }

        case let .didTapStar(index, repository):
            if let isStared = repository.isStared, isStared {
                Task.detached { [weak self, repository] in
                    guard let self = self else { return }
                    let request = UnStarRequest(
                        ownerName: repository.owner.login,
                        repositoryName: repository.name
                    )
                    do {
                        _ = try await self.environment.apiClient.send(request)

                        Task { @MainActor [weak self, index] in
                            guard let self = self else { return }

                            self.environment.notificationCenter.post(
                                name: Notification.Name.updateUserStares,
                                object: self.state.repositories[index]
                            )

                            var _repositories = self.state.repositories
                            _repositories[index].isStared = false
                            _repositories[index].stargazersCount -= 1

                            self.send(
                                ._update(
                                    repositories: _repositories,
                                    pageNumber: nil,
                                    resultsCount: nil
                                )
                            )
                        }
                    } catch {
                        print(error)
                    }
                }
            } else {
                Task.detached {[weak self, repository] in
                    guard let self = self else { return }

                    let request = StarRepositoryRequest(
                        ownerName: repository.owner.login,
                        repositoryName: repository.name
                    )
                    do {
                        _ = try await self.environment.apiClient.send(request)
                        Task { @MainActor [weak self, index] in
                            guard let self = self else { return }

                            self.environment.notificationCenter.post(
                                name: Notification.Name.updateUserStares,
                                object: self.state.repositories[index]
                            )

                            var _repositories = self.state.repositories
                            _repositories[index].isStared = true
                            _repositories[index].stargazersCount += 1

                            self.send(
                                ._update(
                                    repositories: _repositories,
                                    pageNumber: nil,
                                    resultsCount: nil
                                )
                            )
                        }
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

            Task.detached {[weak self] in
                guard let self = self else { return }

                do {
                    let response = try await self.environment.apiClient.send(request)

                    Task { @MainActor [weak self, response] in
                        guard let self = self else { return }
                        self.send(
                            ._update(
                                repositories: response.items.map {
                                    RepositoryTranslator.translateToRepository(from: $0)
                                },
                                pageNumber: nil,
                                resultsCount: response.totalCount
                            )
                        )
                    }
                } catch {
                    print(error)
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        self.state.isLoading = false
                    }
                }
            }

        case let .checkStar(index, repository):
            guard repository.isStared == nil else { break }

            Task.detached {[weak self, repository] in
                guard let self = self else { return }
                let request = CheckStarRequest(
                    ownerName: repository.owner.login,
                    repositoryName: repository.name
                )
                do {
                    let response = try await self.environment.apiClient.send(request)
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        
                        var _repositories = self.state.repositories
                        
                        _repositories[index].isStared = response
                        self.send(
                            ._update(
                                repositories: _repositories,
                                pageNumber: nil,
                                resultsCount: nil
                            )
                        )
                    }
                } catch {
                    print(error)
                }
            }

        case .pagination:
            if state.isLoading { return } else { state.isLoading = true }
            state.page += 1

            let request = SearchRepositoryRequest(
                keyword: self.state.keyword,
                page: self.state.page
            )
            Task.detached { [weak self] in
                guard let self = self else { return }

                do {
                    let response = try await self.environment.apiClient.send(request)

                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        
                        let _repositories = self.state.repositories + response.items.map {
                            RepositoryTranslator.translateToRepository(from: $0)
                        }
                        
                        self.send(
                            ._update(
                                repositories: _repositories,
                                pageNumber: nil,
                                resultsCount: response.totalCount
                            )
                        )
                    }
                } catch {
                    print(error)
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        self.state.isLoading = true
                    }
                }
            }

        case let ._update(repositories, pageNumber, resultsCount):
            if let _pageNumber = pageNumber { state.page = _pageNumber }
            if let _resultsCount = resultsCount { state.resultsCount = _resultsCount}
            state.repositories = repositories
            state.isLoading = false

        }
    }

}
