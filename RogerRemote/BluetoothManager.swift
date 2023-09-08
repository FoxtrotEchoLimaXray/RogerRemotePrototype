//
//  BluetoothManager.swift
//  RogerRemote
//
//  Created by El-Hoiydi, Felix on 08.09.23.
//

import CoreBluetooth
import OSLog


class BluetoothManager : NSObject,ObservableObject{
    static let ble_log = OSLog(subsystem: "FoxtrotEchoHotel.RogerRemote", category: "BLe")
    let scanUuidFilters : [CBUUID]? = [CBUUID(string: "5a791800-0d19-4fd9-87f9-e934aedbce59")]
    
    private var centralManager : CBCentralManager? = nil
    @Published var knownPeripherals : [CBPeripheral] = []
    @Published var connectedPeripheral : CBPeripheral? = nil
    @Published var services : [CBService] = []
    @Published var characteristics : [CBCharacteristic] = []
    @Published var readValues : String = ""
    
    @Published var isScanning : Bool = false
    @Published var rogerIsDiscovered : Bool = false
    
    @Published var isConnected : Bool = false
    
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    //scanning
    func startScan(){
        centralManager?.scanForPeripherals(withServices: scanUuidFilters,options: nil)
        isScanning = true
    }
    
    func stopScan(){
        centralManager?.stopScan()
        isScanning = false
    }
    
    //connection
    func connect(peripheral:CBPeripheral){
        isConnected = false
        centralManager?.connect(peripheral)
    }
    
    func disconnect(){
        guard let peripheral = connectedPeripheral else{
            os_log(.info,log: BluetoothManager.ble_log,"try to disconnect but not connected")
            return
        }
        centralManager?.cancelPeripheralConnection(peripheral)
        cleanUp()
    }
    
    func cleanUp(){
        centralManager?.cancelPeripheralConnection(connectedPeripheral!)

        knownPeripherals = []
        connectedPeripheral = nil
        services  = []
        characteristics  = []
        readValues  = ""
        
        isScanning  = false
        rogerIsDiscovered = false
        isConnected  = false
    }
    
    // Characteristic discovery
    func discoverCharacteristics(service:CBService){
        connectedPeripheral?.discoverCharacteristics(nil, for: service)
        readValues  = ""
    }
    
    // Notification
    func subscribeToNotification(characteristic: CBCharacteristic){
        connectedPeripheral?.setNotifyValue(true, for: characteristic)
    }
    
    func unsubscribeToNotification(characteristic: CBCharacteristic){
        connectedPeripheral?.setNotifyValue(false, for: characteristic)
    }
    
    // Read/Write
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
                os_log(.error,log: BluetoothManager.ble_log,"conversion to bytes gone wrong")
                return
            }
            UInt8Array.append(byte)
        }
        
        let data : Data = Data(UInt8Array)
        
        if peripehral.canSendWriteWithoutResponse{
            peripehral.writeValue(data, for: characteristic,type: .withoutResponse)
            os_log(.info,log: BluetoothManager.ble_log,"wrote \(Array(data))")
        }
    }
    
    func writeRequest(messageString : String,characteristic: CBCharacteristic){
        let data = messageString.data(using: .utf8)!
        connectedPeripheral?.writeValue(data, for: characteristic,type: .withResponse)
    }
}

extension BluetoothManager : CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        os_log(.info,log: BluetoothManager.ble_log,"CBManagerState %@","\(central.state)")
        switch central.state {
        case CBManagerState.poweredOn:
            startScan()
        default :
            return
        }
    }
    
    //scanning
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        os_log(.info,log: BluetoothManager.ble_log,"scaned : %@",peripheral.debugDescription)
        knownPeripherals.append(peripheral)
        connect(peripheral:knownPeripherals[0])
        self.stopScan()
        
        rogerIsDiscovered = true
    }
    
    //connection
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        os_log(.info,log: BluetoothManager.ble_log,"connected to : %@",(peripheral.debugDescription))
        isConnected = true
        
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate=self
        connectedPeripheral?.discoverServices(nil)
    
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            os_log(.error,log: BluetoothManager.ble_log,"\(error.localizedDescription)")
        }
        cleanUp()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            os_log(.error,log: BluetoothManager.ble_log,"\(error.localizedDescription)")
        }
        cleanUp()
    }
}

extension BluetoothManager : CBPeripheralDelegate{
    // Service discovery
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            os_log(.error,log: BluetoothManager.ble_log,"\(error.localizedDescription)")
            return
        }
        guard let services = peripheral.services else {
            return
        }
        self.services = services
    }
    
    // Characteristic discovery
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            os_log(.error,log: BluetoothManager.ble_log,"\(error.localizedDescription)")
            return
        }
        guard let characteristics = service.characteristics else {
            return
        }
        self.characteristics = characteristics
    }
    
    //read and notification
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
    
    //write request only
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error{
            print(error)
            return
        }
    }
}

// so we can use them in List view
extension CBService:Identifiable{
    public var id:UUID{
        get{
            return UUID()
        }
    }
}

// so we can use them in List view
extension CBCharacteristic:Identifiable{
    public var id:UUID{
        get{
            return UUID()
        }
    }
}
