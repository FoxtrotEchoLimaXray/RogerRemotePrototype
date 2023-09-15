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
                Button(action:{router.navigate(to: .findmyroger)}){
                    Text("FindMyRoger")
                }.buttonStyle(.borderedProminent)
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
        @StateObject var router = Router()
        ServicesScreen()
            .environmentObject(bluetoothManager)
            .environmentObject(router)
        
        
    }
}


