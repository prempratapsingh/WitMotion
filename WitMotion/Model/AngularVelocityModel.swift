//
//  AngularVelocityModel.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 24/03/23.
//

import Foundation

class AngularVelocityModel {
    
    // MARK: - Public properties
    
    var wx: CGFloat
    var wy: CGFloat
    var wz: CGFloat
    
    // MARK: - Initializer
    
    init(wx: CGFloat, wy: CGFloat, wz: CGFloat) {
        self.wx = wx
        self.wy = wy
        self.wz = wz
    }
}
