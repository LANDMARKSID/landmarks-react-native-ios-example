//
//  IntFloat+Str.swift
//  landmarksidios12
//
//  Created by Bohdan Pashchenko on 15.03.2022.
//  Copyright © 2022 Reza Farahani. All rights reserved.
//

import Foundation

extension BinaryInteger {
    var str: String { String(self) }
}

extension BinaryFloatingPoint {
    var str: String { String("\(self)") }
}
