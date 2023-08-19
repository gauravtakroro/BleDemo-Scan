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
    @State var showBleDeviceDetailsUi = false
   
    func buildView() -> some View {
        return AnyView(Text("DetailView"))
    }
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(
                    destination: buildView(), isActive: $showBleDeviceDetailsUi
                ) {
                    EmptyView()
                }.isDetailLink(false)
                Text("List of Scanned Ble Devices").font(.title)
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
                // List of discovered peripherals filtered by search text
                List(bleScanner.discoveredPeripheralDevices.filter {
                    self.searchText.isEmpty ? true : $0.peripheralDevice.name?.lowercased().contains(self.searchText.lowercased()) == true
                }, id: \.peripheralDevice.identifier) { discoveredPeripheralDevice in
                    HStack {
                        Text(discoveredPeripheralDevice.peripheralDevice.name ?? "Unknown Device").bold().frame(alignment: .leading)
                        Spacer()
                        Image("_next").frame(alignment: .trailing)
                    }.frame(maxWidth: .infinity)
                        .onTapGesture {
                            print("Ble Device Tapped")
                           // showBleDeviceDetailsUi = true
                           // bleScanner.centralManager.connect(discoveredPeripheralDevice.peripheralDevice, options: nil)
                        }
                }.padding(.top, 16)
                
                // Button for starting or stopping scanning
                Button(action: {
                    showBleDeviceDetailsUi = true
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
        }.ignoresSafeArea()
    }
}
