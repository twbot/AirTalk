//
//  ContentView.swift
//  audioSwitch
//
//  Created by Tristan Wayne Brodeur on 6/23/20.
//  Copyright © 2020 Brodeur Co. All rights reserved.
//

import SwiftUI
import Speech


struct ContentView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var bleConnection: BLEConnection
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        
        ZStack {
            GeometryReader{ geometry in
                VStack {
                    Button(action: {
                        print("Connect tapped")
                        self.determineBLEConnectivity()
                        self.findDevices()
                        
                    }) {
                        Text("Connect")
                            .font(.title)
                            .padding(50)
                            .background(Color.white.opacity(0.8))
                            .foregroundColor(Color.black)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                    .alert(isPresented: self.$showAlert) {
                        Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), primaryButton: .default (Text("OK")) {
                        },
                              secondaryButton: .cancel(Text("Settings"), action: {
                                 self.settings()
                              }))
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
    }
    
    private func findDevices() {
        self.bleConnection.retrievePeripherals()
    }
    
    private func determineBLEConnectivity() {
        switch self.bleConnection.bluetoothState {
            case 2:
                self.alertTitle = "Bluetooth is turned off"
                self.alertMessage = "Go to settings to make sure bluetooth is on"
            case 3:
                self.alertTitle = "Bluetooth is resetting"
                self.alertMessage = "Restart the app to allow bluetooth connectivity"
            case 6:
                self.alertTitle = "Bluetooth is not supported"
                self.alertMessage = "Make sure that your bluetooth is turned on"
        default:
            self.alertTitle = "Bluetooth is not enabled"
            self.alertMessage = "Make sure that your bluetooth is turned on"
        }
        if self.bleConnection.bluetoothState == 1 {
            self.showAlert = false
            self.viewRouter.currentPage = "blelist"
        } else {
            self.showAlert = true
        }
    }
    
    private func settings() {
        // Take to settings
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ViewRouter()).environmentObject(BLEConnection())
    }
}
#endif
