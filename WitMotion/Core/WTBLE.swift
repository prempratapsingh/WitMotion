//
//  WTBLE.swift
//  
//
//  Created by Prem Pratap Singh on 22/03/23.
//

import Foundation
import CoreBluetooth

public class WTBLE {
    
    public var bleManager: WTBLECentralManager!
    public var bleCallback: WTBLECallback!
    
    public static let sharedInstance = WTBLE()
        
    private init() {
        self.bleManager = WTBLECentralManager()
        self.bleCallback = self.bleManager.callback
    }
    
    public func startScan() {
        self.bleManager?.startScan()
    }

    public func cancelScan() {
        self.bleManager?.cancelScan()
    }

    public func tryConnectPeripheral(_ peripheral: CBPeripheral) {
        self.bleManager.tryConnectPeripheral(peripheral)
    }

    public func cancelConnection() {
        self.bleManager.cancelConnection()
    }

    public func tryReceiveDataAfterConnected() {
        self.bleManager.tryReceiveDataAfterConnected()
    }

    public func readRssi() {
        self.bleManager.readRssi()
    }
    
    public func writeData(_ data: Data) {
        self.bleManager.writeData(data)
    }

    public func getDeviceType() -> WTBTType {
        guard let manager = self.bleManager else {
            return .BT_BLE
        }
        return manager.getType()
    }
}
