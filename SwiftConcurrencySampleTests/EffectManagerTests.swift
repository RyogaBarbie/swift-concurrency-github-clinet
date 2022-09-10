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

        // 追加されるか
        effectManager.add(DefaultEffectID()) {
            try? await Task.sleep(nanoseconds: 500_000_000)
            expectation.fulfill()
        }
        XCTAssertEqual(effectManager.effects[DefaultEffectID()]!.count, 1)

        // taskの完了を待って削除されてるか
        let task = effectManager.effects[DefaultEffectID()]!.first!
        await task.value
        wait(for: [expectation], timeout: 3.0)
        XCTAssertEqual(effectManager.effects[DefaultEffectID()]!.count, 0)
    }
    
    func testCancell() async throws {
        effectManager.add(DefaultEffectID()) {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }

        let task = effectManager.effects[DefaultEffectID()]!.first!
        effectManager.cancell(DefaultEffectID())

        XCTAssertTrue(task.isCancelled)
    }

    func testAllCancell() async throws {
        effectManager.add(DefaultEffectID()) {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
        let task1 = effectManager.effects[DefaultEffectID()]!.first!


        effectManager.add(DefaultEffectID()) {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
        let task2 = effectManager.effects[DefaultEffectID()]![1]

        effectManager.add(DefaultEffectID()) {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
        let task3 = effectManager.effects[DefaultEffectID()]![2]

        effectManager.cancell(DefaultEffectID())
        XCTAssertTrue(task1.isCancelled)
        XCTAssertTrue(task2.isCancelled)
        XCTAssertTrue(task3.isCancelled)
    }

    // cancel回数が正しいか
    func testCanncellAndAddForCancellCase() async throws {
        let expectation = XCTestExpectation(description: "cancellAndAdd")
        expectation.expectedFulfillmentCount = 2

        effectManager.cancellAndAdd(DefaultEffectID()) {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if Task.isCancelled {
                self.exceptValue += 1
            }
            expectation.fulfill()
        }
        let task1 = effectManager.effects[DefaultEffectID()]!.first!

        effectManager.cancellAndAdd(DefaultEffectID()) {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if Task.isCancelled {
                self.exceptValue += 1
            }
            expectation.fulfill()
        }
        // この時点で2回目のcanncellAndAddが呼ばれてるので、taskの配列からtask1は削除されてるためindexは0
        let task2 = effectManager.effects[DefaultEffectID()]!.first!
        _ = (await task1.value, await task2.value)

        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(exceptValue, 1)
    }

    // cancel回数(exceptValue)が正しいか
    func testCanncellAndAddForNotCancellCase() async throws {
        let expectation = XCTestExpectation(description: "cancellAndAdd")
        expectation.expectedFulfillmentCount = 2

        effectManager.cancellAndAdd(DefaultEffectID()) {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if Task.isCancelled {
                self.exceptValue += 1
            }
            expectation.fulfill()
        }
        let task1 = effectManager.effects[DefaultEffectID()]!.first!
        
        // task1の完了を待つ
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        effectManager.cancellAndAdd(DefaultEffectID()) {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if Task.isCancelled {
                self.exceptValue += 1
            }
            expectation.fulfill()
        }
        // この時点でtask1は完了してるので、taskの配列からtask1は削除されてるためindexは0
        let task2 = effectManager.effects[DefaultEffectID()]![0]

        // task1の完了を待ってからcancellAndAdd呼び出すので、exceptValueは0に
        _ = (await task1.value, await task2.value)
        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(exceptValue, 0)
    }


    func testCanncellAndAddThreeTime() async throws {
        let expectation = XCTestExpectation(description: "cancellAndAdd")
        expectation.expectedFulfillmentCount = 3

        effectManager.cancellAndAdd(DefaultEffectID()) {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if Task.isCancelled {
                self.exceptValue += 1
            }
            expectation.fulfill()
        }
        let task1 = effectManager.effects[DefaultEffectID()]!.first!

        // task1の完了を待つ
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        effectManager.cancellAndAdd(DefaultEffectID()) {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if Task.isCancelled {
                self.exceptValue += 1
            }
            expectation.fulfill()
        }
        let task2 = effectManager.effects[DefaultEffectID()]!.first!

        // task2の完了を待つ場合
//        try? await Task.sleep(nanoseconds: 1_500_000_000)

        effectManager.cancellAndAdd(DefaultEffectID()) {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if Task.isCancelled {
                self.exceptValue += 1
            }
            expectation.fulfill()
        }
        let task3 = effectManager.effects[DefaultEffectID()]!.first!

        _ = (await task1.value, await task2.value, await task3.value)
        wait(for: [expectation], timeout: 10.0)
        // task2のみキャンセルするので
        XCTAssertEqual(exceptValue, 1)
    }
}
