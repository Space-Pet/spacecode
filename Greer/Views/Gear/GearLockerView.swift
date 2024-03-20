//
//  GearLockerView.swift
//  Greer
//
//  Created by Mani Kandan on 2/2/24.
//

import SwiftUI
import SwiftData
import PopupView

struct GearLockerView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @Query var gears: [Gear]
    @Query var packs: [Pack]
    
    @State var showSelectGearForPackSheet = false
    @State var newGear = Gear()
    
    @State var showToast = false
    @State var toastTitle = ""
    @State var toastIcon = ""
    @State var toastColor: Color = .red
    
    @Binding var path: NavigationPath
    
    var requiredFields: Bool {
        !newGear.brand.isEmpty && !newGear.model.isEmpty && !newGear.type.rawValue.isEmpty
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if (gears.isEmpty) {
                    ContentUnavailableView {
                        Label("Mo gear, mo problems", systemImage: "circle.hexagongrid.circle")
                    } description: {
                        Text("Throw in the essentials you gram weenie")
                    } actions: {
                        Button("Add gear") {
                            showSelectGearForPackSheet.toggle()
                        }
                    }
                } else {
                    GearListView
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showSelectGearForPackSheet.toggle()
                    }, label: {
                        Image(systemName: "plus.circle")
                    })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Add samples") {
                            withAnimation(.spring) {
                                addSampleGears()
                            }
                        }
                        
                        EditButton()
                    } label: {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                    }
                }
            }
            .sheet(isPresented: $showSelectGearForPackSheet, content: {
                CreateNewGearView()
            })
            .navigationTitle("Gear (\(gears.count.description))")
            .popup(isPresented: $showToast) {
                popup
            } customize: {
                $0
                    .type(.floater())
                    .position(.bottom)
                    .appearFrom(.bottom)
                    .animation(.interpolatingSpring)
                    .autohideIn(2)
            }
        }
    }
    
    var GearListView: some View {
        List {
            ForEach(gears) { gear in
                VStack {
                    NavigationLink {
                        EditGearView(gear: gear, showToast: $showToast, path: $path)
                        
                    } label: {
                        GearRow(gear: gear)
                    }
                }
            }
            .onDelete(perform: { indexSet in
                deleteGear(indexSet: indexSet)
            })
        }
    }
    
    var popup: some View {
        HStack {
            Image(systemName: toastIcon)
                .resizable()
                .foregroundStyle(toastColor.opacity(0.7))
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
            Text(toastTitle)
                .font(.subheadline)
                .bold()
        }
        .foregroundStyle(.secondary)
        .frame(width: 200, height: 60)
        .background(toastColor.opacity(0.05))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    func addSampleGears() {
        let g1 = Gear(brand: "Hyperlite", model: "Southwest 2400", weight: 33.2, weightUnit: .ounces, desc: "Lightweight backpack with ample storage space for multi-day trips.", url: "https://example.com/hyperlite-southwest-2400", worn: false, consumable: false, type: .backpack)
        let g2 = Gear(brand: "Patagonia", model: "R1 Pullover", weight: 12.4, weightUnit: .ounces, desc: "Midweight fleece pullover suitable for layering in various weather conditions.", url: "https://example.com/patagonia-r1-pullover", worn: true, consumable: false, type: .clothing)
        let g3 = Gear(brand: "Nemo", model: "Hornet 2P", weight: 56.3, weightUnit: .ounces, desc: "Spacious tent designed for two people, with easy setup and durable materials.", url: "https://example.com/nemo-hornet-2p", worn: false, consumable: false, type: .tent)
        let g4 = Gear(brand: "Therm-a-Rest", model: "NeoAir XLite", weight: 15.8, weightUnit: .ounces, desc: "Ultralight sleeping pad with excellent insulation for cold nights.", url: "https://example.com/thermarest-neoair-xlite", worn: true, consumable: false, type: .sleep)
        let g5 = Gear(brand: "Garmin", model: "inReach Mini", weight: 7.5, weightUnit: .ounces, desc: "Compact satellite communicator for sending and receiving messages in remote areas.", url: "https://example.com/garmin-inreach-mini", worn: false, consumable: false, type: .electronic)
        let g6 = Gear(brand: "MSR", model: "PocketRocket 2", weight: 2.6, weightUnit: .ounces, desc: "Portable and efficient backpacking stove for cooking meals on the trail.", url: "https://example.com/msr-pocketrocket-2", worn: true, consumable: false, type: .cooking)
        let g7 = Gear(brand: "Swiss", model: "Army Knife", weight: 0.7, weightUnit: .ounces, desc: "Multi tool for survival", url: "https://example.com/swiss-army-knife", worn: false, consumable: false, type: .safety)
        let g8 = Gear(brand: "Platypus", model: "GravityWorks Water Filter", weight: 11.8, weightUnit: .ounces, desc: "High-capacity water filtration system for purifying water from natural sources while camping or backpacking.", url: "https://example.com/platypus-gravityworks-water-filter", worn: false, consumable: false, type: .water)
        let g9 = Gear(brand: "Black Diamond", model: "Spot Headlamp", weight: 3.2, weightUnit: .ounces, desc: "Compact and versatile headlamp with adjustable brightness levels, ideal for nighttime activities.", url: "https://example.com/black-diamond-spot-headlamp", worn: true, consumable: false, type: .lighting)
        let g10 = Gear(brand: "Petzl", model: "Grigri+", weight: 8.9, weightUnit: .ounces, desc: "Assisted braking belay device for rock climbing, providing added safety during descents.", url: "https://example.com/petzl-grigri-plus", worn: false, consumable: false, type: .climbing)
        let g11 = Gear(brand: "Salomon", model: "X Ultra 3 GTX", weight: 16.4, weightUnit: .ounces, desc: "Waterproof hiking shoes with excellent traction and support for long-distance hikes.", url: "https://example.com/salomon-x-ultra-3-gtx", worn: true, consumable: false, type: .footwear)
        let g12 = Gear(brand: "Leatherman", model: "Wave+", weight: 8.6, weightUnit: .ounces, desc: "Versatile multitool with a variety of useful functions, including pliers, knives, and screwdrivers.", url: "https://example.com/leatherman-wave-plus", worn: false, consumable: false, type: .tools)
        let g13 = Gear(brand: "Sea to Summit", model: "Pocket Trowel", weight: 3.1, weightUnit: .ounces, desc: "Compact and lightweight trowel for digging cat holes while camping.", url: "https://example.com/sea-to-summit-pocket-trowel", worn: false, consumable: false, type: .hygiene)
        let g14 = Gear(brand: "GSI Outdoors", model: "Infinity Backpacker Mug", weight: 2.0, weightUnit: .ounces, desc: "Durable and lightweight mug for enjoying hot beverages while on the trail.", url: "https://example.com/gsi-outdoors-infinity-backpacker-mug", worn: false, consumable: true, type: .fun)
        
        context.insert(g1)
        context.insert(g2)
        context.insert(g3)
        context.insert(g4)
        context.insert(g5)
        context.insert(g6)
        context.insert(g7)
        context.insert(g8)
        context.insert(g9)
        context.insert(g10)
        context.insert(g11)
        context.insert(g12)
        context.insert(g13)
        context.insert(g14)
        
        do {
            try context.save()
        } catch {
            print("error while context saving after adding sample gears to gearlockerview")
        }
    }
    
    func deleteGear(indexSet: IndexSet) {
        //                print("deleting gear id: \(gears[indexSet.first ?? 0].id), name: \(gears[indexSet.first ?? 0].brand), model: \(gears[indexSet.first ?? 0].model)")
        
        // remove specific gear from pack.gearInPack for a clean delete
        for pack in packs {
            
            // Check if the pack contains the gear to be deleted
            if let index = pack.gearInPack.firstIndex(where: { $0.gear.id == gears[indexSet.first ?? 0].id }) {
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
        if let index = gears.firstIndex(where: { $0.id == gears[indexSet.first ?? 0].id }) {
            do {
                // go to previous screen (gear locker)
                dismiss()
                
                //                print("gears[] index: \(index)")
                context.delete(gears[index])
                
                // show toast that gear was deleted
                callToast(title: "Deleted gear", icon: "trash", color: .red)
                
                try context.save()
            } catch {
                print("error while context saving after remove gear from pack.gearInPack")
            }
        }
    }
    
    func callToast(title: String, icon: String, color: Color) {
        toastTitle = title
        toastIcon = icon
        toastColor = color
        showToast.toggle()
    }
}

/// Note: can also use `.fill(Color(hex: gear.color))`
struct GearRow: View {
    @Environment(\.colorScheme) var colorScheme
    @State var gear: Gear
    
    var body: some View {
        HStack(alignment: .top) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(gear.type.typeColor.opacity(0.9))
                    .frame(width: 32, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(gear.type.typeColor)
                            .saturation(1.5)
                    )
                Image(systemName: gear.type.icon)
                    .foregroundStyle(Color.white)
                    .font(.footnote)
            }
            
            VStack(alignment: .leading) {
                Text(gear.brand + " " + gear.model)
                    .lineLimit(2)
                    .padding(.bottom)
                
                HStack(spacing: 6) {
                    Text(String(format: "%.2f", gear.weight) + " \(gear.weightUnit.abbreviation)")
                        .padding(6)
                        .background(.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.gray.opacity(colorScheme == .dark ? 0.4:0.6))
                                .saturation(1.5)
                        )
                    
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(gear.consumable ? .orange:.gray.opacity(0.3))
                    
                    Image(systemName: "tshirt.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(gear.worn ? .blue:.gray.opacity(0.3))
                }
                .font(Utils().monoFont)
            }
            .foregroundStyle(colorScheme == .dark ? .white:.black)
        }
    }
}

//#Preview {
//    //    GearLockerView()
//    //        .modelContainer(for: Gear.self)
//    do {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try ModelContainer(for: Gear.self, configurations: config)
//        
//        //        let g1 = Gear(brand: "hyperlite", model: "southwest 4400", color: "#000000", weight: 10.0, url: "https://www.hyperlitemountaingear.com/products/southwest-40", type: .backpack)
//        return GearLockerView()
//            .modelContainer(container)
//    } catch {
//        fatalError("Failed to make Packdetailsview container")
//    }
//}
