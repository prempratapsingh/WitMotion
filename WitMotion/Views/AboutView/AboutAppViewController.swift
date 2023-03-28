//
//  AboutAppViewController.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 23/03/23.
//

import UIKit

class AboutAppViewController: UIViewController {
    
    // MARK: - UI Controls
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var functionIntroductionTitleLabel: UILabel!
    @IBOutlet weak var helpTitleLabel: UILabel!
    @IBOutlet weak var versionUpdateTileLabel: UILabel!
    @IBOutlet weak var privacyAgreementBtn: UIButton!
    
    // MARK: - LifeCycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("about", comment: "")
        self.functionIntroductionTitleLabel.text = NSLocalizedString("functionIntroduction", comment: "")
        self.helpTitleLabel.text = NSLocalizedString("helpCenter", comment: "")
        self.versionUpdateTileLabel.text = NSLocalizedString("versionUpdate", comment: "")
        self.privacyAgreementBtn.setTitle(String(format: "《%@》", NSLocalizedString("privacyAgreement", comment: "")), for: .normal)
    }
    
    // MARK: - Private methods
    
    @IBAction func functionIntroduction(_ sender: Any) {
        self.navigationController?.pushViewController(FunctionIntroductionViewController(), animated: true)
    }
    
    @IBAction func helpAction(_ sender: Any) {
        let alertController = UIAlertController(title: "提示", message: "如有疑问请联系官方邮箱：kevin@wit-motion.com", preferredStyle: .alert)
        let cancelAlertAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAlertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func versionUpdate(_ sender: Any) {
        if let url = URL(string: "https://apps.apple.com/cn/app/witmotion/id1504360719") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func privacyAgreement(_ sender: Any) {
        self.navigationController?.pushViewController(PrivacyAgreementViewController(), animated: true)
    }
}
