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
    public typealias CancelableTask = Task<Void, Never>
    #if TEST
    private var effects: [EffectId: Set<Task<Void, Never>>] = [:]
    #else
    private(set) var effects: [EffectId: Array<CancelableTask>] = [:]
    #endif
    

    public init(){}

    public func add<T: EffectIDProtocol>(
        _ id: T,
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
        task: Task<Void, Never>
    ) {
        effects[id]?.removeAll(where: { _task in task == _task })
    }
    
    public func cancellAndAdd<T: EffectIDProtocol>(
        _ id: T,
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
        if let tasks = effects.removeValue(forKey: id) {
            for task in tasks {
                task.cancel()
            }
        }
    }
}
