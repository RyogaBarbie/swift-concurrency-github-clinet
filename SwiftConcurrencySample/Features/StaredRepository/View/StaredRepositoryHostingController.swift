//
//  StaredRepositoryHostingController.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/14.
//

import Foundation
import UIKit
import SwiftUI

class StaredRepositoryHostingController: UIHostingController<StaredRepositoryView>  {
    private let viewModel: StaredRepositoryViewModel
    
    init(
        _ view: StaredRepositoryView,
        viewModel: StaredRepositoryViewModel
    ) {
        self.viewModel = viewModel
        super.init(rootView: view)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        viewModel.send(.viewDidLoad)
    }
    
    func setup() {
        navigationItem.title = "Stared Repositories"
    }
}
