//
//  Request.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/09.
//

import Foundation

protocol Request: Sendable {
    associatedtype Response: Decodable
    var method: APIMethod { get }
    var path: String { get }
    var query: [String: String] { get }
    var body: String? { get }
}
