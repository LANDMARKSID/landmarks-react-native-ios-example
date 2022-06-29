//
//  Expectation.swift
//  landmarksidios12
//
//  Created by Bohdan Pashchenko on 10.03.2022.
//  Copyright © 2022 Reza Farahani. All rights reserved.
//

var ignoreNextExpectationFailure: Bool = false

func expectationFail() {
    if ignoreNextExpectationFailure { ignoreNextExpectationFailure = false; return }
    assertionFailure()
}

func expect(_ expr: Bool) {
    if !expr { expectationFail() }
}

extension Optional {
    func expectNonNil() -> Self {
        if self == nil { expectationFail() }
        return self
    }
}
