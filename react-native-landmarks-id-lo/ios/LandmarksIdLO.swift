//
//  LandmarksIdLO.swift
//  LandmarksIdLo
//
//  Copyright © 2022 Facebook. All rights reserved.
//

import Foundation
import LandmarksIDSDK

@objc(RNLandmarksIdLO)
class RNLandmarksIdLO: NSObject {
  
  // MARK: - Properties
  
  var landmarksIdManager: LandmarksIDManagerDelegate?
  
  // MARK: - Initialiser
  
  override init() {
    print("SDK class initialised");
  }
  
  // MARK: - Functions
  
  @objc static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  // sdk initialisers
  
  @objc func initialiseSDK(_ appId: String, appSecret: String, debugMode: Bool) -> Void {
    DispatchQueue.main.async {
      self.landmarksIdManager = LandmarksIDManagerDelegate.initialize(appId, appSecret: appSecret)
      self.landmarksIdManager?.debug = debugMode
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
  
  @objc func requestLocationWhenInUse() {
    landmarksIdManager?.requestLocationPermissions(.authorizedWhenInUse)
  }
  
  @objc func requestLocationAlways() {
    landmarksIdManager?.requestLocationPermissions(.authorizedAlways)
  }
  
  // device level data collection
  
  
  /*
   ================================================================================
   || functions exported to react-native are asynchronous with void return type. ||
   || for returning any value, callback is used.                                 ||
   ================================================================================
   */
  
//  @objc func isSDKAllowedToRecordData(_ callback: RCTResponseSenderBlock) {
//    let allowed: Bool = LandmarksIDManagerDelegate.sharedManager().isAllowedToRecordData()
//    callback([allowed])
//  }
  
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
    landmarksIdManager?.setCustomString(key, value: value)
  }
  
  @objc func sendCustomInteger(_ key: String, value: NSNumber) {
    landmarksIdManager?.setCustomInt(key, value: Int32(truncating: value))
  }

  @objc func sendCustomFloat(_ key: String, value: NSNumber) {
    landmarksIdManager?.setCustomFloat(key, value: Float(truncating: value))
  }
}
