//
//  ViewRouter.swift
//  audioSwitch
//
//  Created by Tristan Wayne Brodeur on 6/29/20.
//  Copyright © 2020 Brodeur Co. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class ViewRouter: ObservableObject {
    
    let objectWillChange = PassthroughSubject<ViewRouter,Never>()
    var currentPage: String = "connect" {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
}
