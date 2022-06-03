//
//  ContentViewB.swift
//  audioSwitch
//
//  Created by Tristan Wayne Brodeur on 6/29/20.
//  Copyright © 2020 Brodeur Co. All rights reserved.
//

import Foundation
import SwiftUI

struct ContentViewB: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var bleConnection: BLEConnection
    
    var body: some View {
        VStack {
            Text("Devices").font(.title).foregroundColor(Color.white)
            List(self.bleConnection.scannedBLEDevices, id: \.id) { device in
                Text(verbatim: device.name)
                    .font(.body)
                    .foregroundColor(Color.black)
                    .background(Color.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(10)
                    .onTapGesture(count: 1) {
                        self.bleConnection.connectToDevice(device.peripheralObject)
                    }
            }
            .onAppear(){
                self.bleConnection.objectWillChange.send()
            }
            .listRowBackground(Color.blue)
            .background(Color.white.opacity(0.8))
            .frame(minWidth: 0, maxWidth: 300, minHeight: 0, maxHeight: 250)
            .cornerRadius(20)
            .padding(10)
            .background(Color.white.opacity(0.8))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
    }
}

#if DEBUG
struct ContentViewB_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewB().environmentObject(ViewRouter()).environmentObject(BLEConnection())
    }
}
#endif
