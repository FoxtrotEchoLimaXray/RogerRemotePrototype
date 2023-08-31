//
//  ScanningScreen.swift
//  Remote
//
//  Created by El-Hoiydi, Felix on 30.08.23.
//

import SwiftUI
import CoreBluetooth

struct ScanningScreen: View {
    @EnvironmentObject var router : Router
    @EnvironmentObject var bluetoothManager : BluetoothManager
    
    @State var scanning = true
    
    var body: some View {
        VStack {
            Text("Filtering uuid: 5a791800-0d19-4fd9-87f9-e934aedbce59")
            Spacer()
            if scanning{
                VStack{
                    Text("Scanning")
                    Spacer()
                        .frame(height: 20)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint:.black))
                        .scaleEffect(1.5)
                }
            }
           
            Spacer()
            Button(action:{
                if(scanning){
                    bluetoothManager.stopScan()
                }else{
                    bluetoothManager.startScan()
                }
                scanning.toggle()
            }){
                if scanning{
                    Text("Stop Scanning")
                }else{
                    Text("Start Scanning")
                }
            }.buttonStyle(.borderedProminent)
        }
        .padding()
    }
}


struct ScanningScreen_Previews: PreviewProvider {
    static var previews: some View {
        ScanningScreen()
    }
}
