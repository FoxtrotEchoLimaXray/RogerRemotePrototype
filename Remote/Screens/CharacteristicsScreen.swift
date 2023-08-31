//
//  CharacteristicsScreen.swift
//  Remote
//
//  Created by El-Hoiydi, Felix on 30.08.23.
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
