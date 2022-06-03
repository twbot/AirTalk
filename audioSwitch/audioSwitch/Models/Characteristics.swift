//
//  Characteristics.swift
//  audioSwitch
//
//  Created by Tristan Wayne Brodeur on 7/1/20.
//  Copyright © 2020 Brodeur Co. All rights reserved.
//

import CoreBluetooth

let sBLEService_UUID = "589b8eac-b74b-11ea-b3de-0242ac130004"
let sBLE_Characteristic_uuid_Tx = "589b8eac-b75b-11ea-b3de-0242ac130004"
let sBLE_Characteristic_uuid_Rx = "589b8eac-b76b-11ea-b3de-0242ac130004"
let MaxCharacters = 20

let BLEService_UUID = CBUUID(string: sBLEService_UUID)
//(Property = Write without response)
let BLE_Characteristic_uuid_Tx = CBUUID(string: sBLE_Characteristic_uuid_Tx)
// (Property = Read/Notify)
let BLE_Characteristic_uuid_Rx = CBUUID(string: sBLE_Characteristic_uuid_Rx)
