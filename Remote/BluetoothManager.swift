//
//  BluetoothManager.swift
//  Test
//
//  Created by El-Hoiydi, Felix on 29.08.23.
//

import Foundation
import CoreBluetooth
import os.log

@objc class BluetoothManager : NSObject,ObservableObject{
    static let ble_log = OSLog(subsystem: "com.felix.test", category: "BLe")
    
    @Published var centralManager : CBCentralManager? = nil
    @Published var connectedPeripheral : CBPeripheral? = nil
    @Published var knownPeripherals : [CBPeripheral] = []
    @Published var services : [CBService] = []
    @Published var characteristics : [CBCharacteristic] = []
    @Published var readValues : String = ""
    @Published var scanning : Bool = false
    
  
    
    private var withServicesUUIDs : [CBUUID]? = [CBUUID(string: "5a791800-0d19-4fd9-87f9-e934aedbce59")]
    
    override init() {
        super.init()
        //let serialQueue = dispatch_queue_serial_t.main
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan(){
        centralManager?.scanForPeripherals(withServices: withServicesUUIDs,options: nil)
        os_log(.info,log: BluetoothManager.ble_log,"start scan")
    }
    func stopScan(){
        centralManager?.stopScan()
        os_log(.info,log: BluetoothManager.ble_log,"stop scan")
    }
    
    func connect(peripheral:CBPeripheral){
        centralManager?.connect(peripheral)
        os_log(.info,log: BluetoothManager.ble_log,"try connect")
        print("lol")
    }
    
    func disconnect(){
        guard let peripheral = connectedPeripheral else{
            os_log(.info,log: BluetoothManager.ble_log,"try to disconnect but not connected")
            return
        }
        centralManager?.cancelPeripheralConnection(peripheral)
        os_log(.info,log: BluetoothManager.ble_log,"try to disconnect")
    }
    
    func discoverCharacteristics(service:CBService){
        connectedPeripheral?.discoverCharacteristics(nil, for: service)
    }
    
    func subscribeToNotification(characteristic: CBCharacteristic){
        connectedPeripheral?.setNotifyValue(true, for: characteristic)
        os_log(.info,log: BluetoothManager.ble_log,"try to subscribing")
    }
    
    func unsubscribeToNotification(characteristic: CBCharacteristic){
        connectedPeripheral?.setNotifyValue(false, for: characteristic)
    }
    
    func readValue(characteristic: CBCharacteristic){
        connectedPeripheral?.readValue(for :characteristic)
    }
    
    func writeCommmand(messageString : String,characteristic: CBCharacteristic){
        guard let peripehral = connectedPeripheral else {
            return
        }
        
        var UInt8Array : [UInt8] = []
        
        messageString.forEach{ char in
            let stringvalue = String(char)
            let uint8value = UInt8(stringvalue)
            guard let byte = uint8value else{
                print("error conversion to bytes gone wrong")
                return
            }
            UInt8Array.append(byte)
        }
        
        let data : Data = Data(UInt8Array)
        
        if peripehral.canSendWriteWithoutResponse{
            peripehral.writeValue(data, for: characteristic,type: .withoutResponse)
            print("wrote \(Array(data))")
        }
    }
    
    func writeRequest(messageString : String,characteristic: CBCharacteristic){
        let data = messageString.data(using: .utf8)!
        connectedPeripheral?.writeValue(data, for: characteristic,type: .withResponse)
    }
    
    func discoverDescriptors(characteristic: CBCharacteristic){
        connectedPeripheral?.discoverDescriptors(for: characteristic)
    }
}

extension BluetoothManager:CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        os_log(.info,log: BluetoothManager.ble_log,"bluetoothstate : %@","\(central.state)")
        
        switch central.state {
        case CBManagerState.poweredOn:
           print("poweredOn")
            self.startScan()
        case CBManagerState.poweredOff:
            print("poweredOff")
        default :
            return
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        os_log(.info,log: BluetoothManager.ble_log,"scaned : %@",peripheral.description)
        
        knownPeripherals.append(peripheral)
        centralManager?.connect(knownPeripherals[0])
        self.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate=self
        os_log(.info,log: BluetoothManager.ble_log,"connected to : %@",(peripheral.description))
        
        connectedPeripheral?.discoverServices(nil)
        os_log(.info,log: BluetoothManager.ble_log,"try discoverServices from : %@",peripheral.description)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        os_log(.info,log: BluetoothManager.ble_log,"disconnected from : %@",peripheral.description)
    }
}

extension BluetoothManager:CBPeripheralDelegate{
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        self.services = services
       
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            os_log(.error,log: BluetoothManager.ble_log,"error on characteristic discovery : %@",service.description)
            return
        }
        self.characteristics = characteristics
        for characteristic in characteristics {
            os_log(.info,log: BluetoothManager.ble_log,"discovered service : %@",characteristic.description)
            discoverDescriptors(characteristic: characteristic)
        }
    }
    
   
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Characteristic value update failed: \(error.localizedDescription)")
            return
          }
        
        guard let data = characteristic.value else { return }

        var intlist : [Int] = []
        for val in data {
            intlist.append(Int(val))
        }
        print("test")
        self.readValues = "\(intlist)"
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error{
            print(error)
            return
        }
    }
    
  
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error{
            print(error)
            return
        }
        guard let descriptors = characteristic.descriptors else { return }
     
        // Get user description descriptor
        if let userDescriptionDescriptor = descriptors.first(where: {
            return $0.uuid.uuidString == CBUUIDCharacteristicUserDescriptionString
        }) {
            // Read user description for characteristic
            peripheral.readValue(for: userDescriptionDescriptor)
           
            print(userDescriptionDescriptor)
        }
    }
     
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if let error = error{
            print(error)
            return
        }
        // Get and print user description for a given characteristic
        if descriptor.uuid.uuidString == CBUUIDCharacteristicUserDescriptionString,
           let userDescription = descriptor.value as? String {
            print("Characterstic \(descriptor.characteristic!.uuid.uuidString) is also known as \(userDescription)")
        }
        
    }
}

extension CBPeripheral:Identifiable{
    public var id:UUID{
        get{
            return UUID()
        }
    }
}

extension CBService:Identifiable{
    public var id:UUID{
        get{
            return UUID()
        }
    }
}

extension CBCharacteristic:Identifiable{
    public var id:UUID{
        get{
            return UUID()
        }
    }
}
