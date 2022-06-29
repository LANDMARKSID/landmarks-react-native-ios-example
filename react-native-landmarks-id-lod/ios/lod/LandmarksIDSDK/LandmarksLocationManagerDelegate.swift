//
//  LandmarksLocationManagerDelegate.swift
//  landmarksidios12
//
//  Created by Bohdan Pashchenko on 12.03.2022.
//  Copyright © 2022 Reza Farahani. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol LandmarksLocationManagerDelegateDelegate: AnyObject {
    var logger: Logger { get }
    var serverConfigLoaded: Bool { get }
    var shouldCollectData: Bool { get }
    var significantLocationTrackingEnabled: Bool { get }
    var locationOptimisedEnabled: Bool { get }
    var foregroundTrackingEnabled: Bool { get }
    var distanceFilterMeters: Double { get }
    var appState: String { get } // TODO: remove
    var batchSize: Int { get }
    var loreRequestStatus: Bool { get }
    
    func sendEvents()
    func stopSignificantLocationTracking()
    func startSignificantLocationTracking()
    func startForegroundTracking()
    func stopTracking()
    func generateLore(location: CLLocation) -> APIManager.Event
    func saveEventInTerminatedMode(location: CLLocation)
    
    func readAndSendTerminatedEventsIfNeeded()
    
    var discoveryTrackingEnabled: Bool { get }
    var discoveryEnabled: Bool { get }
    
    func stopDiscoveryTracking()
    func startDiscoveryTracking()
}

class LandmarksLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    weak var delegate: LandmarksLocationManagerDelegateDelegate!
    private var logger: Logger { delegate.logger }
    
    // TODO: review perhaps merge logic here with that in getConfig handler
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        logger.logDataDebug("LOCATION AUTORIZATION CHANGED\n")
        guard delegate.serverConfigLoaded else { return }
        
        delegate.sendEvents()
        
        if status == .authorizedAlways {
            if delegate.significantLocationTrackingEnabled, !delegate.locationOptimisedEnabled { delegate.stopSignificantLocationTracking() }
            else if delegate.shouldCollectData { delegate.startSignificantLocationTracking() }
            
            if !delegate.locationOptimisedEnabled { delegate.stopTracking() }
            else if delegate.shouldCollectData { delegate.startForegroundTracking() }
         
            if delegate.discoveryTrackingEnabled, !delegate.discoveryEnabled { delegate.stopDiscoveryTracking() }
            if !delegate.discoveryTrackingEnabled, delegate.discoveryEnabled, delegate.shouldCollectData { delegate.startDiscoveryTracking() }
        }
        else if status == .authorizedWhenInUse {
            logger.logData("WhileInUse permissions")
            
            if delegate.significantLocationTrackingEnabled, !delegate.locationOptimisedEnabled { delegate.stopSignificantLocationTracking() }
            
            if UIApplication.shared.applicationState != .background {
                logger.logData("In Foreground and whileInUse permissions")
                if delegate.foregroundTrackingEnabled, !delegate.locationOptimisedEnabled { delegate.stopTracking() }
                else if delegate.shouldCollectData { delegate.startForegroundTracking() }
            }
            else { logger.logData("IN BACKGROUND??") }
        }
        else {
            delegate.stopSignificantLocationTracking()
            delegate.stopTracking()
            delegate.stopDiscoveryTracking()
        }
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) { logger.logDataDebug("Resume Location updates\n") }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { logger.logDataDebug("Failed with error \(error)\n") }
    
    var lastLORELocation: CLLocation?
    var usedEventIds: [String: Any] = [:]
    var events: [APIManager.Event] = []
    var LOCount = 0
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let timeSinceLocation = location.timestamp.timeIntervalSince(Date())
        logger.logData("Time elased since event time=\(timeSinceLocation)")
        
        if timeSinceLocation >= 60 || timeSinceLocation <= -60 { // TODO: can this time diff be negative?
            logger.logData("REMOVE CACHED LOCATION EVENTS")
            delegate.sendEvents()
            return
        }
        
        if let lastLORELocation = lastLORELocation {
            let distanceFromLast = lastLORELocation.distance(from: location)
            let timeSinceLast = lastLORELocation.timestamp.timeIntervalSinceNow * -1
        
            logger.logData("INSIDE LOCATION CALLBACK")
            logger.logDataDebug("Distance from last=\(distanceFromLast)")
            logger.logDataDebug("Time since last=\(timeSinceLast)")
            
            if distanceFromLast < delegate.distanceFilterMeters {
                logger.logData("Event Discarded. distance=\(distanceFromLast) time=\(timeSinceLast)")
                return
            }
        }
            
        self.lastLORELocation = location
        let event = delegate.generateLore(location: location)
        
        guard let key = event["sourceEventId"] as? String, !usedEventIds.keys.contains(key) else { return }
        usedEventIds[key] = event
        
        var duplicateFlag = false
        
        for e in events {
            let alts = [e, event].map { ($0["altitude"] as? Double).expectNonNil() }
            let longs = [e, event].map { ($0["long"] as? Double).expectNonNil() }
            if alts[0] == alts[1], longs[0] == longs[1] { duplicateFlag = true; break }
        }
        
        if !duplicateFlag {
            events.append(event)
            
            if (event["appState"] as? String).expectNonNil() == "terminated" { delegate.saveEventInTerminatedMode(location: location) }
            LOCount += 1
        }
        
        logger.logDataDebug("\(event)\n")
        
        if shouldSendBackgroundEvents || events.count > delegate.batchSize {
            delegate.sendEvents()
            delegate.readAndSendTerminatedEventsIfNeeded()
        }
        
        if shouldSendTerminatedEvents { delegate.readAndSendTerminatedEventsIfNeeded() }
    }
    
    var shouldSendBackgroundEvents: Bool { UIApplication.shared.applicationState != .background && !events.isEmpty }
    var shouldSendTerminatedEvents: Bool { delegate.appState == "terminated" && UserDefaults.standard.bool(forKey: "allowsTerminatedTrackingFromUserDefautls") }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        guard let managerLocation = manager.location else { expectationFail(); return }
        
        let location = CLLocation(coordinate: visit.coordinate, altitude: managerLocation.altitude, horizontalAccuracy: visit.horizontalAccuracy, verticalAccuracy: managerLocation.verticalAccuracy, timestamp: visit.arrivalDate)
        
        let event = delegate.generateLore(location: location)
        events.append(event)
        LOCount += 1
        
        logger.logDataDebug("\(event)\n")
        
        if (shouldSendBackgroundEvents && delegate.loreRequestStatus) || shouldSendTerminatedEvents || events.count > delegate.batchSize {
            delegate.sendEvents()
        }
    }
}
