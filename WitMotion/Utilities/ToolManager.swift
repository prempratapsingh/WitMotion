//
//  ToolManager.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 24/03/23.
//

import UIKit

class ToolManager {
    class func alertVC(
        withTitle title: String,
        sureAction: (() -> Void)?,
        cancelAction: (() -> Void)?) -> UIAlertController {
            
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let cancelAct = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { _ in
            if let cancelAction = cancelAction {
                cancelAction()
            }
        }
        let action = UIAlertAction(title: NSLocalizedString("done", comment: ""), style: .default) { _ in
            if let sureAction = sureAction {
                sureAction()
            }
        }
        if sureAction != nil {
            alert.addAction(action)
        }
        if cancelAction != nil {
            alert.addAction(cancelAct)
        }
        return alert
    }
}
