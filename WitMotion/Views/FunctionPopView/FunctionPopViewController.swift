//
//  FunctionPopViewController.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 24/03/23.
//

import UIKit

class FunctionPopViewController: UIViewController {
    
    // MARK: UI Controls
    
    @IBOutlet weak var accCaliBtn: UIButton!
    @IBOutlet weak var rateBtn: UIButton!
    @IBOutlet weak var restoreBtn: UIButton!
    @IBOutlet weak var magCaliBtn: UIButton!
    @IBOutlet weak var renameBtn: UIButton!
    @IBOutlet weak var cancleBtn: UIButton!
    
    // MARK: Public properties
    
    var onAccelerometerBlock: (() -> Void)?
    var onMagneticBlock: (() -> Void)?
    var onVelocityBlock: (() -> Void)?
    var onResumeBlock: (() -> Void)?
    var onRenameBlock: (() -> Void)?
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        accCaliBtn.setTitle(NSLocalizedString("AccCali", comment: ""), for: .normal)
        rateBtn.setTitle(NSLocalizedString("Rate", comment: ""), for: .normal)
        restoreBtn.setTitle(NSLocalizedString("Restore", comment: ""), for: .normal)
        magCaliBtn.setTitle(NSLocalizedString("MagCali", comment: ""), for: .normal)
        renameBtn.setTitle(NSLocalizedString("Rename", comment: ""), for: .normal)
        cancleBtn.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
    }
    
    // MARK: - Private methods
    
    @IBAction func closeBtnAction(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onAccelerometerButtonAction(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        onAccelerometerBlock?()
    }
    
    @IBAction func onMagneticButtonAction(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        onMagneticBlock?()
    }
    
    @IBAction func onVelocityButtonAction(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        onVelocityBlock?()
    }
    
    @IBAction func onResumeButtonAction(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        onResumeBlock?()
    }
    
    @IBAction func onRenameButtonAction(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        onRenameBlock?()
    }
}
