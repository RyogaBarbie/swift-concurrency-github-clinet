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
        case didTap
        case pagination
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
                    dump(state.repositories)
                } catch {
                    print(error)
                }

                state.isLoading = false
            }
        case .didTap: break
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
        }

    }

}
