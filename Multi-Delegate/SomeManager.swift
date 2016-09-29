//
//  SomeManager.swift
//  Multi-Delegate
//
//  Created by Chan on 16/9/29.
//  Copyright © 2016年 Chan. All rights reserved.
//

import UIKit
@objc protocol SomeManagerDelegate {
    func callBack()
    @objc optional func callback(msg:[String:String])
}

class SomeManager: NSObject {
    static let instance = SomeManager()
    static func shareInstance() -> SomeManager{
        return instance
    }
    func action() {
        operatDelegate { (delegate) in
            if let myDelegate = delegate as? SomeManagerDelegate {
                myDelegate.callBack()
                myDelegate.callback?(msg: ["msg":"hello world!"])
            }
        }
    }
    func addDelegate(delegate:SomeManagerDelegate){
        super.addDelegateObj(delegate: delegate as AnyObject?)
    }
}
