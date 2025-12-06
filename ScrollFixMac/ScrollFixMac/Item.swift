//
//  Item.swift
//  ScrollFixMac
//
//  Created by Freddie Farr on 06/12/2025.
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
