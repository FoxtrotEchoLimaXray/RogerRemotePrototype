//
//  RemoteApp.swift
//  Remote
//
//  Created by El-Hoiydi, Felix on 25.08.23.
//

import SwiftUI
import CoreBluetooth

@main
struct RemoteApp: App {
    @ObservedObject var router = Router()
    @ObservedObject var bluetoothManager = BluetoothManager()
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
            .onChange(of: bluetoothManager.knownPeripherals){ value in
                if (value.count != 0){
                    router.navigate(to: .connection)
                }
                
            }
            .onChange(of: bluetoothManager.connectedPeripheral){ value in
                if (value != nil){
                    router.navigate(to: .services)
                }else{
                    if(bluetoothManager.centralManager?.state == CBManagerState.poweredOn){
                        bluetoothManager.knownPeripherals = []
                        bluetoothManager.startScan()
                    }
                    router.navigateToRoot()
                }
            }
        }
    }
}
