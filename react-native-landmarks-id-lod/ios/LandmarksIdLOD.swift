//
//  LandmarksIdLOD.swift
//  LandmarksIdLod
//
//  Copyright © 2022 Facebook. All rights reserved.
//

import Foundation
//import LandmarksIDSDK

@objc(RNLandmarksIdLOD)
class RNLandmarksIdLOD: NSObject {
    
    // MARK: - Properties
    
    var landmarksIdManager: LandmarksIDManagerDelegate? = LandmarksIDManagerDelegate.sharedManager
    
    // MARK: - Initialiser
    
    override init() {
        print("SDK class initialised");
    }
    
    // MARK: - Functions
    
    @objc static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    // sdk initialisers
    
    @objc func initialiseSDK(_ appId: String, appSecret: String, apiKey: String, debugMode: Bool) -> Void {
        DispatchQueue.main.async {
            LandmarksIDManagerDelegate.initialize(appId, appSecret: appSecret, apiKey: apiKey)
            self.landmarksIdManager?.debug = debugMode
            self.landmarksIdManager?.discoveryEnabled = true
            self.landmarksIdManager?.setup()
        }
    }
    
    // tracking
    
    @objc func startTracking() {
        landmarksIdManager?.startTracking()
    }
    
    @objc func stopTracking() {
        landmarksIdManager?.stopTracking()
    }
    
    @objc func terminate() {
        landmarksIdManager?.applicationWillTerminate()
    }
    
    // location
    
    @objc func requestLocationPermission() {
        landmarksIdManager?.requestLocationPermissions(.authorizedAlways)
    }
    
    // device level data collection
    
    @objc func restartRecordingData() {
        landmarksIdManager?.restartRecordingData()
    }
    
    @objc func stopRecordingData() {
        landmarksIdManager?.stopRecordingData()
    }
    
    // send additional data
    
    @objc func setCustomerId(_ customerId: String) {
        landmarksIdManager?.customerId = customerId
    }
    
    @objc func sendCustomString(_ key: String, value: String) {
        landmarksIdManager?.setCustom(stringValue: value, key: key)
    }
    
    @objc func sendCustomInteger(_ key: String, value: NSNumber) {
        landmarksIdManager?.setCustom(intValue: value, key: key)
    }
    
    @objc func sendCustomFloat(_ key: String, value: NSNumber) {
        landmarksIdManager?.setCustom(floatValue: value, key: key)
    }
}
