//
//  EffectManagerTests.swift
//  SwiftConcurrencySampleTests
//
//  Created by yamamura ryoga on 2022/08/28.
//

import XCTest
@testable import SwiftConcurrencySample


final class EffectManagerTests: XCTestCase {
    var effectManager: EffectManager!
    var exceptValue = 0
    

    override func setUpWithError() throws {
        effectManager = EffectManager()
        exceptValue = 0
    }

    func testAdd() async throws {
        let expectation = XCTestExpectation(description: "add")
        expectation.expectedFulfillmentCount = 1

        let task = Task<Void, Never>.detached {
            try! await Task.sleep(nanoseconds: 1_000_000_000)
            expectation.fulfill()
        }
        // 追加されるか
        effectManager.add(DefaultEffectID(), task: task)
        XCTAssertEqual(effectManager.effects[DefaultEffectID()]!.count, 1)

        // taskが成功したら削除されてるか
        await task.value
        wait(for: [expectation], timeout: 3.0)
        XCTAssertEqual(effectManager.effects[DefaultEffectID()]!.count, 0)
    }
    
    func testCancell() async throws {
        let task = Task<Void, Never>.detached {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
        
        effectManager.add(DefaultEffectID(), task: task)
        effectManager.cancell(DefaultEffectID())
        
        XCTAssertTrue(task.isCancelled)
    }
    
    func testIsCancelled() async throws {
        let task = Task<Void, Never>.detached {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
        
        effectManager.add(DefaultEffectID(), task: task)
        effectManager.cancell(DefaultEffectID())

        XCTAssertTrue(effectManager.isCancelled(DefaultEffectID()))
    }
    
    func testCanncellAndAddForCancellCase() async throws {
        let expectation = XCTestExpectation(description: "cancellAndAdd")
        expectation.expectedFulfillmentCount = 2

        let task1 = Task<Void, Never>.detached {[weak self] in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if self!.effectManager.isCancelled(DefaultEffectID()) == false {
                self!.exceptValue += 1
            }
            expectation.fulfill()
        }
        effectManager.cancellAndAdd(DefaultEffectID(), task: task1)
        
        let task2 = Task<Void, Never>.detached {[weak self] in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if self!.effectManager.isCancelled(DefaultEffectID()) == false {
                self!.exceptValue += 1
            }
            expectation.fulfill()
        }
        effectManager.cancellAndAdd(DefaultEffectID(), task: task2)
        
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(exceptValue, 1)
    }
    
    func testCanncellAndAddForNotCancellCase() async throws {
        let expectation = XCTestExpectation(description: "cancellAndAdd")
        expectation.expectedFulfillmentCount = 2

        let task1 = Task<Void, Never>.detached {[weak self] in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if self!.effectManager.isCancelled(DefaultEffectID()) == false {
                self!.exceptValue += 1
            }
            expectation.fulfill()
        }
        effectManager.cancellAndAdd(DefaultEffectID(), task: task1)
        
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        let task2 = Task<Void, Never>.detached {[weak self] in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if self!.effectManager.isCancelled(DefaultEffectID()) == false {
                self!.exceptValue += 1
            }
            expectation.fulfill()
        }
        effectManager.cancellAndAdd(DefaultEffectID(), task: task2)
        
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(exceptValue, 2)
    }

    
    func testCanncellAndAddThreeTime() async throws {
        let expectation = XCTestExpectation(description: "cancellAndAdd")
        expectation.expectedFulfillmentCount = 3

        let task1 = Task<Void, Never>.detached {[weak self] in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if self!.effectManager.isCancelled(DefaultEffectID()) == false {
                self!.exceptValue += 1
            }
            expectation.fulfill()
        }
        effectManager.cancellAndAdd(DefaultEffectID(), task: task1)
        
//        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        let task2 = Task<Void, Never>.detached {[weak self] in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if self!.effectManager.isCancelled(DefaultEffectID()) == false {
                self!.exceptValue += 1
            }
            expectation.fulfill()
        }
        effectManager.cancellAndAdd(DefaultEffectID(), task: task2)
        
//        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        let task3 = Task<Void, Never>.detached {[weak self] in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if self!.effectManager.isCancelled(DefaultEffectID()) == false {
                self!.exceptValue += 1
            }
            expectation.fulfill()
        }
        effectManager.cancellAndAdd(DefaultEffectID(), task: task3)

        
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(exceptValue, 1)
    }
}
