//
//  APIManager.swift
//  landmarksidios12
//
//  Created by Bohdan Pashchenko on 10.02.2022.
//  Copyright © 2022 Reza Farahani. All rights reserved.
//

import Foundation
import UIKit.UIDevice

// @objc is for unit tests

class APIManager: NSObject {
    
    @objc init(isProduction: Bool, appId: String, appSecret: String) {
        self.isProduction = isProduction
        self.appId = appId
        self.appSecret = appSecret
        self.overrideBaseUrl = nil
    }
    
    @objc init(baseUrl: URL, appId: String, appSecret: String) {
        self.overrideBaseUrl = baseUrl
        self.isProduction = false
        self.appId = appId
        self.appSecret = appSecret
    }
    
    let isProduction: Bool
    let appId: String
    let appSecret: String
    private let overrideBaseUrl: URL?
    
    // TODO: assert
    private var baseUrl: URL {
        if let overrideBaseUrl = overrideBaseUrl { return overrideBaseUrl }
        return URL(string: isProduction ? "https://events.landmarksid.com" : "https://events-staging.landmarksid.com") ?? URL(fileURLWithPath: "")
    }

    @objc func fetchConfig(completion: @escaping Block2<Data?, Error?>) {
        httpGet(path: "config/\(appId)", completion: completion)
    }
    
    func sendDeviceInfoRequest(deviceInfo: [String: Any], completion: Block<Bool>?) {
        httpPost(path: "device-info", data: deviceInfo) { success, errorMessage in
            // TODO: replace with logger
            NSLog("post device info result success: \(success)\n and message: \(errorMessage ?? "")")
            completion?(success)
        }
    }
    
    typealias Event = [String: Any]
    
    func sendEvents(events: [Event], completion: Block2<Bool, String?>?) {
        guard events.count > 0 else { completion?(true, nil); return }
        
        httpPost(path: "lore/event", data: ["events": events], completion: completion)
    }
    
    // MARK: -
    // TODO: these should probably be replaced with Alamofire
    
    func httpGet(path: String, completion: @escaping Block2<Data?, Error?>) {
        var rq = URLRequest(url: baseUrl.appendingPathComponent(path))
        rq.httpMethod = "GET"
        rq.setValue("application/json", forHTTPHeaderField: "Accept")
        rq.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        rq.setValue(appSecret, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: rq) { data, response, error in
            guard let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data else {
                let error = NSError(landmarksError: "failed to get response, details: \(error?.localizedDescription ?? "N/A")")
                completion(nil, error);
                return
            }
            completion(data, nil)
        }.resume()
    }
    
    func httpPost(path: String, data: [String: Any], completion: Block2<Bool, String?>?) {
        guard UIDevice.current.isConnectedToInternet, let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else { return }
        
        var rq = URLRequest(url: baseUrl.appendingPathComponent(path))
        rq.httpMethod = "POST"
        rq.setValue("application/json", forHTTPHeaderField: "Accept")
        rq.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        rq.setValue(appSecret, forHTTPHeaderField: "Authorization")
        
        rq.httpBody = jsonData
        
        URLSession.shared.dataTask(with: rq) { data, response, error in
            guard let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data, let responseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                // TODO: replace with logger
                NSLog(response?.description ?? "")
                completion?(false, "failed to get response, details: \(error?.localizedDescription ?? "N/A")");
                return
            }
            
            // TODO: replace with logger
            NSLog(responseDict.description)
            completion?(true, nil)
        }.resume()
    }
}
