//
//  StaredRepository.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/14.
//

import Foundation
import SwiftUI

struct StaredRepositoryView: View {
    @ObservedObject private var viewModel: StaredRepositoryViewModel
    private let notificationCenter: NotificationCenter
    private let taskBag = TaskBag()
    
    init(
        viewModel: StaredRepositoryViewModel,
        notificationCenter: NotificationCenter
    ) {
        self.viewModel = viewModel
        self.notificationCenter = notificationCenter

        let task = Task { @MainActor in
            for await notification in notificationCenter.notifications(named: Notification.Name.updateUserStares, object: nil) {
                guard let repository = notification.object as? Repository else { return }
//                dump(repository)
                viewModel.send(.updateUserStares)
            }
        }
        Task.detached {[taskBag = self.taskBag] in
            await taskBag.append(task)
        }
    }
    
    var body: some View {
        if viewModel.state.isLoading && viewModel.state.repositories.isEmpty {
            ProgressView()
        } else {
            ScrollView(.vertical) {
                LazyVStack(alignment: .center, spacing: 20) {
                    ForEach(
                        Array(viewModel.state.repositories.enumerated()),
                        id: \.element.id
                    ) { index, repository in
                        RepositoryView(
                            repository: repository,
                            didTapStaredClosure: {
                                viewModel.send(.didTapStar(index, repository))
                            }
                        )
                            .padding(.leading, 20)
                            .onAppear {
                                viewModel.send(.checkStar(index, repository))
                                if index > (viewModel.state.repositories.count - 6) {
                                    viewModel.send(.pagination)
                                }
                            }
                    }
                    if viewModel.state.isLoading {
                        ProgressView()
                    }
                }
                .padding(.top, 15)
            }
            .refreshable {
                viewModel.send(.fetchInitialUserStares(isRefresh: true))
            }
        }
    }
}
