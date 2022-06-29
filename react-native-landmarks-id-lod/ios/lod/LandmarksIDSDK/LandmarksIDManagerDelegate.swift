//
//  LandmarksIDManagerDelegateSwift.swift
//  landmarksidios12
//
//  Created by Bohdan Pashchenko on 10.03.2022.
//  Copyright © 2022 Reza Farahani. All rights reserved.
//

import Foundation
import UIKit.UIDevice
import AdSupport
import CoreLocation.CLLocation
import AppTrackingTransparency
import CoreTelephony
//import BDPointSDK

fileprivate let LANDMARKSID_LORE_EVENT_TYPE = "lore"
fileprivate let LANDMARKSID_LRE_EVENT_TYPE = "lre"
fileprivate let LANDMARKSID_SOURCE = "landmarksid-lod-sdk" // TODO: should this be lod or lo?
fileprivate let SDK_VERSION = "2.5.0"

@objc public class LandmarksIDManagerDelegate: NSObject {
    @objc public static var sharedManager = LandmarksIDManagerDelegate()
    
    var discoveryTrackingEnabled: Bool = false
    var bluedotApiKey: String?
    var bluedotDelegate = BlueDotLocationManagerDelegate()
    
    @objc public class func initialize(_ appIdentifier: String, appSecret: String, apiKey: String) {
        sharedManager.appIdentifier = appIdentifier
        sharedManager.appSecret = appSecret
        sharedManager.bluedotApiKey = apiKey
        
        sharedManager.bluedotDelegate.delegate = sharedManager
        BDLocationManager.instance().sessionDelegate = sharedManager.bluedotDelegate
        BDLocationManager.instance().locationDelegate = sharedManager.bluedotDelegate
    }
        
    var eventsManager: EventsManager = EventsManager()
    lazy var logger: Logger = Logger(isDebug: { [weak self] in self?.debug ?? false })
    lazy var locationManagerDelegate: LandmarksLocationManagerDelegate = LandmarksLocationManagerDelegate()
    var locationManager: CLLocationManager = CLLocationManager()
    
    private override init() {
        super.init()
        locationManagerDelegate.delegate = self
        locationManager.delegate = locationManagerDelegate
    }
    
    @objc public var enableAdvertisingId: Bool = false
    var adTrackingEnabled: Bool = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
    private(set) var appIdentifier: String = ""
    private(set) var appSecret: String = ""

    var vendorId: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    var sessionId: String = UUID().uuidString // TODO: can we infer this instead of storing as state?
    var appBuildVersion: String = Bundle.main.version
    var osVersion: String = UIDevice.current.systemVersion
    
    var clientId: String = ""
    @objc public var customerId: String = ""
    @objc var customData: [[String: String]] = []
    
    @objc public var debug: Bool = false
    var loreRequestStatus: Bool = false // TODO: would it be better to use a queue to serially sync sending of the events?
    @objc public var shouldCollectData = false
    var serverConfigLoaded = false
    var appState: String = "notInitilisedYet"
    @objc public var monitoredApps: [String] = []
    
    @objc public var batchSize: Int = 10
    var terminatedBatchSize: Int = 10
    @objc public var distanceFilterMeters: CLLocationDistance = 100
    var significantLocationTrackingEnabled: Bool = false
    var foregroundTrackingEnabled: Bool = false
    @objc public var locationOptimisedEnabled: Bool = false
    var allowsTerminatedTracking: Bool = false
    var lastDeviceInfo: [String: Any]?
    @objc public var enableSimOperator: Bool = false

    @objc public var isAllowedToRecordData: Bool {
        get { UserDefaults.standard.bool(forKey: "shouldStopRecordingData") == false }
        set { UserDefaults.standard.set(!newValue, forKey: "shouldStopRecordingData") }
    }
    
    @objc public func stopRecordingData() { isAllowedToRecordData = false }
    @objc public func restartRecordingData() { isAllowedToRecordData = true }

    @objc public var deviceId: String { enableAdvertisingId ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : "" }
    
    @objc public var discoveryEnabled: Bool = false
    
    var apiManager: APIManager { APIManager(isProduction: !debug, appId: appIdentifier, appSecret: appSecret) }
    
    func saveEventInTerminatedMode(location: CLLocation) {
        _ = eventsManager.saveEvents(location: location, event: generateLore(location: location))
    }
    
    func generateLore(location: CLLocation) -> APIManager.Event {
        let sourceEventId = UUID().uuidString
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        return [
            "_id": sourceEventId,
            "sourceEventId": sourceEventId,
            "messageType": LANDMARKSID_LORE_EVENT_TYPE,
            "schemaVersion": 1.0,
            "appId": self.appIdentifier,
            "deviceId": deviceId,
            "appState": getCurrentAppState(),
            "sessionId": self.sessionId,
            "vendorId": self.vendorId,
            "clientId": self.clientId,
            "customerId": self.customerId,
            "source": LANDMARKSID_SOURCE,
            "lat": location.coordinate.latitude,
            "long": location.coordinate.longitude,
            "horizontalAccuracy": location.horizontalAccuracy,
            "verticalAccuracy": location.verticalAccuracy,
            "deviceSpeed": location.speed,
            "altitude": location.altitude,
            "floor": location.floor.expectNonNil()?.level ?? 0,
            "heading": location.course,
            "sdkVersion": SDK_VERSION,
            "deviceType": "iOS",
            "osVersion": self.osVersion,
            "appBuildVersion": self.appBuildVersion,
            "adTrackingEnabled": adTrackingEnabled,
            "customData": self.customData,
            "eventTime": f.string(from: location.timestamp),
            "networkStatus": UIDevice.current.networkStatus,
            "chargeStatus": UIDevice.current.batteryStateStr,
            "batteryLevel" : Int(abs(UIDevice.current.batteryLevel) * 100)
        ]
    }
    
    func getCurrentAppState() -> String {
        let location = UserDefaults.standard.integer(forKey: "location")
        let appState = UserDefaults.standard.string(forKey: "appState")
        
        if location == 9001 { UserDefaults.standard.set("terminated", forKey: "appState") }
        if appState != "foreground" && appState != "background" { UserDefaults.standard.set("notDetermined", forKey: "appState") }
                    
        UserDefaults.standard.synchronize()
        return UserDefaults.standard.string(forKey: "appState").expectNonNil() ?? ""
    }
    
    @objc public func applicationWillTerminate() { }
    
    func readAndSendTerminatedEvents() {
        let resDict = NSMutableDictionary(dictionary: eventsManager.readEvents(fromFileName: "Events", fileType: "plist"))
        guard resDict.count > 0, let firstArr = resDict.allValues.first as? [AnyObject] else { print("WARNING: Couldn't create dictionary from Events.plist at Documents Dicretory! Default values will be used!"); return }
        
        print("Saved Events.plist file in Documents Direcotry is --> \(resDict)")
        sendLOREEventsFromTerminatedMode(terminatedEvents: resDict)
        
        let events: [AnyObject] = firstArr
            .compactMap { ($0 as? [String: Any]).expectNonNil() }
            .map {
                var d = $0
                d.removeValue(forKey: "lat")
                d.removeValue(forKey: "long")
                return d as NSDictionary
            }
        expect(events.count == 1)
        
        resDict.removeAllObjects()
        resDict.setValue(events, forKey: "events")
        
        let path = eventsManager.getFilePath(fileName: "Events", fileType: "plist")
        try? FileManager.default.removeItem(atPath: path)
        
        resDict.write(toFile: path, atomically: true)
    }
    
    func sendLOREEventsFromTerminatedMode(terminatedEvents: NSDictionary) {
        guard UIDevice.current.isConnectedToInternet, let events = terminatedEvents["events"] as? [APIManager.Event] else { return }
        
        loreRequestStatus = true
        apiManager.sendEvents(events: events) { success, error in
            self.loreRequestStatus = false
            print("post LORE events from Terminated Modee result: \((success ? "Succesful" : "Failure"))\n and message: \(error ?? "")")
        }
    }
    
    func getCountOfTerminatedEvents() -> Int {
        let resDict = NSMutableDictionary(dictionary: eventsManager.readEvents(fromFileName: "Events", fileType: "plist"))
        
        guard resDict.count > 0 else {
            print("WARNING: Couldn't create dictionary from Events.plist at Documents Dicretory! Default values will be used!")
            return 0
        }
        
        NSLog("Saved Events.plist file in Documents Direcotry is --> \(resDict.description)")
            
        expect(resDict.count == 1)
        return (resDict.allValues.first as? [AnyObject]).expectNonNil()?.count ?? 0
    }
    
    @objc public func requestPermissionForIDFA() {
        guard #available(iOS 14, *) else { return }
        ATTrackingManager.requestTrackingAuthorization { _ in }
    }
    
    func getLocationAuthorizationStatusString() -> String { CLLocationManager.authorizationStatus().landmarksDescription }
    
    func getATTrackingPermissionStatusString() -> String {
        guard #available(iOS 14, *) else { return "" }
        return ATTrackingManager.trackingAuthorizationStatus.landmarksDescription
    }
    
    func getAccuracyAuthorizationStatusString() -> String {
        guard #available(iOS 14, *) else { return "" }
        return CLLocationManager().accuracyAuthorization.landmarksDescription
    }
    
    // MARK: - custom data
    
    @objc public func setCustom(intValue value: NSNumber?, key: String) { setCustom(value: (value?.intValue ?? 0).str, type: "int", key: key) }
    @objc public func setCustom(floatValue value: NSNumber?, key: String) { setCustom(value: (value?.floatValue ?? 0).str, type: "float", key: key) }
    @objc public func setCustom(stringValue value: String?, key: String) { setCustom(value: value, type: "string", key: key) }
    
    func setCustom(value: String?, type: String, key: String) {
        guard !key.isEmpty else { return }
        
        if value.isEmptyOrNil {
            customData.removeAll(where: { $0["key"] == key })
            return
        }
        
        guard let value = value else { return }
        
        let dataItem = ["key": key, "value": value, "type": type]
        if let index = customData.firstIndex(where: { $0["key"].expectNonNil() == key }) { customData[index] = dataItem }
        else { customData.append(dataItem) }
        
        customDataFlag = true
        sendDeviceInfo()
    }
    
    private var customDataFlag = false
    private var lastDateSentDeviceInfo: Date = Date()

    func sendDeviceInfo() {
        guard UIDevice.current.isConnectedToInternet else { return }
        // TODO: do we need fabs here?
        guard fabs(Date().timeIntervalSince(lastDateSentDeviceInfo)) > 3 || lastDeviceInfo == nil else { return }
        lastDateSentDeviceInfo = Date() // TODO: should this be set after successfully sending the request?
        
        generateDeviceInfo { deviceInfo in
            defer { self.logger.logDataDebug("\(deviceInfo)\n") }
            guard self.shouldCollectData else { return }
            guard self.customDataFlag || deviceInfo as NSDictionary != self.lastDeviceInfo as NSDictionary? else { return }
            self.customDataFlag = false // TODO: can we have customDataFlag as this function param instead of object state?
            self.apiManager.sendDeviceInfoRequest(deviceInfo: deviceInfo) { success in
                if success { self.lastDeviceInfo = deviceInfo }
            }
        }
    }
    
    func updateDeviceInfo() {
        vendorId = UIDevice.current.identifierForVendor.expectNonNil()?.uuidString ?? ""
        sessionId = UUID().uuidString
        adTrackingEnabled = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        appBuildVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String).expectNonNil() ?? "N/A"
        osVersion = UIDevice.current.systemVersion
    }
    
    func getAppList(completionBlock: @escaping Block<[String]>) {
        // TODO: do we need to do this async or main or perhaps we're already on main?
        DispatchQueue.main.async {
            let apps = self.monitoredApps.filter {
                guard let url = URL(string: $0).expectNonNil() else { return false }
                return UIApplication.shared.canOpenURL(url)
            }
            // TODO: do we need do dispatch to global here, perhaps the caller should do that?
            DispatchQueue.global().async { completionBlock(apps) }
        }
    }
    
    func generateDeviceInfo(completion: @escaping Block<[String: Any]>) {
        updateDeviceInfo()
        
        let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider
        let carrierName: String = enableSimOperator ? carrier?.carrierName ?? "" : ""
        let simOperatorIso: String = enableSimOperator ? carrier?.isoCountryCode ?? "" : ""
        
        getAppList { appList in
            let deviceInfo = [
                "appId": self.appIdentifier,
                "appVersion": self.appBuildVersion,
                "vendorId": self.vendorId,
                "deviceId": self.deviceId,
                "clientId": self.clientId,
                "customerId": self.customerId,
                "adTrackingEnabled": self.adTrackingEnabled,
                "adTrackingPermission": self.getATTrackingPermissionStatusString(),
                "locationPermissions": self.getLocationAuthorizationStatusString(),
                "locationAccuracy": self.getAccuracyAuthorizationStatusString(),
                "deviceModel": UIDevice.current.model,
                "os": "iOS",
                "osVersion": self.osVersion,
                "sdkVersion": SDK_VERSION,
                "customData": self.customData,
                "installedApps": appList,
                "simOperatorName": carrierName,
                "simOperatorIso": simOperatorIso,
            ] as [String: Any]
            
            completion(deviceInfo)
        }
    }
    
    @objc public func requestLocationPermissions(_ type: CLAuthorizationStatus) {
        switch type {
        case .authorizedAlways: locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse: locationManager.requestWhenInUseAuthorization()
        default: expectationFail(); break
        }
    }
    
    @objc public func startTracking() {
        defer { UserDefaults.standard.synchronize() }
        
        UserDefaults.standard.set("foreground", forKey: "appState")
        
        guard isAllowedToRecordData else { return }
        
        if shouldCollectData {
            sendDeviceInfo()
            startSignificantLocationTracking()
            startForegroundTracking()
        }
        
        UserDefaults.standard.set(9000, forKey: "location") // TODO: wtf?
        getConfig()
    }
    
    private var configRequestInFlight: Bool = false
    
    func getConfig() {
        guard UIDevice.current.isConnectedToInternet, !configRequestInFlight else { return }
        configRequestInFlight = true
        
        // TODO: can we just use config instance instead of duplicating vars as locals?
        let config = Configuration()
        
        apiManager.fetchConfig { data, error in
            self.configRequestInFlight = false
            let configDict = config.getConfigValues(data)
                        
            guard error == nil, configDict.count > 0 else {
                expectationFail()
                self.serverConfigLoaded = false
                self.logger.logDataDebug("ERROR IN READING CONFIG\n")
                return
            }
            
            NSLog("Config Read")
            self.serverConfigLoaded = true
            self.logger.logDataDebug("\(configDict)\n")
            config.initConfig(configDict)
            
            self.distanceFilterMeters = config.distanceFilterMeters
            self.batchSize = config.batchSize
            self.monitoredApps = (config.monitoredApps as? [String]).expectNonNil() ?? []
            self.locationOptimisedEnabled = config.locationOptimisedEnabled
            self.shouldCollectData = config.shouldCollectData
            self.allowsTerminatedTracking = config.allowsTerminatedTracking
            self.enableSimOperator = config.enableSimOperator
            self.enableAdvertisingId = config.enableAdvertisingId
            self.significantLocationTrackingEnabled = config.locationOptimisedEnabled
            self.shouldCollectData = config.shouldCollectData
            
            self.sendDeviceInfo()
            
            UserDefaults.standard.set(config.allowsTerminatedTracking, forKey: "allowsTerminatedTrackingFromUserDefautls")
            UserDefaults.standard.synchronize()
            
            NSLog("Significant Tracking enabled?: \(self.significantLocationTrackingEnabled ? "YES" : "NO")")
            
            if self.significantLocationTrackingEnabled, self.locationOptimisedEnabled, self.shouldCollectData { self.startSignificantLocationTracking() }
            if !self.significantLocationTrackingEnabled, !self.locationOptimisedEnabled { self.stopSignificantLocationTracking() }
            
            if self.shouldCollectData, self.locationOptimisedEnabled { self.startForegroundTracking() }
            if self.shouldCollectData, !self.locationOptimisedEnabled { self.stopTracking() }
            
            if !self.shouldCollectData, self.significantLocationTrackingEnabled { self.stopSignificantLocationTracking() }
            if !self.shouldCollectData, !self.foregroundTrackingEnabled { self.stopTracking() }
        
            if self.discoveryTrackingEnabled, !self.discoveryEnabled { self.stopDiscoveryTracking() }
            if !self.discoveryTrackingEnabled, self.discoveryEnabled, self.shouldCollectData { self.startDiscoveryTracking() }
            
            if !self.shouldCollectData {
                if self.discoveryTrackingEnabled { self.stopDiscoveryTracking() }
                if self.significantLocationTrackingEnabled { self.stopSignificantLocationTracking() }
                if !self.foregroundTrackingEnabled { self.stopTracking() }
            }
        }
    }
    
    @objc public func setup() {
        getConfig()
    }
}

extension CLAuthorizationStatus {
    var landmarksDescription: String {
        switch self {
        case .authorizedAlways: return "always"
        case .authorizedWhenInUse: return "whenInUse"
        case .denied: return "denied"
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        @unknown default: expectationFail(); return "N/A"
        }
    }
}

extension CLAccuracyAuthorization {
    var landmarksDescription: String {
        switch self {
        case .fullAccuracy: return "full"
        case .reducedAccuracy: return "reduced"
        default: expectationFail(); return "unknown"
        }
    }
}

@available(iOS 14, *)
extension ATTrackingManager.AuthorizationStatus {
    var landmarksDescription: String {
        switch self {
        case .authorized: return "authorised"
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: expectationFail(); return "N/A"
        }
    }
}

extension LandmarksIDManagerDelegate: LandmarksLocationManagerDelegateDelegate {
    
    func stopSignificantLocationTracking() {
        logger.logDataDebug("STOP MONITORING SIGNIFICANT LOCATION CHANGES\n")
        locationManager.stopMonitoringSignificantLocationChanges()
        significantLocationTrackingEnabled = false
    }
    
    func startSignificantLocationTracking() {
        guard isAllowedToRecordData, CLLocationManager.locationServicesEnabled(), CLLocationManager.authorizationStatus() == .authorizedAlways, locationOptimisedEnabled else { return }
        logger.logDataDebug("START MONITORING SIGNIFICANT LOCATION CHANGES\n")
        locationManager.startMonitoringSignificantLocationChanges()
        significantLocationTrackingEnabled = true
    }
    
    func startForegroundTracking() {
        guard serverConfigLoaded, locationOptimisedEnabled else { return }
        defer { sendEvents() }
        
        guard CLLocationManager.locationServicesEnabled(), (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse) else { return }
        logger.logDataDebug("START TRACKING\n")
        
        locationManager.distanceFilter = distanceFilterMeters
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .fitness
        stopSignificantLocationTracking()
        locationManager.startUpdatingLocation()
        foregroundTrackingEnabled = true
    }
    
    @objc public func stopTracking() {
        logger.logDataDebug("STOP TRACKING\n")
        
        UserDefaults.standard.set("background", forKey: "appState")
        UserDefaults.standard.synchronize()
        
        foregroundTrackingEnabled = false
        locationManager.stopUpdatingLocation()
        
        if allowsTerminatedTracking {
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.activityType = .fitness
        }
        
        startSignificantLocationTracking()
    }
    
    func readAndSendTerminatedEventsIfNeeded() {
        guard getCountOfTerminatedEvents() >= terminatedBatchSize else { return }
        readAndSendTerminatedEvents()
    }

    func sendEvents() {
        guard UIDevice.current.isConnectedToInternet, shouldCollectData, !locationManagerDelegate.events.isEmpty else { return }
        
        loreRequestStatus = true
        apiManager.sendEvents(events: locationManagerDelegate.events) { success, errorMessage in
            NSLog("send event result: \(success ? "Succesful" : "Failure")\n and message: \(errorMessage ?? "")")
            self.loreRequestStatus = false
        }
        
        logger.logDataDebug("Events recorded")
        locationManagerDelegate.events.removeAll()
    }
}

extension LandmarksIDManagerDelegate {
    func startDiscoveryTracking() {
        guard discoveryEnabled, isAllowedToRecordData, CLLocationManager.locationServicesEnabled(), CLLocationManager.authorizationStatus() == .authorizedAlways else { return }
        guard let bluedotApiKey = bluedotApiKey.expectNonNil() else { return }
        logger.logDataDebug("START DISCOVERY TRACKING")
        
        discoveryTrackingEnabled = true
        
        if #available(iOS 14, *), locationManager.accuracyAuthorization != .fullAccuracy { return }
        BDLocationManager.instance().authenticate(withApiKey: bluedotApiKey, requestAuthorization: .authorizedAlways)
    }
    
    func stopDiscoveryTracking() {
        logger.logDataDebug("STOP DISCOVERY TRACKING")
        BDLocationManager.instance().logOut()
        discoveryTrackingEnabled = false
    }

    // TODO: looks like start / stop session is not used, remove?
    
    func startSession() {
        guard isAllowedToRecordData, CLLocationManager.locationServicesEnabled(), CLLocationManager.authorizationStatus() == .authorizedAlways else { return }
        
        if discoveryEnabled {
            logger.logDataDebug("START SESSION")
            BDLocationManager.instance().authenticate(withApiKey: bluedotApiKey, requestAuthorization: .authorizedAlways)
            discoveryTrackingEnabled = true
        }
        
        if locationOptimisedEnabled {
            logger.logDataDebug("START MONITORING SIGNIFICANT LOCATION CHANGES")
            locationManager.startMonitoringSignificantLocationChanges()
            significantLocationTrackingEnabled = true
        }
    }
    
    func stopSession() {
        BDLocationManager.instance().logOut()
        locationManager.stopMonitoringSignificantLocationChanges()
        significantLocationTrackingEnabled = false
        discoveryTrackingEnabled = false
    }
}

extension LandmarksIDManagerDelegate: BlueDotLocationManagerDelegateDelegate {
    func generateLRE(eventId: String, eventType: BlueDotLocationManagerDelegate.LREType, location: BDLocationInfo, fence: BDFenceInfo, dwellTime: UInt) -> APIManager.Event {
        let eventTypeStr: String
        switch eventType {
        case .checkin: eventTypeStr = "checkin"
        case .checkout: eventTypeStr = "checkout"
        }
        
        return [
            "_id": eventId,
            "sourceEventId": eventId,
            "messageType": LANDMARKSID_LRE_EVENT_TYPE,
            "schemaVersion": 1.0,
            "appId": self.appIdentifier,
            "deviceId": self.deviceId,
            "appState": self.getCurrentAppState(),
            "sessionId": self.sessionId,
            "vendorId": self.vendorId,
            "clientId": self.clientId,
            "customerId": self.customerId,
            "source": "bluedots",
            "sourceType": eventTypeStr,
            "sourceFenceId": fence.id.expectNonNil() ?? "",
            "sourceFenceName": fence.name.expectNonNil() ?? "",
            "lat": location.latitude,
            "long": location.longitude,
            "deviceSpeed": location.speed,
            "dwellTime": dwellTime,
            "heading": location.bearing,
            "sdkVersion": SDK_VERSION,
            "deviceType": "iOS",
            "osVersion": self.osVersion,
            "appBuildVersion": self.appBuildVersion,
            "adTrackingEnabled": self.adTrackingEnabled,
            "customData": self.customData,
            "networkStatus": UIDevice.current.networkStatus,
            "chargeStatus": UIDevice.current.batteryStateStr,
            "batteryLevel" : Int(abs(UIDevice.current.batteryLevel) * 100)
        ]
    }
}
