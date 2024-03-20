//
//  SettingsView.swift
//  Greer
//
//  Created by Mani Kandan on 3/5/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.openURL) var openURL
    
    @AppStorage("defaultPackWeightUnit") var defaultPackWeightUnit: Gear.WeightUnit = .pounds
    @AppStorage("defaultGearWeightUnit") var defaultGearWeightUnit: Gear.WeightUnit = .ounces
    @AppStorage("defaultGearWeightUnit") var iCloudSync: Bool = true
    
    var body: some View {
//        NavigationStack {
            List {
                NavigationLink("Test page") {
                    NavigationStack {
                        Text("Helllooo")
                    }
                }
                
                Section {
                    Picker(selection: $defaultPackWeightUnit) {
                        ForEach(Gear.WeightUnit.allCases, id: \.self) { unit in
                            if unit == defaultPackWeightUnit {
                                Text(unit.abbreviation)
                            } else {
                                Text("\(unit.rawValue) (\(unit.abbreviation))")
                            }
                        }
                    } label: {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.red)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(lineWidth: 1)
                                            .foregroundStyle(.red)
                                            .saturation(1.5)
                                    )
                                
                                Image(systemName: "backpack.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                                    .frame(width: 16, height: 16)
                            }
                            
                            Text("Pack weight unit")
                        }
                    }
                    
                    Picker(selection: $defaultGearWeightUnit) {
                        ForEach(Gear.WeightUnit.allCases, id: \.self) { unit in
                            if unit == defaultGearWeightUnit {
                                Text(unit.abbreviation)
                            } else {
                                Text("\(unit.rawValue) (\(unit.abbreviation))")
                            }
                        }
                    } label: {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.mint)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(lineWidth: 1)
                                            .foregroundStyle(.mint)
                                            .saturation(1.5)
                                    )
                                
                                Image(systemName: "circle.hexagongrid.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                                    .frame(width: 16, height: 16)
                            }
                            
                            Text("Gear weight unit")
                        }
                    }
                } header: {
                    Text("Default unit for NEW packs & gear")
                } footer: {
                    Text("Does not convert units for existing packs or gear")
                }
                
                Section {
                    Toggle(isOn: $iCloudSync, label: {
                        HStack {
                            ZStack {
                                Image(systemName: "icloud.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.iCloudBlue)
                                    .frame(width: 16, height: 16)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.gray.opacity(0.08))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(lineWidth: 1)
                                            .foregroundStyle(.gray.opacity(0.08))
                                            .saturation(1.5)
                                    )
                            }
                            
                            Text("iCloud Sync")
                        }
                    })
                    .disabled(true)
                } footer: {
                    Text("In the future, you can turn this off")
                }

            }
            
            Spacer()
            
            VStack {
                HStack(alignment: .bottom, spacing: 0) {
                    Text("Made by ")
                    Text("Mani")
                        .foregroundStyle(Color.accentColor)
                        .onTapGesture {
                            openURL(URL(string: "https://x.com/man1_kandan")!)
                        }
                }
                .opacity(0.6)
                .font(.subheadline)
                
                HStack(alignment: .bottom, spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.stone)
                        .frame(width: 16, height: 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.stone)
                                .saturation(1.5)
                        )
                    Text("shadyforge")
                        .foregroundStyle(.stone)
                        .onTapGesture {
                            openURL(URL(string: "https://shadyforge.com")!)
                        }
                }
                .font(.subheadline)
            }
            .padding(.vertical, 30)
            .navigationTitle("Settings")
//        }
    }
}

#Preview {
    SettingsView()
}
