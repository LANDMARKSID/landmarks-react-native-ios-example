//
//  Collection+IsEmptyOrNil.swift
//  landmarksidios12
//
//  Created by Bohdan Pashchenko on 15.03.2022.
//  Copyright © 2022 Reza Farahani. All rights reserved.
//

import Foundation

extension Optional where Wrapped: Collection {
    var isEmptyOrNil: Bool { self == nil || self?.isEmpty == true }
}
