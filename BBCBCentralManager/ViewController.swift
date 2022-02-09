//
//  ViewController.swift
//  BBCBCentralManager
//
//  Created by AidyBao on 2022/2/8.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    @IBOutlet weak var tabView: UITableView!
    ///连接时间
    internal var scanTimer: DispatchSourceTimer?
    var per: CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabView.backgroundColor = UIColor.white
        tabView.register(UITableViewCell.self, forCellReuseIdentifier: "bbcell")
        let refreshBtn = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshAction))
        self.navigationItem.rightBarButtonItem = refreshBtn
        
        self.scanPeripheral()

    }

    @objc func refreshAction() {
        self.devices.removeAll()
        self.tabView.reloadData()
        self.scanPeripheral()
    }
    
    func scanPeripheral() {
        if manager.state == .poweredOn {
            self.manager.scanForPeripherals(withServices: nil, options: nil)
            self.scanTimer = DispatchSource.makeCodeTimer(repeatCount: 10) { timer, count in
                if count <= 0 {
                    self.manager.stopScan()
                    if self.devices.isEmpty {//未扫描到
                        print("未发现设备，请确保设备开启且在附近")
                        return
                    }
                    self.tabView.reloadData()
                }
            }
        }
    }
    
    lazy var manager: CBCentralManager = {
        let mger = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: "CBCentralManagerOptionRestoreIdentifierKey"])
        return mger
    }()
    
    lazy var devices: Array<CBPeripheral> = {
        let list = Array<CBPeripheral>()
        return list
    }()
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "bbcell", for: indexPath)
        cell.textLabel?.text = devices[indexPath.row].name
        return cell
    }

    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        manager.stopScan()
        if let peri = devices[indexPath.row] as? CBPeripheral {
            per = peri
            BBPeripheralViewController.show(superV: self, cbManager: self.manager, connPeripheral: self.per)
        }
    }
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.scanPeripheral()
            break
        case .poweredOff:
            break
        case .resetting:
            break
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.name)
        if !devices.contains(peripheral), let name = peripheral.name, !name.isEmpty {
            devices.append(peripheral)
        }
    }
    
    /** 发现服务 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
    }
    
    /** 发现特征 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        
    }
}
