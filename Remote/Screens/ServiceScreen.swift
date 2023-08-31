//
//  ServiceScreen.swift
//  Remote
//
//  Created by El-Hoiydi, Felix on 30.08.23.
//


import SwiftUI

struct ServicesScreen: View {
    @EnvironmentObject var router : Router
    
    @EnvironmentObject var bluetoothManager : BluetoothManager
    var body: some View {
        VStack{
            if(bluetoothManager.services.count == 0){
                Text("no services")
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
        .navigationBarBackButtonHidden(true)
    }
}



struct ServicesScreen_Previews: PreviewProvider {
    static var previews: some View {
        ServicesScreen()
    }
}
