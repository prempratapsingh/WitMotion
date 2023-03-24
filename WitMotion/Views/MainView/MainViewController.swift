
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
    
    // MARK: UI controls
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()

    private lazy var scanButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onScanButtonAction), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.setTitle(NSLocalizedString("stop_scan", comment: ""), for: .normal)
        button.setTitle(NSLocalizedString("scan", comment: ""), for: .selected)
        return button
    }()
    
    private lazy var aboutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(aboutButtonAction), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.setTitle(NSLocalizedString("about", comment: ""), for: .normal)
        button.setTitle(NSLocalizedString("about", comment: ""), for: .selected)
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.rowHeight = 50
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    
    // MARK: Private properties
    
    private var peripheralList: [WTBLEPeripheral] = []
    private var lastId: String?
    private var selectIndex: Int = 0
    
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.presentDetailsViewControllerIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = NSLocalizedString("device_scan", comment: "")

        
        // Set callback for discovered peripherals
        WTBLE.sharedInstance().bleCallback?.blockOnDiscoverPeripherals = { [weak self] central, peripheral, advertisementData, RSSI in
            guard let strongSelf = self else { return }
            strongSelf.addPeripheralDevice(with: peripheral, advertisementData: advertisementData, RSSI: RSSI)
        }
        
        peripheralList.removeAll()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = ""
    }
    
    
    // MARk: Private methods
    
    private func configureView() {
        let indicatorViewBarButton = UIBarButtonItem(customView: self.indicatorView)
        let scanBarButton = UIBarButtonItem(customView: self.scanButton)
        self.navigationItem.leftBarButtonItems = [indicatorViewBarButton, scanBarButton]
        
        let aboutBarButton = UIBarButtonItem(customView: self.aboutButton)
        self.navigationItem.rightBarButtonItem = aboutBarButton
        
        self.scanButton.isSelected = true
        
        self.view.addSubview(self.tableView)
        NSLayoutConstraint.activate([
            self.tableView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.tableView.safeAreaLayoutGuide.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            self.tableView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.tableView.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
    
    private func presentDetailsViewControllerIfNeeded() {
        let userDefault = UserDefaults.standard
        self.lastId = userDefault.object(forKey: "device_uuid") as? String
        
        if let id = lastId, !id.isEmpty {
            let controller = DetailViewController()
            self.navigationController?.pushViewController(controller, animated: false)
            self.lastId = nil
        }
    }
    
    private func addPeripheralDevice(with peripheral: CBPeripheral, advertisementData: [String: Any], RSSI: NSNumber) {
        for currentPeripheral in peripheralList {
            if let peripheral = currentPeripheral.peripheral,
               peripheral.identifier.uuidString == peripheral.identifier.uuidString {
                currentPeripheral.RSSI = RSSI
                tableView.reloadData()
                return
            }
        }
        
        if let blePeripheral = WTBLEPeripheral.peripheral(with: peripheral, advertisementData: advertisementData, RSSI: RSSI) {
            peripheralList.append(blePeripheral)
            tableView.reloadData()
        }
        
        if peripheral.identifier.uuidString == lastId {
            let controller = DetailViewController()
            controller.peripheral = WTBLEPeripheral.peripheral(with: peripheral, advertisementData: advertisementData, RSSI: RSSI)
            navigationController?.pushViewController(controller, animated: false)
            lastId = nil
        }
    }

    func beginConnectPeripheralWith() {
        if !self.scanButton.isSelected {
            self.onScanButtonAction()
        }
      
        if self.peripheralList.count + 1 > self.selectIndex {
            let controller = DetailViewController()
            let userDefault = UserDefaults.standard
            
            if self.selectIndex > 0 {
                let blePeripheral = self.peripheralList[self.selectIndex - 1]
                controller.peripheral = blePeripheral
                if let peripheral = blePeripheral.peripheral {
                    userDefault.set(peripheral.identifier.uuidString, forKey: "device_uuid")
                }
            } else {
                controller.peripheral = nil
                userDefault.set(NSLocalizedString("this_device", comment: ""), forKey: "device_uuid")
            }
            userDefault.synchronize()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    private func getRSSILevel(rssi: NSNumber) -> Int {
        var RSSILevel = 4
        let rssiValue = rssi.intValue
        if rssiValue > -60 {
            RSSILevel = 4
        } else {
            if rssiValue > -70 {
                RSSILevel = 3
            } else if rssiValue > -80 {
                RSSILevel = 2
            } else {
                RSSILevel = 1
            }
        }
        return RSSILevel
    }

    
    @objc private func onScanButtonAction() {
        self.scanButton.isSelected = !self.scanButton.isSelected;
        
        if self.scanButton.isSelected {
            WTBLE.sharedInstance().cancelScan()
            self.indicatorView.stopAnimating()
        } else {
            self.peripheralList.removeAll()
            self.tableView.reloadData()
            WTBLE.sharedInstance().startScan()
            self.indicatorView.startAnimating()
        }
    }
    
    @objc private func aboutButtonAction() {
        let aboutViewController = AboutAppViewController()
        self.navigationController?.pushViewController(aboutViewController, animated: true)
    }
}

// MARK: UITableViewDelegate and UITableViewDataSource methods

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripheralList.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        
        
        if indexPath.row == 0 {
            
            
            cell.display(
                title: NSLocalizedString("this_device", comment: ""),
                subTitle: NSLocalizedString("this_device_sensor_data", comment: ""),
                image: nil
            )
        } else {
            let blePeripheral = self.peripheralList[indexPath.row - 1]
            var deviceId = ""
            var deviceName = NSLocalizedString("unknown_device", comment: "")
            if let peripheral = blePeripheral.peripheral, let advertisementData = blePeripheral.advertisementData {
                deviceName = advertisementData[CBAdvertisementDataManufacturerDataKey] as? String ?? peripheral.name ?? NSLocalizedString("unknown_device", comment: "")
                deviceId = peripheral.identifier.uuidString
            }
            
            var rssiLevelImage: UIImage?
            if let rssi = blePeripheral.RSSI {
                let RSSILevel = self.getRSSILevel(rssi: rssi)
                switch RSSILevel {
                case 4:
                    rssiLevelImage = UIImage(named: "M4")
                case 3:
                    rssiLevelImage = UIImage(named: "M3")
                case 2:
                    rssiLevelImage = UIImage(named: "M2")
                case 1:
                    rssiLevelImage = UIImage(named: "M1")
                default:
                    break
                }
            }
            
            cell.display(
                title: deviceName,
                subTitle: deviceId,
                image: rssiLevelImage
            )
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectIndex = indexPath.row
        self.beginConnectPeripheralWith()
    }
}
