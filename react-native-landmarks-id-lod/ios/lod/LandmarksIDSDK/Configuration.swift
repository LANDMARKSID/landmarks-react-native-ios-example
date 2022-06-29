//
//  ConfigurationSwift.swift
//  landmarksidios12
//
//  Created by Bohdan Pashchenko on 09.03.2022.
//  Copyright © 2022 Reza Farahani. All rights reserved.
//

import Foundation

// all @objc here is for tests

class Configuration: NSObject {
    @objc var distanceFilterMeters: Double = 500
    @objc var clientId: NSString = ""
    @objc var batchSize: Int = 10
    @objc var terminatedBatchSize: Int = 10
    @objc var terminatedEventsSize: Int = 10
    @objc var monitoredApps: NSMutableArray = []
    
    // Enables Bluedot
    @objc var discoveryEnabled: Bool = false
    @objc var locationOptimisedEnabled: Bool = false
    @objc var foregroundTrackingEnabled: Bool = false
    @objc var significantLocationTrackingEnabled: Bool = false
    @objc var shouldCollectData: Bool = false
    @objc var allowsTerminatedTracking: Bool = false
    @objc var enableNetworkName: Bool = false
    @objc var enableAdvertisingId: Bool = false
    @objc var enableSimOperator: Bool = false

    @objc func initConfig(_ dictionary: NSDictionary) {
        if let v = dictionary["distanceFilterMeters"] as? Double { distanceFilterMeters = v }
        if let v = dictionary["clientId"] as? NSString { clientId = v }
        if let v = dictionary["batchSize"] as? Int { batchSize = v }
        if let v = dictionary["terminatedBatchSize"] as? Int { terminatedBatchSize = v }
        if let v = dictionary["terminatedEventsSize"] as? Int { terminatedEventsSize = v }
        if let v = dictionary["monitoredApps"] as? NSArray { monitoredApps = NSMutableArray(array: v) }
        
        if let v = dictionary["discoveryEnabled"] as? Bool { discoveryEnabled = v }
        if let v = dictionary["locationOptimisedEnabled"] as? Bool { locationOptimisedEnabled = v }
        if let v = dictionary["foregroundTrackingEnabled"] as? Bool { foregroundTrackingEnabled = v }
        if let v = dictionary["significantLocationTrackingEnabled"] as? Bool { significantLocationTrackingEnabled = v }
        if let v = dictionary["shouldCollectData"] as? Bool { shouldCollectData = v }
        if let v = dictionary["allowsTerminatedTracking"] as? Bool { allowsTerminatedTracking = v }
        if let v = dictionary["enableNetworkName"] as? Bool { enableNetworkName = v }
        if let v = dictionary["enableAdvertisingId"] as? Bool { enableAdvertisingId = v }
        if let v = dictionary["enableSimOperator"] as? Bool { enableSimOperator = v }
    }
    
    // TODO: why don't we just make this a convenience init?
    @objc func getConfigValues(_ data: Data?) -> NSDictionary {
        guard let data = data, let dict = try? JSONSerialization.jsonObject(with: data) as? NSDictionary, let body = dict["body"] as? NSDictionary else { return [:] }
        return body
    }
}
