//
//  Data+ByteString.swift
//  BBCBCentralManager
//
//  Created by AidyBao on 2022/2/9.
//

import UIKit

extension Data {
    var byteString: String {
        var str = ""
        for i in bytes {
            str += String(format: "%02x", i)
        }
        return str
    }
    var bytes : [UInt8] {
        return [UInt8](self)
    }
}
