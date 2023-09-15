//
//  ContentView.swift
//  FindMyRoger
//
//  Created by El-Hoiydi, Felix on 13.09.23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var bluetoothManager = BluetoothManager()
    @State var searching = false
    
    var body: some View {
        VStack {
            List(bluetoothManager.knownPeripherals){peripheralWrapper in
                PeripheralCardView(peripheralWrapper:peripheralWrapper)
            }
            
            if(searching){
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.black))
            }
            Spacer()
                .frame(height: 20)
            DisclosureGroup("options"){
                VStack{
                    HStack{
                        Button(action: {bluetoothManager.startFindMy()
                            searching = true}){
                                Text("FindMyRoger")
                                
                            }.buttonStyle(.borderedProminent)
                        
                        Button(action: {bluetoothManager.stopFindMy()
                            searching = false}){
                                Text("Stop")
                            }.buttonStyle(.borderedProminent)
                        Button(action: {bluetoothManager.knownPeripherals = []}){
                                Image(systemName: "trash")
                            }.buttonStyle(.borderedProminent)
                    }
                    
                    Toggle(isOn: $bluetoothManager.averaging){
                        Text("Averaging").font(.title3)
                    }
                    Toggle(isOn: $bluetoothManager.searchForNewDevices){
                        Text("Search new Devices").font(.title3)
                    }
                    Toggle(isOn: $bluetoothManager.filterForHearingAids){
                        Text("Search for Hearing Aids to").font(.title3)
                    }
                }
                .padding()
            }
        }
        .padding()
    }
    
}

struct PeripheralCardView: View {
    let peripheralWrapper : PeripheralWrapper // no need for binding since we dont change the value in this view
    var body: some View {
        VStack(alignment: .leading){
            
            InfoView(peripheralWrapper: peripheralWrapper)
            Spacer()
                .frame(height:20)
            DistBarView(peripheralWrapper: peripheralWrapper)
            Spacer()
                .frame(height:20)
            RSSICapsulesView(peripheralWrapper: peripheralWrapper)
            Text(String(format : "%.1f",
                        peripheralWrapper.minDistance) + "-" + String(format : "%.1f",peripheralWrapper.maxDistance)+"m")
            .font(.title2)
        }
    }
}

struct InfoView: View {
    let peripheralWrapper : PeripheralWrapper
    var body: some View {
        DisclosureGroup("\(peripheralWrapper.name)"){
            Text("identifier \(peripheralWrapper.id)")
            Text("rssi \(peripheralWrapper.rssi)")
            Text("txpower \(peripheralWrapper.txpower)")
            Text("rssiAverage \(peripheralWrapper.rssiAverage)")
            Text("distance \(peripheralWrapper.distance)")
            Text("trendingslope \(peripheralWrapper.trendingslope)")
            
            if(peripheralWrapper.trendingslope > 0.002 ){
                Text("you are doing good")
            }else if(peripheralWrapper.trendingslope < -0.002 ){
                Text("not good")
            }else{
                Text("idle")
            }
            
        }
        
    }
}

struct DistBarView: View {
    let peripheralWrapper : PeripheralWrapper
    var body: some View {
        ProgressView(value:min(15,peripheralWrapper.distance),total: 15 )
            .progressViewStyle(LinearProgressViewStyle(tint: Color(UIColor(red:  (0.5*(1+tanh((peripheralWrapper.distance - 7)/2))),
                                                                           green:  (1-0.5 * (1+tanh((peripheralWrapper.distance - 7)/2))),
                                                                           blue: 0, alpha: 1))))
            .scaleEffect(x:1,y:4)
    }
}


struct RSSICapsulesView: View {
    let peripheralWrapper : PeripheralWrapper
    var body: some View {
        HStack{
            if(peripheralWrapper.rssiAverage < -90){
                Capsule()
                    .fill(Color(UIColor(red: 1,
                                        green:  0,
                                        blue: 0, alpha: 1)))
                    .frame(width: 50, height: 15)
            }
            if(peripheralWrapper.rssiAverage > -90){
                Capsule()
                    .fill(Color(UIColor(red: 0.8,
                                        green:  0.2,
                                        blue: 0, alpha: 1)))
                    .frame(width: 50, height: 15)
            }
            if (peripheralWrapper.rssiAverage > -80){
                Capsule()
                    .fill(Color(UIColor(red: 0.6,
                                        green:  0.4,
                                        blue: 0, alpha: 1)))
                    .frame(width: 50, height: 15)
            }
            if (peripheralWrapper.rssiAverage > -70){
                Capsule()
                    .fill(Color(UIColor(red: 0.4,
                                        green:  0.6,
                                        blue: 0, alpha: 1)))
                    .frame(width: 50, height: 15)
            }
            if (peripheralWrapper.rssiAverage > -60){
                Capsule()
                    .fill(Color(UIColor(red: 0.2,
                                        green:  0.8,
                                        blue: 0, alpha: 1)))
                    .frame(width: 50, height: 15)
            }
            if (peripheralWrapper.rssiAverage > -50){
                Capsule()
                    .fill(Color(UIColor(red: 0,
                                        green:  1,
                                        blue: 0, alpha: 1)))
                    .frame(width: 50, height: 15)
            }
        }
    }
}

let sampleperipheralWrapper = PeripheralWrapper(id:UUID(),txpower: 0,name: "Roger In On")
struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            List{
                PeripheralCardView(peripheralWrapper:sampleperipheralWrapper)
                PeripheralCardView(peripheralWrapper:sampleperipheralWrapper)
            }
        }
    }
}
