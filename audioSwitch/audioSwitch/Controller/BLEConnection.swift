//
//  BLEConnection.swift
//  audioSwitch
//
//  Created by Tristan Wayne Brodeur on 6/24/20.
//  Copyright © 2020 Brodeur Co. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import os

var blePeripheral : CBPeripheral?
var txCharacteristic : CBCharacteristic?
var rxCharacteristic : CBCharacteristic?
var characteristicASCIIValue = NSString()

open class BLEConnection: UIViewController, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    
    
    struct Peripheral: Identifiable {
        let id: Int
        let name: String
        let rssi: Int
        let peripheralObject: CBPeripheral
    }
    
    // Properties
    private var centralManager: CBCentralManager! = nil
    private var peripheralManager: CBPeripheralManager! = nil
    private var peripheral: CBPeripheral!
    var bluetoothState: Int = 1
    var alertTitle: String = ""
    var alertMessage: String = ""
    var showAlert: Bool = false
    let properties: CBCharacteristicProperties = [.notify, .read, .write]
    let permissions: CBAttributePermissions = [.readable, .writeable]

    
    var discoveredPeripheral: CBPeripheral?
    var transferCharacteristic: CBCharacteristic?
    
    var timer = Timer()

    // Array to contain names of BLE devices to connect to.
    // Accessable by ContentView for Rendering the SwiftUI Body on change in this array.
    @Published var scannedBLEDevices = [Peripheral]()
    var RSSIs = [NSNumber]()
    var data = NSMutableData()
    
    // MARK: Central Functions
    // Connecting, Connected, Disconnected
    func startCentralManager() {
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.centralManagerDidUpdateState(self.centralManager)
            self.determineState()
        }
    }

    // Handles BLE Device Settings
    public func centralManagerDidUpdateState(_ central: CBCentralManager)  {
        switch central.state {
            case .poweredOn:
                print("CBManager is powered on")
                return
            case .poweredOff:
                print("CBManager is not powered on")
                self.alertTitle = "Bluetooth is turned off"
                self.alertMessage = "Go to settings and make sure your bluetooth is turned on"
                self.bluetoothState = 2
                return
            case .resetting:
                print("CBManager (Bluetooth) is resetting")
                self.alertTitle = "Bluetooth is resetting"
                self.alertMessage = "Please restart the app and allow bluetooth to reset"
                self.bluetoothState = 3
                return
            case .unauthorized:
                print("BLE is Unauthorized")
                self.alertTitle = "Bluetooth is not authorized on this device"
                self.alertMessage = "Go to settings and make sure bluetooth is authorized for this app"
                if #available(iOS 13.0, *) {
                    switch central.authorization {
                    case .denied:
                        print("You are not authorized to use Bluetooth")
                    case .restricted:
                        print("Bluetooth is restricted")
                    default:
                        print("Unexpected authorization")
                    }
                } else {
                    // Fallback on earlier versions
                }
                self.bluetoothState = 4
                return
            case .unknown:
                print("BLE is Unknown")
                self.alertTitle = "An unkown error occured"
                self.alertMessage = "Please restart the app and allow bluetooth to reset"
                self.bluetoothState = 5
                return
            case .unsupported:
                print("BLE is Unsupported")
                self.alertTitle = "Bluetooth is not supported"
                self.alertMessage = "Make sure this device has bluetooth support"
                self.bluetoothState = 6
                return
            @unknown default:
                print("A previously unknown central manager state occurred")
                self.alertTitle = "Bluetooth is not enabled"
                self.alertMessage = "Make sure that your bluetooth is turned on"
                self.bluetoothState = 7
                return
        }
    }
    
    private func determineState() {
        if self.bluetoothState == 1 {
            self.showAlert = false
        } else {
            self.showAlert = true
        }
    }
    
    public func retrievePeripherals() {
          print("Retrieving BLE Peripherals")
          self.timer.invalidate()
          centralManager?.scanForPeripherals(withServices: [BLEService_UUID] , options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
          Timer.scheduledTimer(withTimeInterval: 17, repeats: false) {_ in
              self.cancelPeripheralRetrieve()
          }
    }
    
    private func cancelPeripheralRetrieve() {
        self.centralManager?.stopScan()
        os_log("Stopping peripheral retrieval")
    }
    
    /*
     Called when the central manager discovers a peripheral while scanning. Also, once peripheral is connected, cancel scanning.
     */
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // self.centralManager.cancelPeripheralRetrieve()
        self.throwLocalNotificationWith(message: "Discovered peripheral");
        // Reject if the signal strength is too low to attempt data transfer
        guard RSSI.intValue >= -50
            else {
                // os_log("Discovered perhiperal not in expected range, at %d", RSSI.intValue)
                print("Discovered perhiperal not in expected range, at %d", RSSI.intValue)
                print(peripheral)
                return
        }
        var peripheralName: String!
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else {
            peripheralName = "Unknown"
        }
        let newPeripheral = Peripheral(id: peripheral.hashValue, name: peripheralName, rssi: RSSI.intValue, peripheralObject: peripheral)
        self.scannedBLEDevices.append(newPeripheral)
        self.RSSIs.append(RSSI)
        peripheral.delegate = self
        for item in scannedBLEDevices {
            print(item)
        }
        // self.baseTableView.reloadData()
        if blePeripheral == nil {
            for item in scannedBLEDevices {
                print(item)
            }
//            print("Found new pheripheral devices with services")
//            print("Peripheral name: \(String(describing: peripheral.name))")
//            print("**********************************")
//            print ("Advertisement Data : \(advertisementData)")
        }
    }
    
    // Peripheral Connecting, Connected, Disconnected
    
    //-Connection
    func connectToDevice (_ peripheral: CBPeripheral) {
        // blePeripheral = peripheral
        centralManager?.connect(peripheral, options: nil)
    }
    
    //-Connected
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        /*
        Invoked when a connection is successfully created with a peripheral.
        This method is invoked when a call to connect(_:options:) is successful. You typically implement this method to set the peripheral’s delegate and to discover its services.
        */
        
        // Stop scanning
        centralManager?.stopScan()
        os_log("Scanning stopped")
        
        // Print peripheral data
        print("*****************************")
        print("Connection complete")
        print("Peripheral info: \(String(describing: blePeripheral))")
        
        
        //Erase data that we might have
        data.length = 0
        
        //Discovery callback
        peripheral.delegate = self
        //Only look for services that matches transmit uuid
        peripheral.discoverServices([BLEService_UUID])
        
        
        //Once connected, move to new view controller to manager incoming and outgoing data
        // let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // let uartViewController = storyboard.instantiateViewController(withIdentifier: "UartModuleViewController") as! UartModuleViewController
        // uartViewController.peripheral = peripheral
        // navigationController?.pushViewController(uartViewController, animated: true)
    }
    
    //-Failed Connect
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        /*
        Invoked when the central manager fails to create a connection with a peripheral.
        */
        if error != nil {
            print("Failed to connect to peripheral")
            return
        }
    }
    
    //-Disconnected
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        /*
        Invoked when the central manager fails to create a connection with a peripheral.
        */
        print("Disconnected")
    }
    
    // Peripheral Connecting, Connected, Disconnected
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        /*
        Invoked when you discover the peripheral’s available services.
        This method is invoked when your app calls the discoverServices(_:) method. If the services of the peripheral are successfully discovered, you can access them through the peripheral’s services property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
        */
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        //We need to discover the all characteristic
        for service in services {
            
            peripheral.discoverCharacteristics(nil, for: service)
            // bleService = service
        }
        print("Discovered Services: \(services)")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        /*
        Invoked when you discover the characteristics of a specified service.
        This method is invoked when your app calls the discoverCharacteristics(_:for:) method. If the characteristics of the specified service are successfully discovered, you can access them through the service's characteristics property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
        */
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("Found \(characteristics.count) characteristics!")
        
        for characteristic in characteristics {
            //looks for the right characteristic
            
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Rx)  {
                rxCharacteristic = characteristic
                
                //Once found, subscribe to the this particular characteristic...
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
                // didUpdateNotificationStateForCharacteristic method will be called automatically
                peripheral.readValue(for: characteristic)
                print("Rx Characteristic: \(characteristic.uuid)")
            }
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Tx){
                txCharacteristic = characteristic
                print("Tx Characteristic: \(characteristic.uuid)")
            }
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    // Getting Values From Characteristic
    /** After you've found a characteristic of a service that you are interested in, you can read the characteristic's value by calling the peripheral "readValueForCharacteristic" method within the "didDiscoverCharacteristicsFor service" delegate.
     */
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic == rxCharacteristic,
            let characteristicValue = characteristic.value,
            let ASCIIstring = NSString(data: characteristicValue,
                                       encoding: String.Encoding.utf8.rawValue)
            else { return }
        
        characteristicASCIIValue = ASCIIstring
        print("Value Recieved: \((characteristicASCIIValue as String))")
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: self)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        guard let descriptors = characteristic.descriptors else { return }
            
        descriptors.forEach { descript in
            print("function name: DidDiscoverDescriptorForChar \(String(describing: descript.description))")
            print("Rx Value \(String(describing: rxCharacteristic?.value))")
            print("Tx Value \(String(describing: txCharacteristic?.value))")

        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        
        if (error != nil) {
            print("Error changing notification state:\(String(describing: error?.localizedDescription))")
            
        } else {
            print("Characteristic's value subscribed")
        }
        
        if (characteristic.isNotifying) {
            print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        print("Message sent")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        print("Succeeded!")
    }
    
    // MARK: Peripheral Functions
    public func startPeripheralManager() {
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
//        let advertisementData = [CBAdvertisementDataServiceUUIDsKey: BLEService_UUID]
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.peripheralManager.startAdvertising(advertisementData)
//        }
    }
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        if peripheral.state == CBManagerState.poweredOn {
            print("Powered On: Peripheral State")
            advertise()
        } else if peripheral.state == CBManagerState.poweredOff {
            print("Powered off: Peripheral State")
        }
    }
    
    public func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?)
    {
        if let error = error {
            print("Failed… error: \(error)")
            return
        }
        print("Succeeded!")
    }
    
    public func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest)
    {
        if request.characteristic.uuid.isEqual(txCharacteristic!.uuid)
        {
            // Set the correspondent characteristic's value
            // to the request
            request.value = txCharacteristic!.value
     
            // Respond to the request
            peripheralManager.respond(
                to: request,
                withResult: .success)
        }
    }
    
    public func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {

        if (error != nil) {
            print("PerformerUtility.publishServices() returned error: \(error!.localizedDescription)")
            print("Providing the reason for failure: \(String(describing: error!.localizedFailureReason))")
        }
        else {
            print("Started advertising")
        }
    }
    
    func advertise()
    {
        txCharacteristic = CBMutableCharacteristic(
        type: BLE_Characteristic_uuid_Tx,
        properties: properties,
        value: nil,
        permissions: permissions)
        
        let service1 = CBMutableService(type: BLEService_UUID, primary: true)
        print(service1)
        service1.characteristics = [txCharacteristic!]
        self.peripheralManager.add(service1)
        let services: NSArray = [service1.uuid]
        self.peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : services])
    }
    
    
    // MARK: Notification Functions
    func throwLocalNotificationWith(message:String){
     
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = message
            content.body = "body"
            content.categoryIdentifier = "alarm"
            content.userInfo = ["customData": "fizzbuzz"]
            content.sound = UNNotificationSound.default
         
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            center.add(request)
         
         
        } else {
            let notification = UILocalNotification()
            notification.fireDate = NSDate(timeIntervalSinceNow: 5) as Date
            notification.alertBody = message
            notification.alertAction = "Action"
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
         
        }
    }
}
