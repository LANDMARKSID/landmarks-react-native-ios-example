//
//  Logger.swift
//  landmarksidios12
//
//  Created by Bohdan Pashchenko on 12.03.2022.
//  Copyright © 2022 Reza Farahani. All rights reserved.
//

import Foundation

class Logger: NSObject {
    init(isDebug: @escaping BlockRet<Bool>) { self.isDebug = isDebug }
    
    var allLogs: String = ""
    var isDebug: BlockRet<Bool>
    
    func logDataDebug(_ str: String) {
        guard isDebug() else { return }
        allLogs.append("\(Date().description)\n\(str)\n")
    }
    
    func logData(_ str: String) {
        allLogs.append("\(Date().description)\n\(str)\n")
    }
}
