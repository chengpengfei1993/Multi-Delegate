//
//  ViewController2.swift
//  Multi-Delegate
//
//  Created by Chan on 16/9/29.
//  Copyright © 2016年 Chan. All rights reserved.
//

import UIKit

class ViewController2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        SomeManager.shareInstance().addDelegate(delegate: self)
    }
    @IBAction func click(_ sender: AnyObject) {
         SomeManager.shareInstance().action()
    }
}

extension ViewController2:SomeManagerDelegate {
    func callBack() {
        title = NSStringFromClass(classForCoder)
    }
}
