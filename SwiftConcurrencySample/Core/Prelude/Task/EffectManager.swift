//
//  EffectManager.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/08/26.
//

import Foundation

public typealias EffectId = AnyHashable

public protocol EffectIDProtocol: Hashable, Sendable {}

struct DefaultEffectID: EffectIDProtocol {}

public class EffectManager {
    public typealias CancelableTask = Task<Void, Never>
    private var effects: [EffectId: Array<CancelableTask>] = [:]

    public init(){}

    public func add<T: EffectIDProtocol>(
        _ id: T = DefaultEffectID(),
        task: CancelableTask
    ) {
        effects[id, default: []].append(task)
        
        Task<Void, Error>.detached {[weak self] in
            await task.value
            self?.removeTask(id, task: task)
        }
    }
    
    private func removeTask<T: EffectIDProtocol>(
        _ id: T,
        task: CancelableTask
    ) {
        effects[id]?.removeAll(where: { _task in task == _task })
    }
    
    public func cancellAndAdd<T: EffectIDProtocol>(
        _ id: T = DefaultEffectID(),
        task: CancelableTask
    ) {
        cancell(id)
        add(
            id,
            task: task
        )
    }

    public func cancell<T: EffectIDProtocol>(
        _ id: T
    ) {
        if let tasks = effects[id] {
            for task in tasks {
                task.cancel()
            }
        }
    }

    public func isCancelled<T: EffectIDProtocol>(
        _ id: T
    ) -> Bool {
        if let tasks = effects[id] {
            let secondFromLastIndex = tasks.endIndex - 2
            if let task = tasks[safe: secondFromLastIndex] {
                return task.isCancelled
            }
        }
        return false
    }
}
