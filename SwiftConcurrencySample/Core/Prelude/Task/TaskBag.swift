//
//  TaskBag.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/08/01.
//

import Foundation

public protocol CancelableTaskProtocol {
    func cancel()
}

extension Task: CancelableTaskProtocol {}

public final actor TaskBag: Sendable {
    private(set) var tasks: [CancelableTaskProtocol] = []

    public func append(_ task: CancelableTaskProtocol) {
        tasks.append(task)
    }

    deinit {
        tasks.forEach { $0.cancel() }
    }
}
