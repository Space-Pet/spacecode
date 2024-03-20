//
//  PackDetailsView.swift
//  Greer
//
//  Created by Mani Kandan on 1/31/24.
//

import SwiftUI
import SwiftData

struct EditPackView: View {
    @Environment(\.modelContext) var context
    @Query var gears: [Gear]
    @Environment(\.colorScheme) var colorScheme
    @State var pack: Pack
    @State private var showSelectGearForPackSheet = false
    @State private var multiGearSelection = Set<Gear>()
    @State private var gearBasket: [String: [Gear]] = ["Add": [], "Remove": []]
    @State var showMetadataDetails = false
    
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack {
            if (!pack.gearInPack.isEmpty) {
//                Button("print") {
//                    print("consumeable: \(pack.consumableWeight)")
//                    print("wearable: \(pack.wearableWeight)")
//                    print("remaining: \(pack.remainingWeight)")
//                }
                GearInPackListView
            } else
            {
                ContentUnavailableView {
                    Label("Such a lonely pack", systemImage: "circle.hexagongrid.circle")
                } description: {
                    Text("Give it some gear")
                } actions: {
                    Button("Add gear") {
                        withAnimation(.spring) {
                            showSelectGearForPackSheet.toggle()
                        }
                    }
                }
            }
        }
        .navigationTitle(pack.name)
        .toolbar {
            //            Menu {
            Button {
                withAnimation(.spring) {
                    showSelectGearForPackSheet.toggle()
                }
            } label: {
                Image(systemName: "plus.circle")
            }
            //            } label: {
            //                Image(systemName: "ellipsis.circle")
            //            }
        }
        .toolbarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSelectGearForPackSheet) {
            SelectGearForPackSheet
        }
        .onAppear {
            pack.updateWeights()
        }
    }
    
    var GearInPackListView: some View {
        ScrollView {
            CircleTest(consumableWeight: $pack.consumableWeight, wearableWeight: $pack.wearableWeight, remainingWeight: $pack.remainingWeight, weightUnit: pack.weightUnit, packWeight: pack.weight)
            
            LazyVStack(alignment: .leading, spacing: 1) {
                ForEach(pack.gearInPack) { gearInPack in
                    NavigationLink {
                        EditGearInPackView(pack: pack, gearInPack: gearInPack)
                    } label: {
                        GearInPackRow(gearInPack: gearInPack)
                    }
                }
                .onDelete(perform: { indexSet in
                    pack.gearInPack.remove(atOffsets: indexSet)
                    do {
                        try context.save()
                    } catch {
                        print("error while context saving after remove gear from pack.gearInPack")
                    }
                })
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
            
            MoreTripDetailsView
            
            MetadataView
        }
        .background(colorScheme == .dark ? .black:.defaultBg)
    }
    
    var MoreTripDetailsView: some View {
        VStack(alignment: .leading) {
            Text("Trip".capitalized)
                .font(.subheadline)
                .padding(.horizontal)
                .padding(.horizontal)
                .opacity(0.7)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.listrowbg)
                
                VStack(spacing: 6) {
                    DatePicker("Start", selection: $pack.startDate)
                        .datePickerStyle(.automatic)
                    
                    DatePicker("End", selection: $pack.endDate, in: pack.startDate...)
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
            .padding(.horizontal)
        }
    }
    
    var MetadataView: some View {
        return VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    withAnimation {
                        showMetadataDetails.toggle()
                    }
                }, label: {
                    HStack {
                        Text("Metadata".capitalized)
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(showMetadataDetails ? "Hide":"Show")
                    }
                    .font(.subheadline)
                    .padding(.leading, 32)
                    .opacity(0.7)
                })
                .font(.subheadline)
                .padding(.trailing, 32)
            }
            
            if(showMetadataDetails) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.listrowbg)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Created")
                                .fontWeight(.medium)
                            Text(pack.createdDate.formatted(date: .abbreviated, time: .complete))
                                .foregroundStyle(.gray.opacity(0.9))
                        }
                        
                        HStack {
                            Text("Gear count")
                                .fontWeight(.medium)
                            Text(pack.gearInPack.count.description)
                                .foregroundStyle(.gray.opacity(0.9))
                        }
                        
                        HStack {
                            Text("Weight")
                                .fontWeight(.medium)
                            Text(pack.weight.description)
                                .foregroundStyle(.gray.opacity(0.9))
                        }
                        
                        HStack {
                            Text("Weight unit")
                                .fontWeight(.medium)
                            Text(pack.weightUnit.rawValue + " (\(pack.weightUnit.abbreviation))")
                                .foregroundStyle(.gray.opacity(0.9))
                        }
                    }
                    .padding(.leading, -10)
                    .padding(.vertical)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    var SelectGearForPackSheet: some View {
        let onlyGearsNotInGearPack = gears.filter { gear in
            !pack.gearInPack.contains(where: { $0.gear.id == gear.id })
        }
        
        return NavigationStack {
            if (onlyGearsNotInGearPack.isEmpty) {
                ContentUnavailableView {
                    Label("How you got no gear?", systemImage: "plus.viewfinder")
                } description: {
                    Text("No gear has been saved that can be added")
                } actions: {
                    NavigationLink("Create new gear", destination: GearLockerView(showSelectGearForPackSheet: true, path: $path))
                }
            } else {
                List {
                    ForEach(onlyGearsNotInGearPack) { gear in
                        HStack(spacing: 18) {
                            // Check if the gear is in pack.gearInPack or gearBasket["Add"]
                            let gearInPackOrAddBasket = pack.gearInPack.contains(where: { $0.id == gear.id }) || gearBasket["Add"]?.contains(where: { $0.id == gear.id }) == true
                            
                            if gearInPackOrAddBasket {
                                Button {
                                    withAnimation {
                                        // if gear is in add, remove from add & then add to remove
                                        if let index = gearBasket["Add"]?.firstIndex(where: { $0.id == gear.id }) {
                                            gearBasket["Add"]?.remove(at: index)
                                        }
                                        gearBasket["Remove"]?.append(gear)
                                    }
                                    
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                            // If the gear is not in pack or gearBasket["Remove"], add it to the "Add" basket
                            else {
                                Button {
                                    withAnimation {
                                        gearBasket["Add"]?.append(gear)
                                    }
                                } label: {
                                    Image(systemName: "circle")
                                        .foregroundStyle(.gray)
                                        .opacity(0.5)
                                }
                            }
                            GearRow(gear: gear)
                        }
                    }
                    .deleteDisabled(true)
                }
                .listStyle(.grouped)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showSelectGearForPackSheet = false
                        } label: {
                            Text("Cancel")
                        }
                    }
                    
                    // FOR DEBUGGING
                    //                    ToolbarItem(placement: .topBarLeading) {
                    //                        Button {
                    //                            print("pack's gear: \(pack.gearInPack.count)")
                    //                            print("basket[add]: \(gearBasket["Add"]?.count.description)")
                    //                            print("onlyGearsNotInGearPack: \(onlyGearsNotInGearPack.count)")
                    //
                    //                            print(pack.gearInPack[0].id)
                    //                        } label: {
                    //                            Text("Print")
                    //                        }
                    //                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: {
                            CreateNewGearView()
                        }, label: {
                            Text("New")
                            .padding(.leading, 6)
                            .padding(.trailing, 4)
                        })
                        .foregroundStyle(.orange)
                        .background(.orange.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.orange)
                                .saturation(1.5)
                        )
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            addGearToPack()
                        }, label: {
                            Text("Add")
                                .padding(.leading, 4)
                                .padding(.trailing, 10)
                        })
                        .foregroundStyle(gearBasket["Add"]?.count == 0 ? .gray:.green)
                        .background(gearBasket["Add"]?.count == 0 ? .gray.opacity(0.4):.green.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(gearBasket["Add"]?.count == 0 ? .gray:.green)
                                .saturation(1.5)
                        )
                        .disabled(gearBasket["Add"]?.count == 0)
                    }
                }
            }
            
            if (gearBasket["Add"]?.count ?? 0 > 0) {
                HStack {
                    Text("\(gearBasket["Add"]?.count ?? 1) selected")
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .padding()
                .background(colorScheme == .dark ? .black : .white)
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
    
    func addGearToPack() {
        let animationDuration = 0.2
        let delayBetweenAnimations = 0.2
        
        if let gearsToAdd = gearBasket["Add"] {
            for gear in gearsToAdd {
                pack.gearInPack.append(GearInPack(gear: gear))
            }
            // After adding gears to the pack, clear the "Add" basket
            gearBasket["Add"]?.removeAll()
        }
        showSelectGearForPackSheet = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + delayBetweenAnimations) {
            withAnimation(.easeInOut(duration: animationDuration)) {
                pack.updateWeights()
            }
        }
    }
}

struct GearInPackRow: View {
    @Environment(\.colorScheme) var colorScheme
    @State var gearInPack: GearInPack
    
    var body: some View {
        HStack(alignment: .top) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(gearInPack.gear.type.typeColor.opacity(0.9))
                    .frame(width: 32, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(gearInPack.gear.type.typeColor)
                            .saturation(1.5)
                    )
                Image(systemName: gearInPack.gear.type.icon)
                    .foregroundStyle(Color.white)
                    .font(.footnote)
            }
            
            VStack(alignment: .leading) {
                Text(gearInPack.gear.brand + " " + gearInPack.gear.model)
                    .lineLimit(2)
                    .padding(.bottom)
                
                HStack(spacing: 6) {
                    Text(String(format: "%.2f", gearInPack.gear.weight) + " \(gearInPack.gear.weightUnit.abbreviation)")
                        .padding(6)
                        .background(.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.gray.opacity(colorScheme == .dark ? 0.4:0.6))
                                .saturation(1.5)
                        )
                    
                    Text(gearInPack.quantity.description+"x")
                        .padding(6)
                        .background(.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.gray.opacity(colorScheme == .dark ? 0.4:0.6))
                                .saturation(1.5)
                        )
                    
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(gearInPack.starred ? .yellow:.gray.opacity(0.3))
                    
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(gearInPack.gear.consumable ? .orange:.gray.opacity(0.3))
                    
                    Image(systemName: "tshirt.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(gearInPack.gear.worn ? .blue:.gray.opacity(0.3))
                }
                .font(Utils().monoFont)
            }
            .foregroundStyle(colorScheme == .dark ? .white:.black)
            
            Spacer()
            
            VStack(alignment: .center) {
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
                    .font(.system(size: 14))
                Spacer()
            }
        }
        .padding()
        .background(.listrowbg)
    }
}

//#Preview {
//    do {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try ModelContainer(for: Pack.self, configurations: config)
//        
//        let p1 = Pack(name: "Packest")
//        let g1 = Gear(brand: "Hyperlite", model: "Southwest 40", weight: 2.01, weightUnit: Gear.WeightUnit.pounds, type: Gear.GearType.backpack)
//        p1.gearInPack = [GearInPack(gear: g1, quantity: 1, starred: false)]
//        
//        return EditPackView(pack: p1)
//            .modelContainer(container)
//    } catch {
//        fatalError("Failed to make Packdetailsview container")
//    }
//}
