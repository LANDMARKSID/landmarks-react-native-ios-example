//
//  UIDevice+Battery.swift
//  landmarksidios12
//
//  Created by Bohdan Pashchenko on 11.03.2022.
//  Copyright © 2022 Reza Farahani. All rights reserved.
//

import UIKit.UIDevice

extension UIDevice {
    // @objc is for unit tests
    @objc var batteryStateStr: String {
        isBatteryMonitoringEnabled = true
        
        switch batteryState {
        case .charging: return "CHARGING"
        case .full: return "FULL"
        case .unplugged: return "DISCHARGING"
        case .unknown: return "UNKNOWN"
        @unknown default: expectationFail(); return "UNKNOWN"
        }
    }
}
