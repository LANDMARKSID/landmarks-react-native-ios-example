//
//  FileManager+DocumentsDir.swift
//  landmarksidios12
//
//  Created by Bohdan Pashchenko on 10.02.2022.
//  Copyright © 2022 Reza Farahani. All rights reserved.
//

import Foundation

extension FileManager {
    var documentsDir: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard urls.count == 1, let url = urls.first else { fatalError() }
        return url
    }
}
