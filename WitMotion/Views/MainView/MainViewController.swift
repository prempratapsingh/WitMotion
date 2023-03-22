
//
//  MainViewController.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 22/03/23.
//

import UIKit
import CoreBluetooth
import WTBLESDK


class MainViewController: UIViewController {
    
    var peripheralList: [WTBLEPeripheral] = []
    var indicatorView: UIActivityIndicatorView!
    var scanButton: UIButton!
    var aboutButton: UIButton!
    var lastId: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
        customRightButtonItems()
        let userDefault = UserDefaults.standard
        lastId = userDefault.object(forKey: "device_uuid") as? String
        
//        if let lastId = lastId {
//            let controller = DetailViewController()
//            navigationController?.pushViewController(controller, animated: false)
//            self.lastId = nil
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Device Scan"
        
        // Set callback for discovered peripherals
        WTBLE.sharedInstance().bleCallback?.blockOnDiscoverPeripherals = { [weak self] central, peripheral, advertisementData, RSSI in
            guard let self = self else { return }
            self.addPeripheralDevice(with: peripheral, advertisementData: advertisementData, RSSI: RSSI)
        }
        
        peripheralList.removeAll()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = ""
    }
    
    func customRightButtonItems() {
        indicatorView = UIActivityIndicatorView(style: .gray)
        indicatorView.hidesWhenStopped = true
        
        scanButton = UIButton(type: .custom)
        scanButton.addTarget(self, action: #selector(onScanButtonAction(sender:)), for: .touchUpInside)
        scanButton.setTitle(NSLocalizedString("stop_scan", comment: ""), for: .normal)
        scanButton.setTitle(NSLocalizedString("scan", comment: ""), for: .selected)
        scanButton.setTitleColor(.white, for: .normal)
        scanButton.setTitleColor(.white, for: .selected)
        
        aboutButton = UIButton(type: .custom)
        aboutButton.addTarget(self, action: #selector(aboutButtonAction(sender:)), for: .touchUpInside)
        aboutButton.setTitle(NSLocalizedString("about", comment: ""), for: .normal)
    }
}
