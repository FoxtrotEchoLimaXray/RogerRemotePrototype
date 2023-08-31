//
//  SingleCharacteristicScreen.swift
//  Remote
//
//  Created by El-Hoiydi, Felix on 30.08.23.
//


import SwiftUI
import CoreBluetooth

struct SingleCharacteristicScreen: View {
    @ObservedObject var bluetoothManager : BluetoothManager
    @State private var inputvalue: String = "example"

    var characteristic : CBCharacteristic
    
    var body: some View {
        VStack {
                Text("uuid : \(characteristic.uuid.uuidString)")
            if(characteristic.isNotifying){
                Text("isNotifying : true")
            }else{
                Text("isNotifying : false")
            }
            Spacer()
                Text("values: \(bluetoothManager.readValues)")
           
            Spacer()
              
    
            HStack{
                Button(action:{bluetoothManager.readValue(characteristic: characteristic)}){
                    Text("read")
                }
                Button(action:{bluetoothManager.writeRequest(value: inputvalue.data(using: .utf8)!, characteristic: characteristic)}){
                    Text("write")
                }
                Spacer()
                Button(action:{bluetoothManager.subscribeToNotification(characteristic: characteristic)}){
                    Text("subscribe")
                }
                Spacer()
                Button(action:{bluetoothManager.unsubscribeToNotification(characteristic: characteristic)}){
                    Text("unsubscribe")
                }
            }
            TextField("Enter data", text: $inputvalue)
                .textFieldStyle(.roundedBorder)
            
        }.padding()
    }
}



