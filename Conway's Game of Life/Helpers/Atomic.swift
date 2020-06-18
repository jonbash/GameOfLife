//
//  Atomic.swift
//  Networker
//
//  Created by Jon Bash on 2020-01-26.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

@propertyWrapper
class Atomic<Value> {
    private lazy var queue: DispatchQueue = {
        let appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
        return DispatchQueue(label: "\(appName).AtomicQueue.\(Value.self)")
    }()
    private var value: Value

    var wrappedValue: Value {
        get { queue.sync { value } }
        set { queue.sync { value = newValue } }
    }

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
}
