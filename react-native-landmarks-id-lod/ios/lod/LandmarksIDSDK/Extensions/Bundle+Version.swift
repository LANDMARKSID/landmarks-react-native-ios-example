//
//  Bundle+Version.swift
//  landmarksidios12
//
//  Created by Bohdan Pashchenko on 16.03.2022.
//  Copyright © 2022 Reza Farahani. All rights reserved.
//

import Foundation

extension Bundle {
    var version: String { (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String).expectNonNil() ?? "N/A" }
    var build: String { (Bundle.main.infoDictionary?["CFBundleVersion"] as? String).expectNonNil() ?? "N/A"}
}
