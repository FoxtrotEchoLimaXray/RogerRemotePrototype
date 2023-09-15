//
//  CharacteristicsScreen.swift
//  RogerRemote
//
//  Created by El-Hoiydi, Felix on 08.09.23.
//

import SwiftUI
import CoreBluetooth


struct CharacteristicsScreen: View {
    @EnvironmentObject var router : Router
    @EnvironmentObject var bluetoothManager : BluetoothManager
    
    @State var singleCharIsActive = false
    var body: some View {
        VStack {
                List(bluetoothManager.characteristics){characteristic in
                    NavigationLink(destination: SingleCharacteristicScreen(bluetoothManager: bluetoothManager,characteristic: characteristic)){
                        Text(characteristic.description)
                    }
                }.scrollContentBackground(.hidden)
        }
        .padding()
    }
}

struct CharacteristicsScreen_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var bluetoothManager = BluetoothManager()
        @StateObject var router = Router()
        ServicesScreen()
            .environmentObject(bluetoothManager)
            .environmentObject(router)
           
       
    }
}


