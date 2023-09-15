//
//  BluetoothManager.swift
//  FindMyRoger
//
//  Created by El-Hoiydi, Felix on 13.09.23.
//

import CoreBluetooth
import OSLog
import Accelerate

class BluetoothManager : NSObject,ObservableObject{
    static let ble_log = OSLog(subsystem: "FoxtrotEchoHotel.RogerRemote", category: "BLe")
    //let scanUuidFilters : [CBUUID]? = [CBUUID(string: "5a791800-0d19-4fd9-87f9-e934aedbce59")]
    let scanUuidFilters : [CBUUID]? = nil
    private var centralManager : CBCentralManager? = nil
    
    @Published var knownPeripherals : [PeripheralWrapper] = []
    public var averaging : Bool = true
    public var searchForNewDevices : Bool = true
    public var filterForHearingAids : Bool = false

    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    //scanning
    func startScan(){
        centralManager?.scanForPeripherals(withServices: scanUuidFilters,options: [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(value: true)])
        //centralManager?.scanForPeripherals(withServices: scanUuidFilters,options: nil)
    }
    
    func stopScan(){
        centralManager?.stopScan()
    }
    
    func startFindMy(){
        startScan()
    }
    
    func stopFindMy(){
        stopScan()
    }
    
    func updateData(rssi : Double,index : Int){
        knownPeripherals[index].rssi = rssi
        knownPeripherals[index].rssiAverage = averaging ? inertial_smoothing(input: rssi) : rssi
        knownPeripherals[index].distance = get_distance_model(rssi: knownPeripherals[index].rssiAverage)
        let minmax = min_max_model(rssi: knownPeripherals[index].rssiAverage)
        knownPeripherals[index].minDistance = minmax[0]
        knownPeripherals[index].maxDistance = minmax[1]
        knownPeripherals[index].trendingslope = trending_slope(input: knownPeripherals[index].rssiAverage)
    }
    
    func get_distance_model(rssi:Double,rssi0 : Double = -60,pathlossfactor : Double = 2,margin:Double=0) -> Double{
        return pow(10, (rssi0-(rssi+margin))/(10 * pathlossfactor))
    }
    
    func min_max_model(rssi:Double,rssi0 : Double = -60,pathlossfactor : Double = 2,margin:Double=0) -> [Double]{
        return [get_distance_model(rssi: rssi,margin: 7),get_distance_model(rssi: rssi,margin: -7)]
    }
    
    
    func exponential_averaging(input : Double,k : Double = 0.1) -> Double{
        struct Holder{
            static var previous_value : Double = 0
        }
        print(input,Holder.previous_value,k)
        let new_value = k * input + (1-k) * Holder.previous_value
        Holder.previous_value = new_value
        return new_value
    }
    
    func inertial_smoothing(input : Double, a : Double = 0.3, b : Double = 0.2) -> Double{
        struct Holder{
            static var previous_speed : Double = 0
            static var previous_pos : Double = 0
        }
        let new_speed = (Holder.previous_speed + (input - Holder.previous_pos) * a) * b
        let new_pos =  Holder.previous_pos + new_speed
        Holder.previous_speed = new_speed
        Holder.previous_pos = new_pos
        return new_pos
    }
    
    func trending_slope(input : Double) -> Double{
        struct Holder{
            static var previous_inputs : [Double] = []
        }
        
        if(Holder.previous_inputs.count < 10){
            Holder.previous_inputs.append(input)
        }else{
            Holder.previous_inputs.removeFirst()
            Holder.previous_inputs.append(input)
        }
        
        let x_sum : Double = Double((1...Holder.previous_inputs.count).reduce(0, +))
        let y_sum : Double = Double(Holder.previous_inputs.reduce(0, +))
        let x_avg : Double = x_sum / Double(Holder.previous_inputs.count)
        let y_avg : Double = y_sum / Double(Holder.previous_inputs.count)
        var top :  Double = 0
        var bot :  Double = 0
        for i in 1...Holder.previous_inputs.count{
            top += (Double(i)-x_avg) * (Holder.previous_inputs[i-1] - y_avg)
            bot += (Double(i)-x_avg) * (Double(i)-x_avg)
        }
        
        let slope : Double = top / pow(bot,2)
        return slope
    }
}

extension BluetoothManager : CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        os_log(.info,log: BluetoothManager.ble_log,"CBManagerState %@","\(central.state)")
        switch central.state {
        case CBManagerState.poweredOn:
            os_log(.info,log: BluetoothManager.ble_log,"CBManagerState %@","\(central.state)")
        default :
            return
        }
    }
    
    //scanning
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //os_log(.info,log: BluetoothManager.ble_log,"scaned : %@",peripheral.debugDescription)
        let index = knownPeripherals.firstIndex{$0.id == peripheral.identifier}
        
        if let id = index{
            updateData(rssi : RSSI.doubleValue,index : id)
            return
        }
        
        if(searchForNewDevices){
            var filtered = false
            
            var pname : String = "unknwon"
            if let name = peripheral.name{
                pname = name
            }
            
            var txpowerP :  Double = 0
            if let txpower = advertisementData[CBAdvertisementDataTxPowerLevelKey] as? Double{
                txpowerP = txpower
            }
            
            if(filterForHearingAids){
                //filter for hearing aids
                if let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data{
                    var intlist : [Int] = []
                    for val in data {
                        intlist.append(Int(val))
                    }
                    if(intlist == [130, 2, 0]){
                        filtered = true
                        pname = "Hearing Aids"
                    }
                }
            }
            
            
            //filter for Roger On
            if let serviceuuid = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]{
                if (serviceuuid[0] == CBUUID(string: "5a791800-0d19-4fd9-87f9-e934aedbce59")){
                    filtered = true
                }
            }
            
            guard filtered else {
                return
            }
            
            knownPeripherals.append(PeripheralWrapper(id: peripheral.identifier,
                                                      txpower:txpowerP,
                                                      name:pname))
        }
    }
}


struct PeripheralWrapper:Identifiable{
    let id : UUID
    var rssi : Double = 0
    var rssiAverage : Double = 0
    var distance : Double = 0
    var minDistance : Double = 0
    var maxDistance : Double = 0
    var trendingslope : Double = 0
    var txpower : Double
    let name : String
}
