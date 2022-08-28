//
//  Collection.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/08/28.
//

import Foundation

extension Collection {
    public subscript(safe index: Index) -> Element? {
        startIndex <= index && index < endIndex ? self[index] : nil
    }
}
