//
//  NSError+LandmarksError.swift
//  landmarksidios12
//
//  Created by Bohdan Pashchenko on 10.02.2022.
//  Copyright © 2022 Reza Farahani. All rights reserved.
//

import Foundation

extension NSError {
    // this would probably be obsolete after conversion to Wwift, unless we want to emit these errors outside the SDK
    convenience init(landmarksError: String) {
        self.init(domain: "com.landmarksid.getconfig", code: 1001, userInfo: ["Error reason": landmarksError])
    }
}
