//
//  RepositoryView.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/10.
//

import Foundation
import SwiftUI

struct RepositoryView: View {
    private let repository: Repository
    private let didTapStaredClosure: (Repository) -> Void

    init(
        repository: Repository,
        didTapStaredClosure: @escaping (Repository) -> Void
    ) {
        self.repository = repository
        self.didTapStaredClosure = didTapStaredClosure
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                if let avatarURL = URL(string: repository.owner.avatarUrl) {
                    AsyncImage(url: avatarURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(width: 25, height: 25)
                        case .success(let image):
                            image.resizable()
                                 .aspectRatio(contentMode: .fit)
                                 .frame(width: 25, height: 25)
                                 .cornerRadius(5)
                                 .overlay(
                                     RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.gray, lineWidth: 0.25)
                                 )
                        case .failure:
                            Image(systemName: "person.crop.circle.fill")
                                .frame(width: 25, height: 25)
                        @unknown default:
                            // Since the AsyncImagePhase enum isn't frozen,
                            // we need to add this currently unused fallback
                            // to handle any new cases that might be added
                            // in the future:
                            EmptyView()
                        }
                    }
                    Spacer().frame(width: 5)
                }
                Text(repository.owner.login)
                    .font(.system(size: 15, weight: .regular))
            }
            Spacer().frame(height: 10)
            Text(repository.name)
                .fontWeight(.bold)
            Spacer().frame(height: 10)
            if let description = repository.description {
                Text(description)
                Spacer().frame(height: 15)
            }
            HStack(alignment: .center, spacing: 3) {
                HStack(alignment: .center, spacing: 3) {
                    if let isStared = repository.isStared, isStared {
                        Image(systemName: "star.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 14, weight: .semibold))
                    } else {
                        Image(systemName: "star")
                            .foregroundColor(.gray)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Text(String(repository.stargazersCount))
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
                .onTapGesture {
                    didTapStaredClosure(repository)
                }
                Spacer().frame(width: 20)
                if let language = repository.language {
                    HStack(alignment: .center, spacing: 3) {
                        FillColorView(size: 13, color: .orange, type: .circle)
                        Text(language)
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
                Spacer()
            }
        }
        Divider()
    }
}
