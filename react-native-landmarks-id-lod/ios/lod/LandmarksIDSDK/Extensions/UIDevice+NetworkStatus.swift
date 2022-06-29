//
//  UIDevice+NetworkStatus.swift
//  landmarksidios12
//
//  Created by Bohdan Pashchenko on 10.03.2022.
//  Copyright © 2022 Reza Farahani. All rights reserved.
//

import UIKit.UIDevice

let reachability: Reachability? = {
    let r = (try? Reachability()).expectNonNil()
    try? r?.startNotifier()
    return r
}()

// @objc is for unit tests

extension UIDevice {
    @objc var networkStatus: String {
        guard let c = reachability.expectNonNil()?.connection else { expectationFail(); return "N/A" }
        return c.description.uppercased() // TODO: does it have to be capitalized or could it be just e.g. WiFi
    }
    
    @objc var isConnectedToInternet: Bool {
        guard let c = reachability.expectNonNil()?.connection else { expectationFail(); return false }
        return c == .wifi || c == .cellular
    }
}
