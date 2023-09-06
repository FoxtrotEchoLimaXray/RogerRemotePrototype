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
    @State private var inputvalue: String = "31"

    var characteristic : CBCharacteristic
    
    var body: some View {
        
        VStack {
            HStack{
                VStack(alignment: .leading){
                    HStack{
                        if( characteristic.properties.contains(CBCharacteristicProperties.write)){
                            Text("write")
                        }else if(characteristic.properties.contains(CBCharacteristicProperties.authenticatedSignedWrites)){
                            Text("authenticatedSignedWrites")
                        }else if(characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse)){
                            Text("writeWithoutResponse")
                        }else{
                            Text("not writeable")
                        }
                        if( characteristic.properties.contains(CBCharacteristicProperties.notify)){
                            Text("notifiable")
                        }else {
                            Text("not notifiable")
                        }
                    }
                    Divider()
                    
                    Text("uuid : \(characteristic.uuid.uuidString)")
                    Spacer()
                        .frame(height: 10)
                    if(characteristic.isNotifying){
                        Text("isNotifying : true")
                    }else{
                        Text("isNotifying : false")
                    }
                    Divider()
                    Spacer()
                        .frame(height: 20)
                   
                        Text("values: \(bluetoothManager.readValues)")
                }
                Spacer()
            }
            
           
            Spacer()

            HStack{
                Menu("actions"){
                    Button(action:{bluetoothManager.writeRequest(messageString:inputvalue, characteristic: characteristic)}){
                        Text("writeRequest")
                    }
                    
                    Button(action:{bluetoothManager.writeCommmand(messageString:inputvalue, characteristic: characteristic)}){
                        Text("writeCommmand")
                    }
                    
                    Button(action:{bluetoothManager.subscribeToNotification(characteristic: characteristic)}){
                        Text("subscribe")
                    }
                    
                    Button(action:{bluetoothManager.unsubscribeToNotification(characteristic: characteristic)}){
                        Text("unsubscribe")
                    }
                    
                    Button(action:{bluetoothManager.readValue(characteristic: characteristic)}){
                        Text("read")
                    }
                }.buttonStyle(.borderedProminent)
            }
            TextField("Enter data", text: $inputvalue)
                .textFieldStyle(.roundedBorder)
            
        }.padding()
    }
}



