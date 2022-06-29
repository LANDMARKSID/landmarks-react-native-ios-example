//
//  EventsManager.swift
//  LandmarksIDSDK
//
//  Created by Bohdan Pashchenko on 07.02.2022.
//  Copyright © 2022 Landmarks ID. All rights reserved.
//

import Foundation
import UIKit.UIDevice
import CoreLocation.CLLocation

// TODO: remove once the framework is rewritten in Swift

enum EventState: Int {
    case foreground = 0, background = 1, terminated = 2, sent = 3, all = 4
}

class EventsManager: NSObject {
    var eventPath: String?
    
    func getFilePath(fileName: String, fileType: String) -> String {
        FileManager.default.documentsDir.appendingPathComponent(fileName).appendingPathExtension(fileType).path
    }
    
    func saveEvents(location: CLLocation, event: APIManager.Event) -> Bool {
        removeEvents(state: .sent)
        let res = readEvents(fromFileName: "Events", fileType: "plist").mutableCopy() as! NSMutableDictionary // TODO: force cast
        guard res.count > 0 else { return false }
        
        // TODO: WTF this means?
        // remove init key value from terminated events
        res.removeObject(forKey: "startEvents")
        
        // TODO: WTF is for loop?
        var arr: [NSObject] = []
        for key in res.allKeys {
            arr = res[key] as! [NSObject] // TODO: force cast
            arr.append(event as NSDictionary)
            break
        }
        
        let writeDict = NSMutableDictionary()
        writeDict["events"] = arr
        
        let path = getFilePath(fileName: "Events", fileType: "plist")
        writeDict.write(toFile: path, atomically: true)
        print("terminated events saved")
        return true
    }
    
    @discardableResult func removeEvents(state: EventState) -> Bool {
        let events = readEvents(fromFileName: "Events", fileType: "plist").mutableCopy() as! NSMutableDictionary // TODO: force cast
        
        var eventsArr: [NSObject] = []
        
        for key in events.allKeys {
            guard let value = events[key] as? [NSObject] else { fatalError() } // TODO: fix fatal error
            eventsArr = value.filter { !($0.value(forKey: "lat") as? Double != 0 && $0.value(forKey: "long") as? Double != 0) }
        }
        
        events.removeAllObjects() // TODO: why do we keep only last?
        events["events"] = eventsArr
        
        if state == .sent {
            if let eventPath = eventPath, !eventPath.isEmpty { // TODO: is not empty
                do {
                    try FileManager.default.removeItem(atPath: eventPath)
                    if events.count > 0 {
                        events.write(toFile: eventPath, atomically: true)
                    }
                }
                catch {
                    assertionFailure()
                }
            }
            
            return true // TODO: why true is returned only for .sent state?
        }
        
        return false
    }
    
    func readEvents(fromFileName fileName: String, fileType: String) -> NSDictionary {
        let path = getFilePath(fileName: fileName, fileType: fileType)
        
        if !FileManager.default.fileExists(atPath: path) {
            print("path doesn't exist. plist file will be copied to the path.")
            
            guard let bundlePath = Bundle.main.path(forResource: fileName, ofType: fileType) else {
                // TODO: for what this Events.plist would be distributed with app bundle?
                print("Events.plist not found in main bundle. Please, make sure it is part of the bundle.")
                return [:]
            }
            
            do {
                try FileManager.default.copyItem(atPath: bundlePath, toPath: path)
                try FileManager.default.removeItem(atPath: path) // TODO: why do we do this? Why remove after copy?
            }
            catch { assertionFailure() }
        }
        
        guard let events = NSDictionary(contentsOfFile: path) else { assertionFailure(); return [:] }
        return events
    }
}
