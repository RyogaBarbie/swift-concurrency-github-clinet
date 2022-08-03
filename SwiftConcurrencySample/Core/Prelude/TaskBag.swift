//
//  TaskBag.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/08/01.
//

import Foundation

protocol CancelableTaskProtocol {
    func cancel()
}

extension Task: CancelableTaskProtocol {}

final class TaskBag {
    private(set) var tasks: [CancelableTaskProtocol] = []

    func append(_ task: CancelableTaskProtocol) {
        tasks.append(task)
    }

    deinit {
        tasks.forEach { $0.cancel() }
    }
}
