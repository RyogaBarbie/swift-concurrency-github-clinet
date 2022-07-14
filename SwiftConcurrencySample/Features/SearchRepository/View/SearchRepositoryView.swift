//
//  SearchRespositoryView.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/10.
//

import Foundation
import SwiftUI

struct SearchRepositoryView: View {
    @ObservedObject private var viewModel: SearchRepositoryViewModel
    init(
        viewModel: SearchRepositoryViewModel
    ) {
        self.viewModel = viewModel
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
        }
    }
}
