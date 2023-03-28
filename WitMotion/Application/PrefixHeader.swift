//
//  PrefixHeader.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 26/03/23.
//

import UIKit

let kKeyWindow = UIApplication.shared.delegate?.window
let kScreenBounds = UIScreen.main.bounds
let keyScreenWidth = UIScreen.main.bounds.size.width
let keyScreenHeight = UIScreen.main.bounds.size.height

let SAFEARWA_BOTTOM_HEIGHT = iPhoneX ? 34 : 0
let SRARUSBAR_NAVIGATIONBAR_HEIGHT = iPhoneX ? 88.0 : 64.0
let SRARUSBAR_TABAR_HEIGHT = iPhoneX ? 83.0 : 49.0

let IOS14_OR_ABOVE = UIDevice.current.systemVersion.compare("14.0", options: .numeric) != .orderedAscending
let IOS13_OR_ABOVE = UIDevice.current.systemVersion.compare("13.0", options: .numeric) != .orderedAscending
let IOS11_OR_ABOVE = UIDevice.current.systemVersion.compare("11.0", options: .numeric) != .orderedAscending

var iPhoneX: Bool {
    var isPhoneX = false
    if #available(iOS 11.0, *) {
        isPhoneX = UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0.0 > 0.0
    }
    return isPhoneX
}

func UIColorFromRGB(_ rgbValue: Int) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0xFF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0xFF) / 255.0,
        alpha: 1.0
    )
}

