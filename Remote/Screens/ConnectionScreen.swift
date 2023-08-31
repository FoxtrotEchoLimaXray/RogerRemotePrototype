//
//  ConnectionScreen.swift
//  Remote
//
//  Created by El-Hoiydi, Felix on 30.08.23.
//

import SwiftUI

struct ConnectionScreen: View {
    @EnvironmentObject var router : Router
    @EnvironmentObject var bluetoothManager : BluetoothManager
    
    var body: some View {
        
        VStack{
            Text("Connection...")
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint:.black))
                .scaleEffect(1.5)
        }
        
        
        
        .padding()
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: {
            if(bluetoothManager.connectedPeripheral != nil){
                router.navigate(to: .services)
            }
        })
    }
}


struct ConnectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionScreen()
    }
}
