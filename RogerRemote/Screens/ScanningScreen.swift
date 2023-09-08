//
//  ScanningScreen.swift
//  RogerRemote
//
//  Created by El-Hoiydi, Felix on 08.09.23.
//

import SwiftUI

struct ScanningScreen: View {
    @EnvironmentObject var bluetoothManager : BluetoothManager
    
    var body: some View {
        VStack {
            Text("Filtering uuid: 5a791800-0d19-4fd9-87f9-e934aedbce59")
            Spacer()
            if (bluetoothManager.isScanning){
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint:.black))
                    .scaleEffect(1.5)
            }
            
            Spacer()
            VStack{
                if (bluetoothManager.isScanning){
                    Button(action: {bluetoothManager.stopScan()}){
                        Text("Stop Scan")
                    }.buttonStyle(.borderedProminent)
                }else{
                    Button(action: {bluetoothManager.startScan()}){
                        Text("Start Scan")
                    }.buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
    }
}


struct ScanningScreen_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var bluetoothManager = BluetoothManager()
        ScanningScreen()
            .environmentObject(bluetoothManager)
    }
}

