//
//  DispatchSource+Extension.swift
//  BBCBCentralManager
//
//  Created by AidyBao on 2022/2/9.
//

import UIKit

extension DispatchSource {
    
    @discardableResult static func xt_makeECGTimer(timeInterval: Int, repeating: DispatchTimeInterval, handler: @escaping ()->Void) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(flags: [], queue: .global())
        timer.schedule(deadline: .now() + TimeInterval(timeInterval), repeating: repeating)
        timer.setEventHandler {
            DispatchQueue.main.async {
                handler()
            }
        }
        timer.resume()
        return timer
    }
    
    @discardableResult static func makeECGTimer(_ milliseconds: Int, handler: @escaping()->Void) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(flags: [], queue: .global())
        timer.schedule(deadline: .now(), repeating: .milliseconds(milliseconds))
        timer.setEventHandler {
            DispatchQueue.main.async {
                handler()
            }
        }
        timer.resume()
        return timer
    }
    
    @discardableResult static func makeCodeTimer(timeInterval: Double = 1, repeatCount:Int, handler:@escaping (DispatchSourceTimer, Int)->()) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(flags: [], queue: .global())
        var count = repeatCount
        timer.schedule(wallDeadline: .now(), repeating: timeInterval)
        timer.setEventHandler(handler: {
            count -= 1
            DispatchQueue.main.async {
                handler(timer, count)
            }
            if count <= 0 {
                timer.cancel()
            }
        })
        timer.resume()
        return timer
    }
}
