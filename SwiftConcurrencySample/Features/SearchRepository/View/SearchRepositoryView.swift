//
//  SearchRespositoryView.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/10.
//

import Foundation
import SwiftUI

struct SearchRepositoryView: View {
    @ObservedObject var viewModel: SearchRepositoryViewModel
    init(
        viewModel: SearchRepositoryViewModel
    ) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .center, spacing: 20) {
                ForEach(viewModel.state.repositories, id: \.id) { repository in
                    RepositoryView(repository: repository)
                        .padding(.leading, 20)
                }
            }
        }
    }
}
