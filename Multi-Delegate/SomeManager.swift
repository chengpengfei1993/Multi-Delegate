//
//  SomeManager.swift
//  Multi-Delegate
//
//  Created by Chan on 16/9/29.
//  Copyright © 2016年 Chan. All rights reserved.
//

import UIKit
protocol SomeManagerDelegate {
    func callBack()
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
            }
        }
    }
    func addDelegate(delegate:SomeManagerDelegate){
        super.addDelegate(delegate: delegate as AnyObject?)
    }
}
