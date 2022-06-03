//
//  Extensions.swift
//  audioSwitch
//
//  Created by Tristan Wayne Brodeur on 7/29/20.
//  Copyright © 2020 Brodeur Co. All rights reserved.
//

import Foundation

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}
