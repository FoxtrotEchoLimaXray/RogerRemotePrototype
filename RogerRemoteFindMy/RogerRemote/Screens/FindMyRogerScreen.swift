//
//  FindMyRogerScreen.swift
//  RogerRemote
//
//  Created by El-Hoiydi, Felix on 12.09.23.
//

import SwiftUI

struct FindMyRogerScreen: View {
    @EnvironmentObject var bluetoothManager : BluetoothManager
    @EnvironmentObject var router : Router
    
    var body: some View {
        VStack {
            HStack{
                Text("rssi\n\(bluetoothManager.rssi)")
                Text("rssiAverage\n\(bluetoothManager.rssiAverage)")
                Text("distance\n\(bluetoothManager.distance == nil ? 0:bluetoothManager.distance!)")
            }
            .padding(.horizontal)
            Spacer()
            if let dist = bluetoothManager.distance{
                if (dist < 2){
                    Text("\(String(Double(round(dist * 10) / 10))) m")
                        .font(.title)
                        .fontWeight(.bold)

                }else{
                    Text("\(String(Int(dist))) m")
                        .font(.title)
                        .fontWeight(.bold)
                }
                ProgressView(value: dist,total: 15)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(UIColor(red:  (0.5*(1+tanh((dist - 7)/2))), //sigmoid
                                                                                   green:  (1-0.5 * (1+tanh((dist - 7)/2))),
                                                                                   blue: 0, alpha: 1))))
                    .scaleEffect(x:1,y:5)
            }
            
            
                
           
            Spacer()
            HStack{
                Button(action:{
                    router.navigate(to: .services)
                    bluetoothManager.distance = nil
                }){
                    Text("back")
                    
                }
                Spacer()
                Button(action:{
                    bluetoothManager.startFindMy()
                }){
                    Text("startFindMy")
                }.buttonStyle(.borderedProminent)
                Button(action:{
                    bluetoothManager.stopFindMy()
                }){
                    Text("stopFindMy")
                }.buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            
        }
        .padding()
        .navigationBarBackButtonHidden()
    }
}

struct FindMyRogerScreen_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var bluetoothManager = BluetoothManager()
        @StateObject var router = Router()
        FindMyRogerScreen()
            .environmentObject(bluetoothManager)
            .environmentObject(router)
    }
}



