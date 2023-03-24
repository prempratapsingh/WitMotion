//
//  WTBLEPeripheral.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 22/03/23.
//

import Foundation
import CoreBluetooth

class WTBLEPeripheral {
    
    var peripheral: CBPeripheral?
    var advertisementData: [String: Any]?
    var RSSI: NSNumber?
    
    static func peripheral(
        with peripheral: CBPeripheral?,
        advertisementData: [String: Any]?,
        RSSI: NSNumber) -> WTBLEPeripheral? {
        guard peripheral != nil else {
            return nil
        }
        
        let blePeripheral = WTBLEPeripheral()
        blePeripheral.peripheral = peripheral
        blePeripheral.advertisementData = advertisementData
        blePeripheral.RSSI = RSSI
        return blePeripheral
    }
}
