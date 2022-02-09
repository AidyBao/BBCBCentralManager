//
//  BBPeripheralViewController.swift
//  BBCBCentralManager
//
//  Created by AidyBao on 2022/2/8.
//

import UIKit
import CoreBluetooth

struct BluetoothConstants {
//    static let ECGServiceUUID = CBUUID(string: "49535343-FE7D-4AE5-8FA9-9FAFD205E455")
//    static let ECGCharacteristicUUID = CBUUID(string: "49535343-1E4D-4BD9-BA61-23C647249616")
    
    static let ECGServiceUUID = CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
    static let ECGCharacteristicUUID = CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e")
    
    static let MacAddressServiceUUIDString = "180A"//UUID = Device Information
    static let MacAddressCharacteristicUUIDString = "2A23"//UUID = System ID
}


class BBPeripheralViewController: UIViewController {
    
    
    
    var connectPer: CBPeripheral!
    var cbManager: CBCentralManager!
    
    static func show(superV: UIViewController, cbManager: CBCentralManager, connPeripheral:CBPeripheral?) {
        let vc = BBPeripheralViewController()
        vc.connectPer = connPeripheral
        vc.cbManager = cbManager
        superV.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        connectPer.delegate = self
        cbManager.delegate = self
        cbManager.connect(connectPer, options: nil)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cbManager.cancelPeripheralConnection(connectPer)
        cbManager.delegate = nil
        connectPer.delegate = nil
        connectPer = nil
        cbManager = nil
    }
}

extension BBPeripheralViewController: CBCentralManagerDelegate {
    /**判断手机蓝牙状态*/
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //print(central.state.rawValue)
        switch central.state {
        case .poweredOn:
            //retrievePeripheral()
            break
        case .poweredOff:
            break
        case .resetting:
            break
        case .unauthorized:
            break
        case .unsupported:
            break
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    /** 发现符合要求的外设 */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
    }
    
    /***/
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        //TODO: Performing Long-Term Actions in the Background
        let peripherals = dict[CBCentralManagerOptionRestoreIdentifierKey]
        
    }
    
    /**连接失败**/
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
       
    }
    
    /** 连接成功 */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    
    /**蓝牙设备断开连接**/
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectPer = nil
    }

    ///蓝牙重新连接
    private func retrievePeripheral() {
        
    }
}


extension BBPeripheralViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        getDistance(rssi: RSSI)
    }
    
    ///根据RSSI计算距离
    func getDistance(rssi: NSNumber) {
        let power = (labs(rssi.intValue) - 59)/(10*2)
        let dis: Float = powf(10.0, Float(power))
        //print("距离 = \(dis)，RSSI = \(rssi)")
    }
    
    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        if error == nil {
            print("error=\(error)")
        }
    }
    
    /** 发现服务 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    /** 发现特征 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("service.uuid = \(service.uuid)")
       
        guard let serviceCharacteristics = service.characteristics else { return }


        for characteristic: CBCharacteristic in serviceCharacteristics {
            peripheral.readValue(for: characteristic)
        }

        if service.uuid == BluetoothConstants.ECGServiceUUID {
            for characteristic: CBCharacteristic in serviceCharacteristics {
                print("characteristic.uuid = \(characteristic.uuid)")
                if characteristic.uuid == BluetoothConstants.ECGCharacteristicUUID {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    /** 接收到数据 */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        guard let characteristicData = characteristic.value else { return }
        //print("characteristicData = \(characteristicData)")

        calculateBatteryValue(characteristicData)
        
    }
    
    func calculateBatteryValue(_ data: Data) {
        
        let adcValue = data.byteString.suffix(4)
        let adcDecimal = Int(adcValue, radix: 16)
        print(data.byteString)
        print("adcValue=\(adcValue)","adcDecimal=\(adcDecimal)")
    }
    
    /** 订阅状态 */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        
    }
    
    /** 写入数据 */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        
    }
}
