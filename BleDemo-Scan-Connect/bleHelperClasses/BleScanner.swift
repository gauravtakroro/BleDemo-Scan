//
//  BleScanner.swift
//  BleDemo-Scan-Connect
//
//  Created by Gaurav Tak on 19/08/23.
//

import SwiftUI
import CoreBluetooth

struct DiscoveredPeripheralDevice {
    // Struct to represent a discovered peripheral device
    var peripheralDevice: CBPeripheral
    var advertisedData: String
}

class BleScanner: NSObject, CBCentralManagerDelegate, ObservableObject {
    // this will store all discovered Peripheral Devices as array, which would populate the data into Home UI as Listing Data
    @Published var discoveredPeripheralDevices = [DiscoveredPeripheralDevice]()
    @Published var isScanningInProgress = false
    var centralManager: CBCentralManager!
    // Set to store unique peripherals that have been discovered
    var discoveredPeripheralDevicesSet = Set<CBPeripheral>()
    // this timer is used to restart the scanning every 5 seconds
    var timer: Timer?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScan() {
        if centralManager.state == .poweredOn {
            // Set isScanning to true and clear the discovered peripherals list
            isScanningInProgress = true
            discoveredPeripheralDevices.removeAll()
            discoveredPeripheralDevicesSet.removeAll()
            objectWillChange.send()

            // Start scanning for peripherals
            centralManager.scanForPeripherals(withServices: nil)

            // Start a timer to stop and restart the scan every 5 seconds
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] timer in
                self?.centralManager.stopScan()
                self?.centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
        }
    }

    func stopScan() {
        // Set isScanning to false and stop the timer
        isScanningInProgress = false
        timer?.invalidate()
        centralManager.stopScan()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            //print("central.state is .unknown")
            stopScan()
        case .resetting:
            //print("central.state is .resetting")
            stopScan()
        case .unsupported:
            //print("central.state is .unsupported")
            stopScan()
        case .unauthorized:
            //print("central.state is .unauthorized")
            stopScan()
        case .poweredOff:
            //print("central.state is .poweredOff")
            stopScan()
        case .poweredOn:
            //print("central.state is .poweredOn")
            startScan()
        @unknown default:
            print("central.state is unknown")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Build a string representation of the advertised data and sort it by names
        var advertisedData = advertisementData.map { "\($0): \($1)" }.sorted(by: { $0 < $1 }).joined(separator: "\n")

        // Convert the timestamp into human readable format and insert it to the advertisedData String
        let timestampValue = advertisementData["kCBAdvDataTimestamp"] as! Double
        // print(timestampValue)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: timestampValue))

        advertisedData = "actual rssi: \(RSSI) dB\n" + "Timestamp: \(dateString)\n" + advertisedData

        // If the peripheral is not already in the list
        if !discoveredPeripheralDevicesSet.contains(peripheral) && peripheral.name != nil && peripheral.name?.isEmpty == false {
            // Add it to the list and the set
            discoveredPeripheralDevices.append(DiscoveredPeripheralDevice(peripheralDevice: peripheral, advertisedData: advertisedData))
            discoveredPeripheralDevicesSet.insert(peripheral)
            objectWillChange.send()
        } else {
            // If the peripheral is already in the list, update its advertised data
            if let index = discoveredPeripheralDevices.firstIndex(where: { $0.peripheralDevice == peripheral }) {
                discoveredPeripheralDevices[index].advertisedData = advertisedData
                objectWillChange.send()
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services, services.count > 0 {
            for service in services {
                print("discovered peripheral has following service: \(service)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        } else {
            print("discovered peripheral has NO service")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print("characterstic in service is: \(characteristic)")
        }
    }
}

extension BleScanner: CBPeripheralDelegate {
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect \(String(describing: peripheral.name))")
        peripheral.delegate = self

        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral \(String(describing: peripheral.name))")
    }
    
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        print("connectionEventDidOccur \(event.rawValue)")
    }
    
}

