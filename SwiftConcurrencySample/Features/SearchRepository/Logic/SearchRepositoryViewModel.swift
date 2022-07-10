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
        var resultsCount: Int = 0
        var repositories: [Repository]

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
        case didTap
        case search(String)
    }
    
    enum RouteType: Sendable {
        case repositoryDetail
    }
    
    func send(_ action: Action) {
        switch action {
        case .didTap: break
        case let .search(keyword):
            environment.userDefaultsClient.searchKeywordHistories.append(keyword)
            
            let request = SearchRepositoryRequest(keyword: keyword)
            Task {
                do {
                    let response = try await environment.apiClient.send(request)

                    state.resultsCount = response.totalCount
                    state.repositories = response.items.map {
                        RepositoryTranslator.translateToRepository(from: $0)
                    }
                    dump(state)
                } catch {
                    print(error)
                }
            }
        }

    }
}
