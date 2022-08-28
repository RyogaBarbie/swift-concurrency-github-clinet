//
//  StaredRepositoryViewModel.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/14.
//

import Foundation

public struct UpdateUserStaresEffectID: EffectIDProtocol {}

@MainActor
final class StaredRepositoryViewModel: ObservableObject {
    @Published var state: State
    private let environment: Environment
    private let effectManager = EffectManager()
    
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
        var updateUserStaresTask: Task<(), Error>? = nil
        var apiTask: Task<(), Error>? = nil

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
        case fetchInitialUserStares(isRefresh: Bool)
        case didTapStar(Int, Repository)
        case checkStar(Int, Repository)
        case pagination
        case updateUserStares
        case _update(repositories: [Repository], pageNumber: Int?)
    }
    
    enum RouteType: Sendable {
        case repositoryDetail
    }
    
    func send(_ action: Action) {
        switch action {
        case let .fetchInitialUserStares(isRefresh):
            /// pull to refresh時にonAppearが呼ばれずstarの状態取得が走らないので、
            /// pull to refreshの時はloading stateを変えない&
            /// 差分更新ではなく新規データソースとなるように repositoriesを空に
            if isRefresh {
                state.repositories = []
            } else {
                state.isLoading = true
            }
            
            let request = StaredRepositoriesRequest(
                page: 1
            )

            Task.detached {[weak self] in
                guard let self = self else { return }

                do {
                    let response = try await self.environment.apiClient.send(request)

                    Task { @MainActor [weak self]  in
                        guard let self = self else { return }

                        self.send(
                            ._update(
                                repositories: response.map {
                                    RepositoryTranslator.translateToRepository(from: $0)
                                },
                                pageNumber: 1
                            )
                        )
                    }
                } catch {
                    print(error)
                    Task { @MainActor in
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
                        Task { @MainActor [index, weak self] in
                            guard let self = self else { return }

                            var _repositories = self.state.repositories
                            _repositories[index].isStared = false
                            _repositories[index].stargazersCount -= 1
                            
                            self.send(
                                ._update(repositories: _repositories, pageNumber: nil)
                            )
                        }
                    } catch {
                        print(error)
                    }
                }

            } else {
                Task.detached { [weak self, repository] in
                    guard let self = self else { return }

                    let request = StarRepositoryRequest(
                        ownerName: repository.owner.login,
                        repositoryName: repository.name
                    )

                    do {
                        _ = try await self.environment.apiClient.send(request)
                        Task { @MainActor [index, weak self] in
                            guard let self = self else { return }

                            var _repositories = self.state.repositories
                            _repositories[index].isStared = true
                            _repositories[index].stargazersCount += 1
                            
                            self.send(
                                ._update(repositories: _repositories, pageNumber: nil)
                            )
                        }
                    } catch {
                        print(error)
                    }
                }

            }

        case let .checkStar(index, repository):
            guard repository.isStared == nil else { break }

            Task.detached { [weak self, repository] in
                guard let self = self else { return }

                let request = CheckStarRequest(
                    ownerName: repository.owner.login,
                    repositoryName: repository.name
                )
                do {
                    let response = try await self.environment.apiClient.send(request)
                    Task { @MainActor [index, weak self] in
                        guard let self = self else { return }
                        var _repositories = self.state.repositories
                        _repositories[index].isStared = response
                        
                        self.send(
                            ._update(repositories: _repositories, pageNumber: nil)
                        )
                    }
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

            Task.detached { [weak self] in
                guard let self = self else { return }
                do {
                    let response = try await self.environment.apiClient.send(request)

                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        
                        let _repositories = self.state.repositories + response.map {
                            RepositoryTranslator.translateToRepository(from: $0)
                        }
                        
                        self.send(
                            ._update(
                                repositories: _repositories,
                                pageNumber: nil
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

        case .updateUserStares:
            effectManager.cancellAndAdd(
                UpdateUserStaresEffectID(),
                task: Task {
                    state.isLoading = true

                    let request = StaredRepositoriesRequest(
                        page: 1
                    )

                    if effectManager.isCancelled(UpdateUserStaresEffectID()) {
                        state.isLoading = false
                        return
                    }

                    Task.detached { [environment] in
                        do {
                            let response = try await environment.apiClient.send(request)

                            Task { @MainActor [weak self] in
                                self?.send(
                                    ._update(
                                        repositories: response.map { RepositoryTranslator.translateToRepository(from: $0)
                                        },
                                        pageNumber: 1
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
                }
            )

        case let ._update(repositories, pageNumber):
            if let _pageNumber = pageNumber { state.page = _pageNumber }
            state.repositories = repositories
            state.isLoading = false
        }
    }
}
