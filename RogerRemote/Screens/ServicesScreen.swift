//
//  ServicesScreen.swift
//  RogerRemote
//
//  Created by El-Hoiydi, Felix on 08.09.23.
//

import SwiftUI

struct ServicesScreen: View {
    @EnvironmentObject var bluetoothManager : BluetoothManager
    @EnvironmentObject var router : Router
    
    var body: some View {
        VStack{
            if(bluetoothManager.services.count == 0){
                Spacer()
                Text("no services")
                    .font(.title)
                Spacer()
            }else{
                List(bluetoothManager.services){service in
                    Button(action:{
                        bluetoothManager.discoverCharacteristics(service: service)
                        router.navigate(to: .characteristics)
                    }){
                        Text(service.description)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            HStack{
                Spacer()
                Button(action:{bluetoothManager.disconnect()}){
                    Text("Disconnect")
                }.buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .navigationBarBackButtonHidden()
    }
}

struct ServicesScreen_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var bluetoothManager = BluetoothManager()
        ServicesScreen()
            .environmentObject(bluetoothManager)
            
       
    }
}


