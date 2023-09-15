//
//  RogerRemoteApp.swift
//  RogerRemote
//
//  Created by El-Hoiydi, Felix on 08.09.23.
//

import SwiftUI

@main
struct RogerRemoteApp: App {
    
    @StateObject var bluetoothManager = BluetoothManager()
    @StateObject var router = Router()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path:$router.navPath){
                ScanningScreen()
                    .navigationDestination(for: Router.Destination.self){destination in
                        switch destination {
                        case .services:
                            ServicesScreen()
                        case .characteristics:
                            CharacteristicsScreen()
                        case .scanner:
                            ScanningScreen()
                        case .connection:
                            ConnectionScreen()
                        }
                    }
            }
            .environmentObject(router)
            .environmentObject(bluetoothManager)
            .onChange(of: bluetoothManager.rogerIsDiscovered){ value in
                if (value){
                    router.navigate(to: .connection)
                }else{
                    router.navigateToRoot()
                }
            }
            .onChange(of: bluetoothManager.isConnected){ value in
                if (value){
                    router.navigate(to: .services)
                }else{
                    router.navigateToRoot()
                }
            }
        }
    }
}
