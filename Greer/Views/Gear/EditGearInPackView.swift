//
//  EditGearInPackView.swift
//  Greer
//
//  Created by Mani Kandan on 2/13/24.
//

import SwiftUI
import SwiftData

struct EditGearInPackView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    var pack: Pack
    @Query var gears: [Gear]
    @State var gearInPack: GearInPack
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            GearInPackFields
            
            GearInPackActionsView
            
            Spacer()
            
                .navigationTitle(gearInPack.gear.model)
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
    
    var GearInPackFields: some View {
        Form {
            Section("Required") {
                TextField("Brand", text: $gearInPack.gear.brand)
                
                TextField("Model", text: $gearInPack.gear.model)
                
                NavigationLink(destination: GearTypeSelectorView(gear: gearInPack.gear)) {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(gearInPack.gear.type.typeColor)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(lineWidth: 1)
                                        .foregroundStyle(gearInPack.gear.type.typeColor)
                                        .saturation(1.5)
                                )
                            
                            Image(systemName: gearInPack.gear.type.icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                        }
                        Text(gearInPack.gear.type.rawValue)
                    }
                }
                
                WeightField(gear: gearInPack.gear)
                
                QuantityField(quantity: $gearInPack.quantity)
            }
            
            Section("Optional") {
                HStack {
                    Spacer()
                    
                    // consumable toggle
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.orange)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(lineWidth: 1)
                                        .foregroundStyle(.orange)
                                        .saturation(1.5)
                                )
                            
                            Image(systemName: "fork.knife")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                        }
                        Text("Consumable")
                            .font(.caption2)
                            .opacity(0.5)
                    }
                    .frame(width: 68)
                    .padding()
                    .background(gearInPack.gear.consumable ? .orange.opacity(0.4) : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.orange.opacity(gearInPack.gear.consumable ? 0.7:0.2))
                            .saturation(2.5)
                    )
                    .onTapGesture {
                        withAnimation {
                            gearInPack.gear.consumable.toggle()
                        }
                    }
                    
                    Spacer()
                    
                    // worn toggle
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.blue)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(lineWidth: 1)
                                        .foregroundStyle(.blue)
                                        .saturation(1.5)
                                )
                            
                            Image(systemName: "tshirt.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                        }
                        Text("Worn")
                            .font(.caption2)
                            .opacity(0.5)
                    }
                    .frame(width: 68)
                    .padding()
                    .background(gearInPack.gear.worn ? .blue.opacity(0.4) : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.blue.opacity(gearInPack.gear.worn ? 0.7:0.2))
                            .saturation(2.5)
                    )
                    .onTapGesture {
                        withAnimation {
                            gearInPack.gear.worn.toggle()
                        }
                    }
                    Spacer()
                }
                
                HStack {
                    TextField("URL", text: $gearInPack.gear.url)
                    Button(action: {
                        openURL(URL(string: gearInPack.gear.url)!)
                    }, label: {
                        Image(systemName: "link")
                    })
                }
                
                TextField("Notes", text: $gearInPack.gear.desc)
            }
        }
    }
    
    var GearInPackActionsView: some View {
        HStack(spacing: 44) {
            Button(action: {
                deleteGearFromPack()
            }, label: {
                Text("Delete")
                Image(systemName: "trash")
            })
            .foregroundStyle(.red)
            .padding()
            .frame(width: 144)
            .background(.red.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(.red.opacity(0.2))
                    .saturation(2.5)
            )
            
            Button(action: {
                gearInPack.starGearInPack()
            }, label: {
                Text("Favorite")
                Image(systemName: gearInPack.starred ? "star.fill" : "star")
            })
            .foregroundStyle(.yellow)
            .padding()
            .frame(width: 144)
            .background(.yellow.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(.yellow.opacity(gearInPack.starred ? 0.7:0.2))
                    .saturation(2.5)
            )
        }
    }
    
    func deleteGearFromPack() {
        let animationDuration = 0.2
        let delayBetweenAnimations = 0.2
        
        if let index = pack.gearInPack.firstIndex(where: { $0.id == gearInPack.id }) {
            do {
                pack.gearInPack.remove(at: index)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + delayBetweenAnimations) {
                    withAnimation(.easeInOut(duration: animationDuration)) {
                        pack.updateWeights()
                    }
                }
                
                try context.save()
                dismiss()
            } catch {
                showAlert = true
                alertTitle = "Deleting Error"
                alertMessage = "Failed to delete gear from pack. Please try again."
            }
        }
    }
}


#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Gear.self, configurations: config)
        let p1 = Pack(name: "Packest")
        let g1 = GearInPack(gear: Gear(brand: "hyperlite", model: "southwest 4400", color: "#000000", weight: 10.0, url: "https://www.hyperlitemountaingear.com/products/southwest-40", type: .backpack))
        return EditGearInPackView(pack: p1, gearInPack: g1)
            .modelContainer(container)
    } catch {
        fatalError("Failed to make Packdetailsview container")
    }
}
