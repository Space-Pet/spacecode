//
//  GearInPack.swift
//  Greer
//
//  Created by Mani Kandan on 2/2/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class GearInPack {
    @Relationship(deleteRule: .cascade) var gear: Gear
    var quantity: Int = 1
    var starred: Bool = false
    
    init(gear: Gear, quantity: Int = 1, starred: Bool = false) {
        self.gear = gear
        self.quantity = quantity
        self.starred = starred
    }
    
    func starGearInPack() {
        withAnimation {
            starred.toggle()
        }
    }
}
