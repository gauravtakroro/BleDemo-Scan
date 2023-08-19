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
    @State var showAdvertisementData = false
    
    var body: some View {
            VStack {
                Text("List of Scanned Ble Devices").font(.title)
                    .padding(.top, 24)
                HStack {
                    // Text field for entering search text
                    TextField("Search", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Button for clearing search text
                    Button(action: {
                        self.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .opacity(searchText == "" ? 0 : 1)
                }
                .padding()
                
                Toggle("Show Advertisement Data", isOn: $showAdvertisementData).padding()
                
                // List of discovered peripherals filtered by search text
                List(bleScanner.discoveredPeripheralDevices.filter {
                    self.searchText.isEmpty ? true : $0.peripheralDevice.name?.lowercased().contains(self.searchText.lowercased()) == true
                }, id: \.peripheralDevice.identifier) { discoveredPeripheralDevice in
                    VStack (alignment: .leading) {
                        Button {
                            print("Ble Device tapped \(String(describing: discoveredPeripheralDevice.peripheralDevice.name))")
                            // bleScanner.centralManager.connect(discoveredPeripheralDevice.peripheralDevice)
                        } label: {
                            Text(discoveredPeripheralDevice.peripheralDevice.name ?? "Unknown Device").bold()
                        }
                        if $showAdvertisementData.wrappedValue {
                            Text(discoveredPeripheralDevice.advertisedData)
                                .font(.caption)
                                .foregroundColor(.gray).padding(.top, 4).padding(.bottom, 16)
                        }
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
            }.ignoresSafeArea()
    }
}
