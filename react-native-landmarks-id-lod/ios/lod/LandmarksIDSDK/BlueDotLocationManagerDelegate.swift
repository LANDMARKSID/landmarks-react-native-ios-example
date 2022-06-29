//
//  BlueDotLocationManagerDelegate.swift
//  LandmarksIDSDK
//
//  Created by Bohdan Pashchenko on 15.04.2022.
//

//import BDPointSDK

protocol BlueDotLocationManagerDelegateDelegate: AnyObject {
    var logger: Logger { get }
    var apiManager: APIManager { get }
    func generateLRE(eventId: String, eventType: BlueDotLocationManagerDelegate.LREType, location: BDLocationInfo, fence: BDFenceInfo, dwellTime: UInt) -> APIManager.Event
}

class BlueDotLocationManagerDelegate: NSObject {
    weak var delegate: BlueDotLocationManagerDelegateDelegate!
    private var logger: Logger { delegate.logger }
    private var eventIdByFenceId: [String: String] = [:]
    private var locationByFenceId: [String: BDLocationInfo] = [:]
}

extension BlueDotLocationManagerDelegate: BDPSessionDelegate {
    func willAuthenticate(withApiKey apiKey: String!) {
        logger.logDataDebug("Authenticating with LandmarksID service\n")
    }
    
    func authenticationWasSuccessful() {
        logger.logDataDebug("Authenticated successfully with LandmarksID service\n")
    }
    
    func authenticationWasDenied(withReason reason: String!) {
        logger.logDataDebug("Authentication with LandmarksID service denied, with reason: \(reason ?? "")\n")
    }
    
    func authenticationFailedWithError(_ error: Error!) {
        logger.logDataDebug("Authentication with LandmarksID service failed, with reason: \(error?.localizedDescription ?? "")\n")
    }
        
    func didEndSession() {
        logger.logDataDebug("Logged out\n")
    }
    
    func didEndSessionWithError(_ error: Error!) {
        logger.logDataDebug("Logged out with error: \(error?.localizedDescription ?? "")\n")
    }
}

extension BlueDotLocationManagerDelegate: BDPLocationDelegate {
    enum LREType { case checkin, checkout }
    
    func didCheck(intoFence fence: BDFenceInfo!, inZone zoneInfo: BDZoneInfo!, atLocation location: BDLocationInfo!, willCheckOut: Bool, withCustomData customData: [AnyHashable : Any]!) {
        guard let fence = fence, let zoneInfo = zoneInfo, let location = location else { expectationFail(); return }
        let eventId = UUID().uuidString
        let event = delegate.generateLRE(eventId: eventId, eventType: .checkin, location: location, fence: fence, dwellTime: 0)
        
        locationByFenceId[fence.id] = location
        eventIdByFenceId[fence.id] = eventId
        
        delegate.apiManager.sendEvents(events: [event]) { success, error in
            self.logger.logData("checkIn result: \(success ? "Succesful" : "Failure")\n and message: \(error ?? "")")
        }
        
        logger.logDataDebug("Checked into \(fence.name ?? "") - \(zoneInfo.name ?? "")\n(\(fence.name ?? ""), \(zoneInfo.name ?? "")) (\(location.longitude), \(location.latitude))\n")
    }
    
    func didCheckOut(fromFence fence: BDFenceInfo!, inZone zoneInfo: BDZoneInfo!, on date: Date!, withDuration checkedInDuration: UInt, withCustomData customData: [AnyHashable : Any]!) {
        guard let fence = fence, let zoneInfo = zoneInfo, let location = locationByFenceId[fence.id], let eventId = eventIdByFenceId[fence.id] else { expectationFail(); return }
        
        locationByFenceId.removeValue(forKey: fence.id)
        eventIdByFenceId.removeValue(forKey: fence.id)
        
        let event = delegate.generateLRE(eventId: eventId, eventType: .checkout, location: location, fence: fence, dwellTime: checkedInDuration)
        delegate.apiManager.sendEvents(events: [event]) { success, error in
            self.logger.logData("checkOut result: \(success ? "Succesful" : "Failure")\n and message: \(error ?? "")")
        }
        
        logger.logDataDebug("Checked out of \(fence.name ?? "") - \(zoneInfo.name ?? "")\n(\(fence.name ?? ""), \(zoneInfo.name ?? "")) (\(location.longitude), \(location.latitude))\n")
    }
}
