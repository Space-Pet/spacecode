//
//  SettingsManager.swift
//  Greer
//
//  Created by Mani Kandan on 3/6/24.
//

import SwiftUI

struct SettingsManager {
    static let shared = SettingsManager()
    
    @AppStorage("defaultPackWeightUnit") var defaultPackWeightUnit: Gear.WeightUnit = .pounds
    @AppStorage("defaultGearWeightUnit") var defaultGearWeightUnit: Gear.WeightUnit = .ounces
    @AppStorage("defaultGearWeightUnit") var iCloudSync: Bool = true
}
