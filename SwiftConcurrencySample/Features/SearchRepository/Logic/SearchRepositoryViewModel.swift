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
        var searchKeyword: String = ""
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
            // TODO: API叩く
        }
    }
}
