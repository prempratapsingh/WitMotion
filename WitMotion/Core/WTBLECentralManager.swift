//
//  WTBLECentralManager.swift
//  
//
//  Created by Prem Pratap Singh on 22/03/23.
//

import Foundation
import CoreBluetooth

public class WTBLECentralManager: NSObject {
    
    // MARK: Public properties
    
    var callback: WTBLECallback = WTBLECallback()
    var manager: CBCentralManager!
    
    // MARK: Private properties
    
    private var peripheral: CBPeripheral!
    private var writeCharacteristic: CBCharacteristic!
    private var readCharacteristic: CBCharacteristic!
    private var wtBTType: WTBTType = .BT_BLE
    
    override init() {
        super.init()
        self.manager = CBCentralManager(delegate: self, queue: .main)
    }
    
    // MARK: Public methods
    
    func getType() -> WTBTType {
        return self.wtBTType
    }

    func startScan() {
        guard self.manager.state == .poweredOn else { return }
        let options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: true,
            CBCentralManagerOptionShowPowerAlertKey: true
        ]
        self.manager.scanForPeripherals(withServices: nil, options: options)
    }

    func cancelScan() {
        self.manager.stopScan()
    }

    func tryConnectPeripheral(_ peripheral: CBPeripheral) {
        cancelConnection()
        self.peripheral = peripheral
        peripheral.delegate = self
        self.manager.connect(peripheral, options: nil)
    }

    func cancelConnection() {
        if let peripheral = peripheral {
            self.manager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func tryReceiveDataAfterConnected() {
        self.peripheral.discoverServices(nil)
    }

    func readRssi() {
        self.peripheral.readRSSI()
    }

    func writeData(_ data: Data) {
        guard let writeCharacteristic = writeCharacteristic else {
            return
        }
        self.peripheral.writeValue(data, for: writeCharacteristic, type: .withoutResponse)
    }
}

// MARK: CBCentralManagerDelegate delegate methods

extension WTBLECentralManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print(">>>CBCentralManagerStateUnknown")
        case .resetting:
            print(">>>CBCentralManagerStateResetting")
        case .unsupported:
            print(">>>CBCentralManagerStateUnsupported")
        case .unauthorized:
            print(">>>CBCentralManagerStateUnauthorized")
        case .poweredOff:
            print(">>>CBCentralManagerStatePoweredOff")
        case .poweredOn:
            print(">>>CBCentralManagerStatePoweredOn")
        @unknown default:
            break
        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name, !name.isEmpty else { return }
        if name.contains("HC") || name.contains("WT") {
            callback.blockOnDiscoverPeripherals?(manager, peripheral, advertisementData, RSSI)
        }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        callback.blockOnConnectedPeripheral?(manager, peripheral)
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        callback.blockOnFailToConnect?(manager, peripheral, error)
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        callback.blockOnDisconnect?(manager, peripheral, error)
    }

    func setReadCharacteristic(_ readCharacteristic: CBCharacteristic) {
        self.readCharacteristic = readCharacteristic
        self.peripheral.setNotifyValue(true, for: readCharacteristic)
    }

    func setWriteCharacteristic(_ writeCharacteristic: CBCharacteristic) {
        self.writeCharacteristic = writeCharacteristic
    }
}

// MARK: CBPeripheralDelegate delegate methods

extension WTBLECentralManager: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("discover service error, error is \(error)")
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
                
                let uuidString = characteristic.uuid.uuidString
                if uuidString.lowercased().contains("ffe9") {
                    self.writeCharacteristic = characteristic
                    self.wtBTType = .BT_BLE
                } else if uuidString.lowercased().contains("ffe4") {
                    self.readCharacteristic = characteristic
                } else if uuidString.lowercased().contains("8841") {
                    self.writeCharacteristic = characteristic
                    self.wtBTType = .BT_HC
                } else if uuidString.lowercased().contains("1e4d") {
                    self.readCharacteristic = characteristic
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if self.callback.blockOnReadValueForCharacteristic != nil {
            self.callback.blockOnReadValueForCharacteristic?(peripheral, characteristic, error)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if self.callback.blockOnDiscoverDescriptorsForCharacteristic != nil {
            self.callback.blockOnDiscoverDescriptorsForCharacteristic?(peripheral, characteristic, error)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if self.callback.blockOnReadRssi != nil {
            self.callback.blockOnReadRssi?(peripheral, RSSI, error)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if self.callback.blockOnDidWriteValueForCharacteristic != nil {
            self.callback.blockOnDidWriteValueForCharacteristic?(characteristic, error)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        if self.callback.blockOnDidWriteValueForDescriptor != nil {
            self.callback.blockOnDidWriteValueForDescriptor?(descriptor, error)
        }
    }
}

public enum WTBTType: Int {
    case BT_BLE = 0
    case BT_HC
}
