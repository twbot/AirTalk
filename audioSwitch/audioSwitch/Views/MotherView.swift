//
//  MotherView.swift
//  audioSwitch
//
//  Created by Tristan Wayne Brodeur on 6/29/20.
//  Copyright © 2020 Brodeur Co. All rights reserved.
//

import Foundation
import SwiftUI

struct MotherView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var bleConnection: BLEConnection
    
    var body: some View {
        ZStack {
                ZStack {
                    Image("rockclimbing")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                    .onAppear(perform: {
                        self.connectBLEDevice()
                    })
                }
                VStack {
                    if viewRouter.currentPage == "connect" {
                        ContentView().transition(.scale)
                    }
                    if viewRouter.currentPage == "blelist" {
                        ContentViewB().transition(.scale)
                    }
                }
        }
    }
    private func connectBLEDevice(){
        // Start Scanning for BLE Devices
        self.bleConnection.startCentralManager()
        self.bleConnection.startPeripheralManager()
    }
    
}

#if DEBUG
struct MotherView_Previews : PreviewProvider {
    static var previews: some View {
        MotherView().environmentObject(ViewRouter()).environmentObject(BLEConnection())
    }
}
#endif
