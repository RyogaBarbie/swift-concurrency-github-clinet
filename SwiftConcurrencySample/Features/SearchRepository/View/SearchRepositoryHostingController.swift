//
//  SearchRepositoryHostingController.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/10.
//

import Foundation
import SwiftUI

class SearchRepositoryHostingController: UIHostingController<SearchRepositoryView>, UISearchBarDelegate{
    
    private let viewModel: SearchRepositoryViewModel
    
    private lazy var searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    init(
        _ view: SearchRepositoryView,
        viewModel: SearchRepositoryViewModel
    ) {
        self.viewModel = viewModel
        super.init(rootView: view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    private func setup() {
        searchController.showsSearchResultsController = true
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Repository "
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
}

// MARK:  UISearchBarDelegate
extension SearchRepositoryHostingController {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let keyword = searchBar.text {
            viewModel.send(.search(keyword))
        }
    }
}
