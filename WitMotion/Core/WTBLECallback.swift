//
//  WTBLECallback.swift
//  
//
//  Created by Prem Pratap Singh on 22/03/23.
//

import Foundation
import CoreBluetooth

public typealias WTCentralManagerDidUpdateStateBlock = (CBCentralManager) -> Void
public typealias WTDiscoverPeripheralsBlock = (CBCentralManager, CBPeripheral, [String : Any], NSNumber) -> Void
public typealias WTConnectedPeripheralBlock = (CBCentralManager, CBPeripheral) -> Void
public typealias WTFailToConnectBlock = (CBCentralManager, CBPeripheral, Error?) -> Void
public typealias WTDisconnectBlock = (CBCentralManager, CBPeripheral, Error?) -> Void
public typealias WTDiscoverServicesBlock = (CBPeripheral, Error?) -> Void
public typealias WTDiscoverCharacteristicsBlock = (CBPeripheral, CBService, Error?) -> Void
public typealias WTReadValueForCharacteristicBlock = (CBPeripheral, CBCharacteristic, Error?) -> Void
public typealias WTDiscoverDescriptorsForCharacteristicBlock = (CBPeripheral, CBCharacteristic, Error?) -> Void
public typealias WTReadValueForDescriptorsBlock = (CBPeripheral, CBDescriptor, Error?) -> Void
public typealias WTDidWriteValueForCharacteristicBlock = (CBCharacteristic, Error?) -> Void
public typealias WTDidWriteValueForDescriptorBlock = (CBDescriptor, Error?) -> Void
public typealias WTReadRssiBlock = (CBPeripheral, NSNumber, Error?) -> Void

public class WTBLECallback {
    public var blockOnCentralManagerDidUpdateState: WTCentralManagerDidUpdateStateBlock?
    public var blockOnDiscoverPeripherals: WTDiscoverPeripheralsBlock?
    public var blockOnConnectedPeripheral: WTConnectedPeripheralBlock?
    public var blockOnFailToConnect: WTFailToConnectBlock?
    public var blockOnDisconnect: WTDisconnectBlock?
    public var blockOnDiscoverServices: WTDiscoverServicesBlock?
    public var blockOnDiscoverCharacteristics: WTDiscoverCharacteristicsBlock?
    public var blockOnReadValueForCharacteristic: WTReadValueForCharacteristicBlock?
    public var blockOnDiscoverDescriptorsForCharacteristic: WTDiscoverDescriptorsForCharacteristicBlock?
    public var blockOnReadValueForDescriptors: WTReadValueForDescriptorsBlock?
    public var blockOnReadRssi: WTReadRssiBlock?
    public var blockOnDidWriteValueForCharacteristic: WTDidWriteValueForCharacteristicBlock?
    public var blockOnDidWriteValueForDescriptor: WTDidWriteValueForDescriptorBlock?
}
