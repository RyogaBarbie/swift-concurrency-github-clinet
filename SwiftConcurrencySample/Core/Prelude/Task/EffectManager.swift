//
//  EffectManager.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/08/26.
//

import Foundation

public typealias EffectId = AnyHashable

public protocol EffectIDProtocol: Hashable, Sendable {}

public struct DefaultEffectID: EffectIDProtocol {}

public class EffectManager {
    private(set) var effects: [EffectId: Array<Task<Void, Never>>] = [:]

    public init(){}

    public func add<T: EffectIDProtocol>(
        _ id: T,
        _ priority: TaskPriority? = nil,
        _ operation: @Sendable @escaping () async -> Void
    ) {
        let task = Task<Void, Never>(priority: priority, operation: operation)
        effects[id, default: []].append(task)
        
        Task<Void, Error>.detached {[weak self] in
            await task.value
            self?.removeTask(id, task: task)
        }
    }
    
    private func removeTask<T: EffectIDProtocol>(
        _ id: T,
        task: Task<Void, Never>
    ) {
        effects[id]?.removeAll(where: { _task in task == _task })
    }
    
    public func cancellAndAdd<T: EffectIDProtocol>(
        _ id: T,
        _ priority: TaskPriority? = nil,
        _ operation: @Sendable @escaping () async -> Void
    ) {
        cancell(id)
        add(
            id,
            priority,
            operation
        )
    }

    public func cancell<T: EffectIDProtocol>(
        _ id: T
    ) {
        if let tasks = effects.removeValue(forKey: id) {
            for task in tasks {
                task.cancel()
            }
        }
    }
}
