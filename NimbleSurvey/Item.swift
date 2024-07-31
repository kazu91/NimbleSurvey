//
//  Item.swift
//  NimbleSurvey
//
//  Created by Kazu on 31/7/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
