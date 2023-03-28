//
//  ItemDataModel.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 24/03/23.
//

import Foundation

class ItemDataModel {
    
    // MARK: - Public properties
    
    var title: String?
    var dataType: ItemDataType
    
    // MARK: - Initializer
    
    init(title: String, dataType: ItemDataType) {
        self.title = title
        self.dataType = dataType
    }
    
    // MARK: - Public functions
    
    static func itemData(withTitle title: String, type: ItemDataType) -> ItemDataModel {
        return ItemDataModel(title: title, dataType: type)
    }
    
    static func itemDataList() -> [ItemDataModel] {
        return [
            ItemDataModel.itemData(withTitle: NSLocalizedString("acceleration", comment: ""),
                                   type: .acceleration),
            ItemDataModel.itemData(withTitle: NSLocalizedString("angular_velocity", comment: ""),
                                   type: .angularVelocity),
            ItemDataModel.itemData(withTitle: NSLocalizedString("angle", comment: ""),
                                   type: .angle),
            ItemDataModel.itemData(withTitle: NSLocalizedString("magnetic", comment: ""),
                                   type: .magnetic),
            ItemDataModel.itemData(withTitle: NSLocalizedString("quaternion", comment: ""),
                                   type: .quaternion)]
    }
}

enum ItemDataType {
    case none
    case acceleration
    case angularVelocity
    case angle
    case magnetic
    case quaternion
}
