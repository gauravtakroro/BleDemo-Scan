//
//  ContentView.swift
//  BleDemo-Scan-Connect
//
//  Created by Gaurav Tak on 19/08/23.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @ObservedObject private var bleScanner = BleScanner()
    @State private var searchText = ""

    var body: some View {
        VStack {
            Text("List of Scanned Ble Devices").font(.title).padding(.top, 24)

            // List of discovered peripherals filtered by search text
            List(bleScanner.discoveredPeripheralDevices, id: \.peripheralDevice.identifier) { discoveredPeripheralDevice in
                HStack {
                    Text(discoveredPeripheralDevice.peripheralDevice.name ?? "Unknown Device").bold().frame(alignment: .leading)
                    Spacer()
                    Image("_next").frame(alignment: .trailing)
                }.frame(maxWidth: .infinity)
                    .onTapGesture {
                        print("Ble Device Tapped")
                      //  bleScanner.centralManager.connect(discoveredPeripheralDevice.peripheralDevice, options: nil)
                    }
            }.padding(.top, 16)

            // Button for starting or stopping scanning
            Button(action: {
                if self.bleScanner.isScanningInProgress {
                    self.bleScanner.stopScan()
                } else {
                    self.bleScanner.startScan()
                }
            }) {
                if bleScanner.isScanningInProgress {
                    Text("Stop Ble Scanning")
                } else {
                    Text("Scan for Ble Devices")
                }
            }
            // Button looks cooler this way on iOS
            .padding()
            .background(bleScanner.isScanningInProgress ? Color.red : Color.blue)
            .foregroundColor(Color.white)
            .cornerRadius(5.0)
        }
    }
}
