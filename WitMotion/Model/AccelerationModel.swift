//
//  AccelerationModel.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 24/03/23.
//

import Foundation

class AccelerationModel {
    
    // MARK: - Public properties
    
    var ax: CGFloat
    var ay: CGFloat
    var az: CGFloat
    var at: CGFloat
    var coordinate: CGFloat
    
    // MARK: - Initializer
    
    init(ax: CGFloat, ay: CGFloat, az: CGFloat, at: CGFloat, coordinate: CGFloat) {
        self.ax = ax
        self.ay = ay
        self.az = az
        self.at = at
        self.coordinate = coordinate
    }
}
