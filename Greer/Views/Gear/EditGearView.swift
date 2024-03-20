//
//  EditGearView.swift
//  Greer
//
//  Created by Mani Kandan on 2/5/24.
//

import SwiftUI
import SwiftData
import PopupView

struct EditGearView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @Query var gears: [Gear]
    @State var gear = Gear()
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @Binding var showToast: Bool
    
    @Query var packs: [Pack]
    
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
            GearFields(gear: gear)
            
            EditGearActionsView
            
                .navigationTitle(gear.model)
                .navigationBarTitleDisplayMode(.inline)
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Button("Back") {
                        dismiss()
                    }
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    var EditGearActionsView: some View {
        HStack(spacing: 44) {
            Button(action: {
                deleteGear()
            }, label: {
                Text("Delete")
                Image(systemName: "trash")
            })
            .foregroundStyle(.red)
            .padding()
            .frame(width: 144)
            .background(.red.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Button("3") {
                showToast.toggle()
            }
        }
    }
    
    func deleteGear() {
        //        print("deleting gear id: \(gear.id), name: \(gear.brand), model: \(gear.model)")
        
        // remove specific gear from pack.gearInPack for a clean delete
        for pack in packs {
            
            // Check if the pack contains the gear to be deleted
            if let index = pack.gearInPack.firstIndex(where: { $0.gear.id == gear.id }) {
                //                print("packName: \(pack.name), index: \(index.description)")
                
                do {
                    pack.gearInPack.remove(at: index)
                    try context.save()
                } catch {
                    print("error while context saving after remove gear from occurences in pack.gearInPack")
                }
            }
        }
        
        // now delete gear from gears[]
        if let index = gears.firstIndex(where: { $0.id == gear.id }) {
            do {
                // go to previous screen (gear locker)
                dismiss()
                
                //                print("gears[] index: \(index)")
                context.delete(gears[index])
                
                // show toast that gear was deleted
                showToast.toggle()
                
                try context.save()
            } catch {
                print("error while context saving after remove gear from pack.gearInPack")
            }
        }
    }
}

struct WeightField: View {
    @State var gear = Gear()
    
    var body: some View {
        HStack {
            TextField("Weight", text: Binding(
                get: {
                    String(format: "%.2f", gear.weight)
                },
                set: { newValue in
                    
                    let animationDuration = 0.2
                    let delayBetweenAnimations = 0.2
                    DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + delayBetweenAnimations) {
                        withAnimation(.easeInOut(duration: animationDuration)) {
                            if let value = Double(newValue) {
                                gear.weight = value
                            }
                        }
                    }
                    
                }))
            .keyboardType(.decimalPad)
            
            Picker("", selection: $gear.weightUnit) {
                ForEach(Gear.WeightUnit.allCases, id: \.self) { unit in
                    if unit == gear.weightUnit {
                        Text(unit.abbreviation)
                    } else {
                        Text("\(unit.rawValue) (\(unit.abbreviation))")
                    }
                }
            }
            .pickerStyle(.menu)
            .onChange(of: gear.weightUnit) { oldValue, newValue in
                let convertedWeight = gear.convertWeight(currentUnit: oldValue, desiredUnit: newValue, currentWeight: gear.weight)
                withAnimation(.easeInOut) {
                    gear.weight = convertedWeight
                    gear.weightUnit = newValue
                }
            }
        }
    }
}

struct QuantityField: View {
    @Binding var quantity: Int
    
    var body: some View {
        HStack {
            Text("\(quantity)")
            
            Spacer()
            
            Button(action: {
                quantity += 1
            }) {
                Image(systemName: "plus.circle")
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                if quantity > 0 {
                    quantity -= 1
                }
            }) {
                Image(systemName: "minus.circle")
                    .foregroundStyle(Color.accentColor)
            }
            .disabled(quantity <= 0)
            .buttonStyle(.plain)
        }
    }
}


/// WIP
//struct AppearsInThesePacks: View {
//}


struct GearFields: View {
    @State var gear = Gear()
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Form {
            Section("Required") {
                TextField("Brand", text: $gear.brand)
                
                TextField("Model", text: $gear.model)
                
                NavigationLink(destination: GearTypeSelectorView(gear: gear)) {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(gear.type.typeColor)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(lineWidth: 1)
                                        .foregroundStyle(gear.type.typeColor)
                                        .saturation(1.5)
                                )
                            
                            Image(systemName: gear.type.icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                        }
                        Text(gear.type.rawValue)
                    }
                }
                
                WeightField(gear: gear)
            }
            Section("Optional") {
                HStack {
                    TextField("URL", text: $gear.url)
                    Button(action: {
                        openURL(URL(string: gear.url)!)
                    }, label: {
                        Image(systemName: "link")
                    })
                }
                
                TextField("Notes", text: $gear.desc)
            }
        }
    }
}

//#Preview {
//    do {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try ModelContainer(for: Gear.self, configurations: config)
//        
//        let g1 = Gear(brand: "hyperlite", model: "southwest 4400", color: "#000000", weight: 10.0, url: "https://www.hyperlitemountaingear.com/products/southwest-40", type: .backpack)
//        return EditGearView(gear: g1, showToast: .constant(false))
//            .modelContainer(container)
//    } catch {
//        fatalError("Failed to make Packdetailsview container")
//    }
//}
