//
//  DetailViewController.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 22/03/23.
//

import UIKit
import CoreMotion
import CoreBluetooth
import WTBLESDK

let ToDeg = 180/3.1415926
func degreesToRadians(_ angle: Double) -> Double {
    return angle / 180.0 * Double.pi
}

class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Public properties
    
    var peripheral: WTBLEPeripheral?
    
    // MARK: Private properties
    
    private var itemDataList: [ItemDataModel]?
    private var beginPoint: CGPoint = CGPoint(x: 0, y: 0)
    private var rightMargin: CGFloat = 0
    private var leftMargin: CGFloat = 0
    private var topMargin: CGFloat = 0
    private var bottomMargin: CGFloat = 0
    private var pathRef: CGMutablePath = CGMutablePath()
    private var selectDataType: ItemDataType = .none
    private var isFirstTimeLoad = false
    
    private var crossBtn: UIButton?
    private var refreshTimer: Timer?
    private var updateTimer: Timer?
    private var motionManager: CMMotionManager?
    private var rssi: NSNumber?
    
    private var cShwoDataArray = [Any]()
    private var coordinate = 0.0
    private var startRecord = false
    private var recordFileName: String?
    private var recordDataStr: String?
    
    private var fetchIndex = 0
    private let byteMagOutCmd: [UInt8] = [0xFF, 0xAA, 0x27, 0x3A, 0x00]
    private let byteQuaternioOutCmd: [UInt8] = [0xFF, 0xAA, 0x27, 0x51, 0x00]
    private let byteTempOutCmd: [UInt8] = [0xFF, 0xAA, 0x27, 0x40, 0x00]
    private let byteEqOutCmd: [UInt8] = [0xFF, 0xAA, 0x27, 0x64, 0x00]
    private let byteVersionOutCmd: [UInt8] = [0xFF, 0xAA, 0x27, 0x2E, 0x00]
    private let byteAccCaliCmd: [UInt8] = [0xFF, 0xAA, 0x01, 0x01, 0x00]
    private let byteMagCaliCmd: [UInt8] = [0xFF, 0xAA, 0x01, 0x07, 0x00]
    private let byteMagCaliFinishCmd: [UInt8] = [0xFF, 0xAA, 0x01, 0x00, 0x00]
    private let byteSaveCmd: [UInt8] = [0xFF, 0xAA, 0x00, 0x00, 0x00]
    private let byteDefaultCmd: [UInt8] = [0xFF, 0xAA, 0x00, 0x01, 0x00]
    private var byteRateCmd: [UInt8] = [0xFF, 0xAA, 0x03, 0x01, 0x00]
    private let byteUnlockCmd: [UInt8] = [0xFF, 0xAA, 0x69, 0x88, 0xB5]
    
    private var Version: Double = 0
    private var Eq: Double = 0
    private var EqLevel: Int = 5
    private var RssiLevel: Int = 4
    
    // MARK: - UI controls
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerItemView: UICollectionView!
    @IBOutlet weak var topDataBgView: UIView!
    @IBOutlet weak var itemTitleLabel0: UILabel!
    @IBOutlet weak var itemValueLabel0: UILabel!
    @IBOutlet weak var itemTitleLabel1: UILabel!
    @IBOutlet weak var itemValueLabel1: UILabel!
    @IBOutlet weak var itemTitleLabel2: UILabel!
    @IBOutlet weak var itemValueLabel2: UILabel!
    @IBOutlet weak var itemTitleLabel3: UILabel!
    @IBOutlet weak var itemValueLabel3: UILabel!
    @IBOutlet weak var EqImgIVew: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var rssiLevelImgView: UIImageView!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var historyRecordBtn: UIButton!
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        recordDataStr = ""
        topDataBgView.isHidden = true
        cShwoDataArray = []
        
        itemDataList = ItemDataModel.itemDataList()
        setUIHeaderItemView()
        
        selectDataType = .acceleration
        isFirstTimeLoad = true
        
        itemTitleLabel0.text = "AngleX(°)"
        itemTitleLabel1.text = "AngleY(°)"
        itemTitleLabel2.text = "AngleZ(°)"
        itemTitleLabel3.text = "T(°)"
        itemValueLabel0.text = String(format: "%0.2f", 0.0)
        itemValueLabel1.text = String(format: "%0.2f", 0.0)
        itemValueLabel2.text = String(format: "%0.2f", 10.5)
        itemValueLabel3.text = String(format: "%0.2f", 32.0)
        
        recordBtn.setTitle(NSLocalizedString("record", comment: ""), for: .normal)
        historyRecordBtn.setTitle(NSLocalizedString("historyRecord", comment: ""), for: .normal)
        
        let userDefault = UserDefaults.standard
        if let lastId = userDefault.string(forKey: "device_uuid"), lastId == "This device" {
            title = "This Device"
            motionManager = CMMotionManager()
            if motionManager!.isAccelerometerAvailable {
                motionManager!.startAccelerometerUpdates()
            }
            if motionManager!.isGyroAvailable {
                motionManager!.startGyroUpdates()
            }
            if motionManager!.isMagnetometerAvailable {
                motionManager!.startMagnetometerUpdates()
            }
            if motionManager!.isDeviceMotionAvailable {
                motionManager!.startDeviceMotionUpdates()
            }
            if updateTimer == nil {
                updateTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateDisplay), userInfo: nil, repeats: true)
                RunLoop.current.add(updateTimer!, forMode: .common)
            }
        } else {
            guard let peripheral = self.peripheral else { return }
            topDataBgView.isHidden = false
            setRightNavItems()
            setUpCrossBtn()
            title = peripheral.advertisementData?["kCBAdvDataLocalName"] as? String ?? peripheral.peripheral?.name ?? "Unknown device"
            
            WTBLE.sharedInstance().bleCallback?.blockOnConnectedPeripheral = { [weak self] central, peripheral in
                self?.tryReceiveData()
            }
            
            WTBLE.sharedInstance().bleCallback?.blockOnReadRssi = { [weak self] peripheral, RSSI, error in
                self?.onReadRssi(peripheral: peripheral, rssi: RSSI, error: error)
            }
            
            WTBLE.sharedInstance().bleCallback?.blockOnReadValueForCharacteristic = { [weak self] peripheral, characteristic, error in
                self?.onReadValue(peripheral: peripheral, characteristic: characteristic, error: error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if peripheral == nil {
            WTBLE.sharedInstance().bleCallback?.blockOnDiscoverPeripherals = { [weak self] central, peripheral, advertisementData, RSSI in
                self?.discoverPeripheralDevice(with: peripheral, advertisementData: advertisementData, RSSI: RSSI)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                WTBLE.sharedInstance().startScan()
            }
            if updateTimer == nil {
                updateTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateDisplay), userInfo: nil, repeats: true)
                RunLoop.current.add(updateTimer!, forMode: .common)
            }
        } else {
            connect()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancelConnect()
    }
    
    // MARK: Private methods
    
    private func setUpCrossBtn() {
        crossBtn = UIButton(type: .custom)
        crossBtn!.backgroundColor = UIColor.systemBlue
        crossBtn!.setTitle(NSLocalizedString("setting", comment: ""), for: .normal)
        crossBtn!.layer.cornerRadius = 27
        crossBtn!.frame = CGRect(x: 2, y: keyScreenHeight/2.0, width: 54, height: 54)
        view.addSubview(crossBtn!)
        crossBtn!.addTarget(self, action: #selector(moreBtnAction), for: .touchUpInside)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        crossBtn!.addGestureRecognizer(pan)
        
        rightMargin = keyScreenWidth - 30
        leftMargin = 30
        bottomMargin = keyScreenHeight - SRARUSBAR_TABAR_HEIGHT
        topMargin = SRARUSBAR_NAVIGATIONBAR_HEIGHT
        
        pathRef = CGMutablePath()
        pathRef.move(to: CGPoint(x: leftMargin, y: topMargin))
        pathRef.addLine(to: CGPoint(x: rightMargin, y: topMargin))
        pathRef.addLine(to: CGPoint(x: rightMargin, y: bottomMargin))
        pathRef.addLine(to: CGPoint(x: leftMargin, y: bottomMargin))
        pathRef.addLine(to: CGPoint(x: leftMargin, y: topMargin))
        pathRef.closeSubpath()
    }
    
    private func setRightNavItems() {
        let connectButton = UIButton(type: .custom)
        connectButton.setTitle(NSLocalizedString("disconnect", comment: ""), for: .normal)
        connectButton.setTitle(NSLocalizedString("connect", comment: ""), for: .selected)
        connectButton.setTitleColor(.white, for: .normal)
        connectButton.addTarget(self, action: #selector(onConnectButtonAction(_:)), for: .touchUpInside)
        let connectItem = UIBarButtonItem(customView: connectButton)
        navigationItem.rightBarButtonItems = [connectItem]
    }
    
    private func setUIHeaderItemView() {
        headerItemView.backgroundColor = UIColor.white
        headerItemView.showsHorizontalScrollIndicator = false
        headerItemView.showsVerticalScrollIndicator = false
        headerItemView.alwaysBounceHorizontal = false
        
        if #available(iOS 13.0, *) {
            headerItemView.backgroundColor = UIColor.link
        } else {
            headerItemView.backgroundColor = UIColor.blue
        }
        
        if let collectionViewLayout = headerItemView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width/5, height: 44)
            collectionViewLayout.minimumLineSpacing = 0
            collectionViewLayout.minimumInteritemSpacing = 0
            collectionViewLayout.scrollDirection = .horizontal
        }
        
        headerItemView.register(HeaderItemCell.self, forCellWithReuseIdentifier: HeaderItemCell.cellIdentifier)
    }
    
    @IBAction func recordAction(_ sender: Any) {
        startRecord.toggle()
        if startRecord {
            (sender as AnyObject).setTitle(NSLocalizedString("stop", comment: ""), for: .normal)
            let formatter = DateFormatter()
            formatter.dateFormat = "HHmmss"
            let time = formatter.string(from: Date())
            recordFileName = "Record(time)"
        } else {
            (sender as AnyObject).setTitle(NSLocalizedString("record", comment: ""), for: .normal)
        }
    }
    
    @IBAction func historyRecordAction(_ sender: Any) {
        let historyRecordVC = HistoryRecordViewController(nibName: "HistoryRecordViewController", bundle: .main)
        historyRecordVC.filePath = DataFileManager.fileRootPath()
        navigationController?.pushViewController(historyRecordVC, animated: true)
    }
    
    @objc func handlePan(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            beginPoint = pan.location(in: view)
        } else if pan.state == .changed {
            let nowPoint = pan.location(in: view)
            let offsetX = nowPoint.x - beginPoint.x
            let offsetY = nowPoint.y - beginPoint.y
            let centerPoint = CGPoint(x: beginPoint.x + offsetX, y: beginPoint.y + offsetY)
            if pathRef.contains(centerPoint) == true {
                crossBtn?.center = centerPoint
            } else {
                if centerPoint.y > bottomMargin {
                    if centerPoint.x < rightMargin && centerPoint.x > leftMargin {
                        crossBtn?.center = CGPoint(x: beginPoint.x + offsetX, y: bottomMargin)
                    }
                } else if centerPoint.y < topMargin {
                    if centerPoint.x < rightMargin && centerPoint.x > leftMargin {
                        crossBtn?.center = CGPoint(x: beginPoint.x + offsetX, y: topMargin)
                    }
                } else if centerPoint.x > rightMargin {
                    crossBtn?.center = CGPoint(x: rightMargin, y: beginPoint.y + offsetY)
                } else if centerPoint.x < leftMargin {
                    crossBtn?.center = CGPoint(x: leftMargin, y: beginPoint.y + offsetY)
                }
            }
        } else if pan.state == .ended || pan.state == .failed {
            // do nothing
        }
    }
    
    private func setStartRecord(startRecord: Bool) {
        self.startRecord = startRecord
        if !startRecord, let recordFileName = self.recordFileName {
            DataFileManager.shareActivityVC(self, recordFileName: recordFileName)
        }
    }
    
    private func discoverPeripheralDevice(with peripheral: CBPeripheral, advertisementData: [String: Any], RSSI: NSNumber) {
        let userDefaults = UserDefaults.standard
        guard let lastId = userDefaults.string(forKey: "device_uuid"), peripheral.identifier.uuidString == lastId else {
            return
        }
        
        self.peripheral = WTBLEPeripheral.peripheral(with: peripheral, advertisementData: advertisementData, RSSI: RSSI)
        self.title = self.peripheral!.advertisementData?["kCBAdvDataLocalName"] as? String ?? self.peripheral!.peripheral?.name ?? "Unknown device"
        WTBLE.sharedInstance().cancelScan()
        connect()
    }

    private func discoverPeripheralDevice(with peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        let userDefault = UserDefaults.standard
        guard let lastId = userDefault.string(forKey: "device_uuid"), peripheral.identifier.uuidString == lastId else {
            return
        }
        
        self.peripheral = WTBLEPeripheral.peripheral(with: peripheral, advertisementData: advertisementData, RSSI: rssi)
        self.title = self.peripheral!.advertisementData?["kCBAdvDataLocalName"] as? String ?? self.peripheral!.peripheral?.name ?? "Unknown device"
        
        WTBLE.sharedInstance().cancelScan()
        connect()
    }

    private func onReadRssi(peripheral: CBPeripheral, rssi: NSNumber, error: Error?) {
        self.rssi = rssi
        guard let rssiValue = self.rssi?.intValue else { return }
        if rssiValue > -60 {
            RssiLevel = 4
        } else {
            if rssiValue > -70 {
                RssiLevel = 3
            } else if rssiValue > -80 {
                RssiLevel = 2
            } else {
                RssiLevel = 1
            }
        }
        updateInfo()
    }

    private func connect() {
        guard let peripheral = self.peripheral, let cbPeripheral = peripheral.peripheral else { return }
        WTBLE.sharedInstance().tryConnectPeripheral(cbPeripheral)
    }

    private func cancelConnect() {
        if self.peripheral?.peripheral != nil {
            WTBLE.sharedInstance().cancelConnection()
        }
        refreshTimer?.invalidate()
        refreshTimer = nil
        updateTimer?.invalidate()
        updateTimer = nil
    }

    private func tryReceiveData() {
        WTBLE.sharedInstance().tryReceiveDataAfterConnected()
        if refreshTimer == nil {
            refreshTimer = Timer.scheduledTimer(
                timeInterval: 0.2,
                target: self,
                selector: #selector(onRefreshTimerTick(_:)),
                userInfo: nil,
                repeats: true
            )
        }
    }

    private func assembleChangeNameCommand(name: String) -> Data? {
        let commandStr = "WT\(name)\r\n"
        return commandStr.data(using: .utf8)
    }

    @objc func onRefreshTimerTick(_ timer: Timer) {
        if (WTBLE.sharedInstance().getDeviceType().rawValue == 0) {
            switch fetchIndex {
            case 1:
                readReg(byteCmd: byteVersionOutCmd)
            case 2:
                readReg(byteCmd: byteEqOutCmd)
            default:
                if (self.selectDataType == .angle) {
                    readReg(byteCmd: byteTempOutCmd)
                } else if (self.selectDataType == .magnetic) {
                    readReg(byteCmd: byteMagOutCmd)
                } else if (self.selectDataType == .quaternion) {
                    readReg(byteCmd: byteQuaternioOutCmd)
                }
                break
            }
        }
        if (fetchIndex > 10) {
            fetchIndex = 0
            WTBLE.sharedInstance().readRssi()
        }
        fetchIndex += 1
    }

    private func setSelectDataType(selectDataType: ItemDataType) {
        self.selectDataType = selectDataType
        itemTitleLabel0.text = nil
        itemTitleLabel1.text = nil
        itemTitleLabel2.text = nil
        itemTitleLabel3.text = nil
        itemValueLabel0.text = nil
        itemValueLabel1.text = nil
        itemValueLabel2.text = nil
        itemValueLabel3.text = nil
    }

    private func recordData(dx: Double, dy: Double, dz: Double, dq: Double, type: String) {
        if type == "a" {
            if startRecord, let dataString = self.recordDataStr, let fileName = self.recordFileName {
                DataFileManager.writeToTXTFile(with: dataString, recordFileName: fileName)
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-DD:HH:mm:ss.S"
            let time = formatter.string(from: Date())
            recordDataStr = "\(time),\(type),\(String(format: "%.4f", dx)),\(String(format: "%.4f", dy)),\(String(format: "%.4f", dz)),ver,\(Version),eq,\(String(format: "%.4f", Eq)),rssi,\(String(describing: rssi)) "
        } else if var recordDataStr = self.recordDataStr {
            if type == "T" {
                recordDataStr += ",\(type),\(String(format: "%.4f", dx))"
            } else if type == "q" {
                recordDataStr += ",\(type),\(String(format: "%.4f", dx)),\(String(format: "%.4f", dy)),\(String(format: "%.4f", dz)),\(String(format: "%.4f", dq))"
            } else {
                recordDataStr += ",\(type),\(String(format: "%.4f", dx)),\(String(format: "%.4f", dy)),\(String(format: "%.4f", dz))"
            }
        }
    }

    private func updateData(dx: Double, dy: Double, dz: Double, dq: Double, type: String) {
        
        coordinate += 0.1
        
        let at: CGFloat = type == "q" ? dq : 0
        let model = AccelerationModel(ax: dx, ay: dy, az: dz, at: at, coordinate: coordinate)
        if cShwoDataArray.count > 200 {
            cShwoDataArray.remove(at: 0)
        }
        
        cShwoDataArray.append(model)
    }

    // Update show values
    private func updateAcc(ax: Double, ay: Double, az: Double, total: Double) {
        if startRecord {
            recordData(dx: ax, dy: ay, dz: az, dq: 0, type: "a")
        }
        
        guard selectDataType == .acceleration else {
            return
        }
        
        itemTitleLabel0.text = "ax(g)"
        itemTitleLabel1.text = "ay(g)"
        itemTitleLabel2.text = "az(g)"
        itemTitleLabel3.text = "|a|(g)"
        
        itemValueLabel0.text = String(format: "%0.3f", ax)
        itemValueLabel1.text = String(format: "%0.3f", ay)
        itemValueLabel2.text = String(format: "%0.3f", az)
        itemValueLabel3.text = String(format: "%0.3f", sqrt(ax*ax+ay*ay+az*az))
        
        // Build data
        updateData(dx: ax, dy: ay, dz: az, dq: 0, type: "a")
        
    }

    private func updateInfo() {
        infoLabel.text = String(format: "Version:%d Eq:%.2f", Version, Eq)
        
        switch EqLevel {
        case 5:
            EqImgIVew.image = nil
        case 4:
            EqImgIVew.image = UIImage(named: "cell5")
        case 3:
            EqImgIVew.image = UIImage(named: "cell4")
        case 2:
            EqImgIVew.image = UIImage(named: "cell3")
        case 1:
            EqImgIVew.image = UIImage(named: "cell2")
        case 0:
            EqImgIVew.image = UIImage(named: "cell1")
        default:
            break
        }
        
        switch RssiLevel {
        case 4:
            rssiLevelImgView.image = UIImage(named: "M4")
        case 3:
            rssiLevelImgView.image = UIImage(named: "M3")
        case 2:
            rssiLevelImgView.image = UIImage(named: "M2")
        case 1:
            rssiLevelImgView.image = UIImage(named: "M1")
        default:
            break
        }
        
    }

    
    private func updateVersion(version: Double) {
        Version = version
        updateInfo()
    }
    
    private func updateEq(eq: Double) {
        Eq = eq
        if (Eq > 5.50) {
            if (Eq < 6.80) { EqLevel = 0 }
            else if (Eq < 7.35) { EqLevel = 1 }
            else if (Eq < 7.75) { EqLevel = 2 }
            else if (Eq < 8.50) { EqLevel = 3 }
            else { EqLevel = 4 }
        } else {
            if (Eq < 3.50) { EqLevel = 0 }
            else if (Eq < 3.65) { EqLevel = 1 }
            else if (Eq < 3.80) { EqLevel = 2 }
            else if (Eq < 4.00) { EqLevel = 3 }
            else { EqLevel = 4 }
        }
        updateInfo()
    }

    private func updateAngularY(wx: Double, wy: Double, wz: Double, total: Double) {
        if startRecord {
            recordData(dx: wx, dy: wy, dz: wz, dq: 0, type: "w")
        }
        if selectDataType != .angularVelocity {
            return
        }

        itemTitleLabel0.text = "wx(°/s)"
        itemTitleLabel1.text = "wy(°/s)"
        itemTitleLabel2.text = "wz(°/s)"
        itemTitleLabel3.text = "|w|(°/s)"
        itemValueLabel0.text = String(format: "%0.2f", wx)
        itemValueLabel1.text = String(format: "%0.2f", wy)
        itemValueLabel2.text = String(format: "%0.2f", wz)
        itemValueLabel3.text = String(format: "%0.2f", sqrt(wx * wx + wy * wy + wz * wz))

        updateData(dx: wx, dy: wy, dz: wz, dq: 0, type: "w")
    }

    private func updateAngle(with roll: Double, pitch: Double, yaw: Double) {
        var rads = 0.0
        var pitchAng = 0.0
        var rollhAng = 0.0
        
        if title == "This Device" {
            rads = degreesToRadians(180-yaw)
            //yaw = 180-yaw
            rollhAng = degreesToRadians(pitch)
        } else {
            rads = degreesToRadians(-yaw)
            rollhAng = degreesToRadians(-pitch)
        }
        
        pitchAng = degreesToRadians(roll)
        let transform = CGAffineTransform(rotationAngle: CGFloat(rads))
        
        let transformPitchAng = CGAffineTransform(rotationAngle: CGFloat(pitchAng))
        //bpImgView.transform = transformPitchAng
        
        var tempRoll = roll
        if tempRoll >= 90 {
            tempRoll = 90
        }
        if tempRoll <= -90 {
            tempRoll = -90
        }
        
        //bpImgView.center = CGPoint(x: 95, y: 95 + rollhAng * 56 * 2)
        
        if startRecord {
            recordData(dx: roll, dy: pitch, dz: yaw, dq: 0, type: "Angle")
        }
        
        if selectDataType != .angle {
            return
        }
        
        itemTitleLabel0.text = "AngleX(°)"
        itemTitleLabel1.text = "AngleY(°)"
        itemTitleLabel2.text = "AngleZ(°)"
        itemValueLabel0.text = String(format: "%0.2f", roll)
        itemValueLabel1.text = String(format: "%0.2f", pitch)
        itemValueLabel2.text = String(format: "%0.2f", yaw)
        
        updateData(dx: roll, dy: pitch, dz: yaw, dq: 0, type: "Angle")
    }

    private func updateTemperature(_ temperature: Double) {
        if startRecord {
            recordData(dx: temperature, dy: 0, dz: 0, dq: 0, type: "T")
        }
        
        if selectDataType != .angle {
            return
        }
        
        itemTitleLabel3.text = "T(°C)"
        itemValueLabel3.text = String(format: "%0.2f", temperature)
    }
    
    private func updateMagnetic(with mx: Double, my: Double, mz: Double, total: Double) {
        if startRecord {
            recordData(dx: mx, dy: my, dz: mz, dq: 0, type: "h")
        }

        if selectDataType != .magnetic {
            return
        }

        itemTitleLabel0.text = "hx"
        itemTitleLabel1.text = "hy"
        itemTitleLabel2.text = "hz"
        itemTitleLabel3.text = "|h|"
        itemValueLabel0.text = String(format: "%0.1f", mx)
        itemValueLabel1.text = String(format: "%0.1f", my)
        itemValueLabel2.text = String(format: "%0.1f", mz)
        itemValueLabel3.text = String(format: "%0.1f", sqrt(mx*mx+my*my+mz*mz))

        updateData(dx: mx, dy: my, dz: mz, dq: 0, type: "h")
    }

    private func updateQuaternion(with q0: Double, q1: Double, q2: Double, q3: Double) {
        if startRecord {
            recordData(dx: q0, dy: q1, dz: q2, dq: q3, type: "q")
        }

        if selectDataType != .quaternion {
            return
        }

        itemTitleLabel0.text = "q0:"
        itemTitleLabel1.text = "q1:"
        itemTitleLabel2.text = "q2:"
        itemTitleLabel3.text = "q3:"
        itemValueLabel0.text = String(format: "%0.3f", q0)
        itemValueLabel1.text = String(format: "%0.3f", q1)
        itemValueLabel2.text = String(format: "%0.3f", q2)
        itemValueLabel3.text = String(format: "%0.3f", q3)

        updateData(dx: q0, dy: q1, dz: q2, dq: q3, type: "q")
    }

    @IBAction func onConnectButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            cancelConnect()
        } else {
            connect()
        }
    }

    @objc func moreBtnAction() {
        let functionPopVC = FunctionPopViewController()
        functionPopVC.modalPresentationStyle = .overFullScreen
        present(functionPopVC, animated: true)

        functionPopVC.onVelocityBlock = { [weak self] in
            guard let byteSaveCmd = self?.byteSaveCmd else { return }
            self?.onVelocityButtonAction()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.writeReg(byteCmd: byteSaveCmd)
            }
        }

        functionPopVC.onAccelerometerBlock = { [weak self] in
            guard let byteAccCaliCmd = self?.byteAccCaliCmd else { return }
            self?.writeReg(byteCmd: byteAccCaliCmd)
            let alert = ToolManager.alertVC(
                withTitle: NSLocalizedString("Calibrating，please wait for 3 seconds", comment: ""),
                sureAction: {},
                cancelAction: {}
            )
            self?.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
                guard let byteSaveCmd = self?.byteSaveCmd else { return }
                let alert = ToolManager.alertVC(
                    withTitle: NSLocalizedString("AutoSave", comment: ""),
                    sureAction: {
                        self?.writeReg(byteCmd: byteSaveCmd)
                    },
                    cancelAction: {}
                )
                self?.present(alert, animated: true)
            }
        }

        functionPopVC.onMagneticBlock = { [weak self] in
            let alert = ToolManager.alertVC(
                withTitle: NSLocalizedString("CorrectedMagneticFieldOne", comment: ""),
                sureAction: { [weak self] in
                    guard let byteMagCaliCmd = self?.byteMagCaliCmd else { return }
                    self?.writeReg(byteCmd: byteMagCaliCmd)
                    let alert1 = ToolManager.alertVC(
                        withTitle: NSLocalizedString("CorrectedMagneticFieldTwo", comment: ""),
                        sureAction: { [weak self] in
                            guard let byteMagCaliFinishCmd = self?.byteMagCaliFinishCmd else { return }
                            self?.writeReg(byteCmd: byteMagCaliFinishCmd)
                            let alert = ToolManager.alertVC(
                                withTitle: NSLocalizedString("AutoSave", comment: ""),
                                sureAction: { [weak self] in
                                    guard let byteSaveCmd = self?.byteSaveCmd else { return }
                                    self?.writeReg(byteCmd: byteSaveCmd)
                                },
                                cancelAction: {})
                            self?.present(alert, animated: true)
                        },
                        cancelAction: nil)
                    self?.present(alert1, animated: true)
                },
                cancelAction: {}
            )
            self?.present(alert, animated: true)
        }

        functionPopVC.onResumeBlock = { [weak self] in
            guard let byteDefaultCmd = self?.byteDefaultCmd else { return }
            self?.writeReg(byteCmd: byteDefaultCmd)
        }

        functionPopVC.onRenameBlock = { [weak self] in
            self?.showRenameAlert()
        }
    }

    private func onVelocityButtonAction() {
        showActionSheetAlertWithTitle(
            title: NSLocalizedString("select_output_rate", comment: ""),
            actionTitles: ["0.2Hz", "0.5Hz", "1Hz", "2Hz", "5Hz", "10Hz", "20Hz", "50Hz", "100Hz", "200Hz"],
            itemSelectBlock: { [weak self] index in
                var timeFreq: Float = 0
                switch index {
                case 0:
                    timeFreq = 0.2
                case 1:
                    timeFreq = 0.5
                case 2:
                    timeFreq = 1
                case 3:
                    timeFreq = 2
                case 4:
                    timeFreq = 5
                case 5:
                    timeFreq = 10
                case 6:
                    timeFreq = 20
                case 7:
                    timeFreq = 50
                case 8:
                    timeFreq = 100
                case 9:
                    timeFreq = 200
                    self?.byteRateCmd[3] = 0x0b
                default:
                    break
                }
                if index != 9 {
                    self?.byteRateCmd[3] = UInt8(index + 1)
                }
                if self?.peripheral == nil {
                    self?.updateTimer?.invalidate()
                    self?.updateTimer = Timer.scheduledTimer(
                        timeInterval: 1 / TimeInterval(timeFreq),
                        target: self!,
                        selector: #selector(self?.updateDisplay),
                        userInfo: nil,
                        repeats: true)
                } else {
                    guard let byteRateCmd = self?.byteRateCmd else { return }
                    self?.writeReg(byteCmd: byteRateCmd)
                    let alert = ToolManager.alertVC(
                        withTitle: NSLocalizedString("AutoSave", comment: ""),
                        sureAction: { [weak self] in
                            guard let byteSaveCmd = self?.byteSaveCmd else { return }
                            self?.writeReg(byteCmd: byteSaveCmd)
                        },
                        cancelAction: {})
                    self?.present(alert, animated: true, completion: nil)
                }
        })
    }

    private func writeReg(byteCmd: [UInt8]) {
        if WTBLE.sharedInstance().getDeviceType().rawValue == 0 {
            WTBLE.sharedInstance().writeData(Data(byteCmd))
        } else {
            WTBLE.sharedInstance().writeData(Data(byteUnlockCmd))
            DispatchQueue.main.asyncAfter(deadline: .now() + 100 * Double(NSEC_PER_MSEC) / Double(NSEC_PER_SEC), execute: {
                WTBLE.sharedInstance().writeData(Data(byteCmd))
            })
        }
    }

    private func readReg(byteCmd: [UInt8]) {
        WTBLE.sharedInstance().writeData(Data(byteCmd))
    }

    // MARK: UICollectionViewDelegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let itemDataList = self.itemDataList else { return 0 }
        return itemDataList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let itemDataList = self.itemDataList else { return HeaderItemCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderItemCell.cellIdentifier, for: indexPath) as! HeaderItemCell
        
        if isFirstTimeLoad && indexPath.item == 0 {
            cell.isSelected = true
            isFirstTimeLoad = false
        }
        
        if indexPath.item < itemDataList.count {
            let item = itemDataList[indexPath.item]
            cell.titleLabel.text = item.title
        }
        
        return cell
    }

    func showActionSheetAlertWithTitle(title: String, actionTitles: [String], itemSelectBlock: ((Int) -> Void)?) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for i in 0..<actionTitles.count {
            let actionTitle = actionTitles[i]
            let action = UIAlertAction(title: actionTitle, style: .default) { _ in
                if let itemSelectBlock = itemSelectBlock {
                    itemSelectBlock(i)
                }
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemDataList = self.itemDataList else { return }
        if indexPath.item < itemDataList.count {
            // Clear data
            coordinate = 0
            cShwoDataArray.removeAll()
            
            let item = itemDataList[indexPath.item]
            selectDataType = item.dataType
        }
        
        if indexPath.item != 0 {
            let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
            cell?.isSelected = false
        }
    }

    private func showRenameAlert() {
        if WTBLE.sharedInstance().getDeviceType().rawValue == 1 {
            showToast("This type of device name can not be changed!")
            return
        }
        
        let alert = UIAlertController(
            title: NSLocalizedString("input_ble_device_name", comment: ""),
            message: nil,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        let doneAction = UIAlertAction(title: NSLocalizedString("done", comment: ""), style: .default) { [weak self] _ in
            if let name = alert.textFields?.first?.text {
                self?.rename(name)
            }
        }
        
        guard let peripheral = self.peripheral else { return }
        let currentName = peripheral.peripheral?.name ?? ""
        alert.addAction(cancelAction)
        alert.addAction(doneAction)
        alert.addTextField { textField in
            textField.placeholder = currentName
            NotificationCenter.default.addObserver(self, selector: #selector(self.alertTextFieldDidChange(_:)), name: UITextField.textDidChangeNotification, object: textField)
        }
        doneAction.isEnabled = false
        present(alert, animated: true, completion: nil)
    }

    private func showToast(_ msg: String) {
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func rename(_ name: String) {
        if let error = checkBLENameAvailable(withName: name) {
            self.deal(withUpdateBLENameInfo: error)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.deal(withUpdateBLENameInfo: nil)
        }
        
        let commandStr = "WT\(name)\r\n"
        WTBLE.sharedInstance().writeData(commandStr.data(using: .utf8)!)
    }

    @objc func alertTextFieldDidChange(_ notification: Notification) {
        if let alert = presentedViewController as? UIAlertController {
            if let textField = alert.textFields?.first {
                if let doneAction = alert.actions.last {
                    let length = textField.text?.lengthOfBytes(using: .utf8) ?? 0
                    doneAction.isEnabled = length > 0
                }
            }
        }
    }

    private func checkBLENameAvailable(withName name: String) -> Error? {
        var error: Error?
        var trimmedName = name.trimmingCharacters(in: .whitespaces)
        
        if !trimmedName.hasPrefix("WT") {
            var desc = NSLocalizedString("prefix_of_ble_device", comment: "")
            if desc.isEmpty {
                desc = "The name should has prefix of 'WT'"
            }
            error = NSError(domain: "com.wit-motion.wtble", code: -1, userInfo: [NSLocalizedDescriptionKey: desc])
        } else if let length = name.data(using: .utf8)?.count, length > 10 {
            var desc = NSLocalizedString("length_of_ble_device", comment: "")
            if desc.isEmpty {
                desc = "Length should be less than 10 bytes"
            }
            error = NSError(domain: "com.wit-motion.wtble", code: -1, userInfo: [NSLocalizedDescriptionKey: desc])
        }
        
        return error
    }

    private func rename(withName name: String) {
        if let error = checkBLENameAvailable(withName: name) {
            deal(withUpdateBLENameInfo: error)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.deal(withUpdateBLENameInfo: nil)
        }
        
        let commandStr = "WT\(name)\r\n"
        WTBLE.sharedInstance().writeData(commandStr.data(using: .utf8)!)
    }

    private func deal(withUpdateBLENameInfo error: Error?) {
        if let error = error {
            let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: NSLocalizedString("done", comment: ""), style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("change_name_success", comment: ""), message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: NSLocalizedString("done", comment: ""), style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func updateDisplay() {
        guard let motionManager = self.motionManager else { return }
        if motionManager.isAccelerometerAvailable {
            if let accelerometerData = motionManager.accelerometerData {
                updateAcc(ax: accelerometerData.acceleration.x, ay: accelerometerData.acceleration.y, az: accelerometerData.acceleration.z, total: 1)
            }
        }
        if motionManager.isGyroAvailable {
            if let gyroData = motionManager.gyroData {
                updateAngularY(wx: gyroData.rotationRate.x*ToDeg, wy: gyroData.rotationRate.y*ToDeg, wz: gyroData.rotationRate.z*ToDeg, total: 1)
            }
        }
        if motionManager.isMagnetometerAvailable {
            if let magnetometerData = motionManager.magnetometerData {
                updateMagnetic(with: magnetometerData.magneticField.x, my: magnetometerData.magneticField.y, mz: magnetometerData.magneticField.z, total: 1)
            }
        }
        if motionManager.isDeviceMotionAvailable {
            if let deviceMotion = motionManager.deviceMotion {
                updateAngle(with: deviceMotion.attitude.roll*ToDeg, pitch: deviceMotion.attitude.pitch*ToDeg, yaw: deviceMotion.attitude.yaw*ToDeg)
                updateQuaternion(with: deviceMotion.attitude.quaternion.w, q1: deviceMotion.attitude.quaternion.x, q2: deviceMotion.attitude.quaternion.y, q3: deviceMotion.attitude.quaternion.z)
            }
        }
    }

    private func onReadValue(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?) {
        guard let value = characteristic.value else { return }
        if WTBLE.sharedInstance().getDeviceType().rawValue == 0 {
            dealWithReadCharacteristicValue(value)
        } else {
            dealWithReadHC06CharacteristicValue(value)
        }
    }

    private func dealWithReadHC06CharacteristicValue(_ data: Data) {
        var dataRemain: Data?
        if dataRemain == nil {
            dataRemain = Data(data)
        } else {
            dataRemain!.append(data)
        }
        let length = dataRemain!.count
        var byte = [UInt8](repeating: 0, count: length)
        dataRemain!.copyBytes(to: &byte, count: length)
        var i = 0
        while i < length {
            if byte[i] != 0x55 {
                i += 1
                continue
            }
            if i+11 > length {
                i += 1
                break
            }
            if (byte[i+1] & 0xF0) != 0x50 {
                i += 1
                continue
            }
            var byteSum: UInt8 = 0
            for j in 0..<10 {
                byteSum += byte[i+j]
            }
            if byteSum != byte[i+10] {
                i += 1
                continue
            }
            
            let d1 = Double(Int16(byte[i+3]) << 8 | Int16(byte[i+2]))
            let d2 = Double(Int16(byte[i+5]) << 8 | Int16(byte[i+4]))
            let d3 = Double(Int16(byte[i+7]) << 8 | Int16(byte[i+6]))
            let d4 = Double(Int16(byte[i+9]) << 8 | Int16(byte[i+8]))
            var scale = 1.0
            switch byte[i+1] {
            case 0x51:
                scale = 1/32768.0*16
                updateAcc(ax: d1*scale, ay: d2*scale, az: d3*scale, total: sqrt(d1*d1+d2*d2+d3*d3)*scale)
                updateTemperature(d4/100)
            case 0x52:
                scale = 1/32768.0*2000
                updateAngularY(wx: d1*scale, wy: d2*scale, wz: d3*scale, total: sqrt(d1*d1+d2*d2+d3*d3)*scale)
                updateEq(eq: d4/100)
            case 0x53:
                let scale = 1/32768.0*180
                let roll = d1*scale
                let pitch = d2*scale
                let yaw = d3*scale
                self.updateAngle(with: roll, pitch: pitch, yaw: yaw)
                let toRad = 3.1415926/180.0
                let siny = sin(yaw*toRad/2)
                let cosy = cos(yaw*toRad/2)
                let sinp = sin(pitch*toRad/2)
                let cosp = cos(pitch*toRad/2)
                let sinr = sin(roll*toRad/2)
                let cosr = cos(roll*toRad/2)
                let q0 = cosr*cosp*cosy+sinr*sinp*siny
                let q1 = sinr*cosp*cosy-cosr*sinp*siny
                let q2 = cosr*sinp*cosy+sinr*cosp*siny
                let q3 = cosr*cosp*siny-sinr*sinp*cosy
                self.updateQuaternion(with: q0, q1: q1, q2: q2, q3: q3)
                self.updateVersion(version: d4)
            case 0x54:
                self.updateMagnetic(with: d1, my: d2, mz: d3, total: sqrt(d1*d1+d2*d2+d3*d3))
            default:
                break
            }
            i += 10
        }
        
        // TODO: Have to see how bytes could be replaced for Data type in below line of code
        // dataRemain.replaceBytes(in: 0..<i-1, withBytes: nil, length: 0)
    }
    
    private func dealWithReadCharacteristicValue(_ data: Data) {
        let length = data.count
        var byte = [UInt8](repeating: 0, count: length)
        data.copyBytes(to: &byte, count: length)
        var start = 0
        
        while start + 20 <= length {
            let header = Int(byte[start]) & 0xff
            let flag = Int(byte[start + 1]) & 0xff
            
            if header != 0x55 {
                print("not support characteristic value")
                return
            }
            
            if flag == 0x61 {
                let ax = Double(Int16(byte[start + 3]) << 8 | Int16(byte[start + 2])) / 32768.0 * 16
                let ay = Double(Int16(byte[start + 5]) << 8 | Int16(byte[start + 4])) / 32768.0 * 16
                let az = Double(Int16(byte[start + 7]) << 8 | Int16(byte[start + 6])) / 32768.0 * 16
                let a = sqrt(ax * ax + ay * ay + az * az)
                updateAcc(ax: ax, ay: ay, az: az, total: a)
                
                let wx = Double(Int16(byte[start + 9]) << 8 | Int16(byte[start + 8])) / 32768.0 * 2000
                let wy = Double(Int16(byte[start + 11]) << 8 | Int16(byte[start + 10])) / 32768.0 * 2000
                let wz = Double(Int16(byte[start + 13]) << 8 | Int16(byte[start + 12])) / 32768.0 * 2000
                let w = sqrt(wx * wx + wy * wy + wz * wz)
                updateAngularY(wx: wx, wy: wy, wz: wz, total: w)
                
                let roll = Double(Int16(byte[start + 15]) << 8 | Int16(byte[start + 14])) / 32768.0 * 180
                let pitch = Double(Int16(byte[start + 17]) << 8 | Int16(byte[start + 16])) / 32768.0 * 180
                let yaw = Double(Int16(byte[start + 19]) << 8 | Int16(byte[start + 18])) / 32768.0 * 180
                updateAngle(with: roll, pitch: pitch, yaw: yaw)
            } else if flag == 0x71 {
                let d1 = Double(Int16((Int(byte[start + 5]) << 8) | Int(byte[start + 4])))
                let d2 = Double(Int16((Int(byte[start + 7]) << 8) | Int(byte[start + 6])))
                let d3 = Double(Int16((Int(byte[start + 9]) << 8) | Int(byte[start + 8])))
                let d4 = Double(Int16((Int(byte[start + 11]) << 8) | Int(byte[start + 10])))

                switch byte[start + 2] {
                case 0x3A: // h
                    let total = sqrt(d1 * d1 + d2 * d2 + d3 * d3)
                    updateMagnetic(with: d1, my: d2, mz: d3, total: total)
                case 0x51: // q
                    updateQuaternion(with: d1 / 32768.0, q1: d2 / 32768.0, q2: d3 / 32768.0, q3: d4 / 32768.0)
                case 0x40:
                    updateTemperature(d1 / 100)
                case 0x2e:
                    let version = UInt16((Int(byte[start + 5]) << 8) | Int(byte[start + 4]))
                    updateVersion(version: Double(version))
                case 0x64:
                    updateEq(eq: d1 / 100)
                default:
                    break
                }
            }
        }
    }
}
