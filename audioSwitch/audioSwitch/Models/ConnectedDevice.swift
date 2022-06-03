//
//  ConnectedDevice.swift
//  audioSwitch
//
//  Created by Tristan Wayne Brodeur on 7/2/20.
//  Copyright © 2020 Brodeur Co. All rights reserved.
//

//import UIKit
//import Foundation
//import CoreBluetooth
//import CoreLocation
//
//class ConnectedDevice : NSObject , NSCoding{
//
//    var RSSI_threshold:NSNumber=0
//
//    var Current_RSSI:NSNumber=0
//
//    var name:String?
//
//    var bdAddr:NSUUID?
//
//    var ConnectState:Bool=false
//
//    var AlertState:Int=0
//
//    var BLEPeripheral : CBPeripheral!
//
//    var DisconnectAddress:[String] = [String]()
//
//    var DisconnectTime:[String] = [String]()
//
//    var Battery:NSInteger=0
//
//    var Location:[CLLocation] = [CLLocation]()
//
//    var AlertStatus:Int!
//
//
//    override init() {
//
//
//    }
//
//    func encode(with coder: NSCoder) {
//        coder.encode(RSSI_threshold, forKey: "RSSI_threshold")
//        coder.encode(Current_RSSI, forKey: "Current_RSSI")
//        coder.encode(name, forKey: "name")
//        coder.encode(bdAddr, forKey: "bdAddr")
//        coder.encode(ConnectState, forKey: "ConnectState")
//        coder.encode(AlertState, forKey: "AlertState")
//        coder.encode(BLEPeripheral, forKey: "BLEPeripheral")
//        coder.encode(DisconnectAddress, forKey: "DisconnectAddress")
//        coder.encode(DisconnectTime, forKey: "DisconnectTime")
//        coder.encode(Battery, forKey: "Battery")
//        coder.encode(Location, forKey: "Location")
//        coder.encode(AlertStatus, forKey: "AlertStatus")
//    }
//
//    required init?(coder decoder: NSCoder) {
//
//        self.RSSI_threshold = decoder.decodeObject(forKey: "RSSI_threshold") as! NSNumber
//        self.Current_RSSI = decoder.decodeObject(forKey: "Current_RSSI") as! NSNumber
//        self.name = decoder.decodeObject(forKey: "name") as? String
//        self.bdAddr = decoder.decodeObject(forKey: "bdAddr") as? NSUUID
//        self.ConnectState = decoder.decodeObject(forKey: "ConnectState") as! Bool
//        self.AlertState = decoder.decodeObject(forKey: "AlertState") as! Int
//        self.BLEPeripheral = decoder.decodeObject(forKey: "BLEPeripheral") as? CBPeripheral
//        self.DisconnectAddress = decoder.decodeObject(forKey: "DisconnectAddress") as! [String]
//        self.DisconnectTime = decoder.decodeObject(forKey: "DisconnectTime") as! [String]
//        self.Battery = decoder.decodeObject(forKey: "Battery") as! NSInteger
//        self.Location = decoder.decodeObject(forKey: "Location") as! [CLLocation]
//        self.AlertStatus = decoder.decodeObjectForKey("AlertStatus") as! decodeObject
//    }
//}
