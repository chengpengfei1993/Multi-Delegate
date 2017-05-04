//
//  ViewController.swift
//  Multi-Delegate
//
//  Created by Chan on 16/9/29.
//  Copyright © 2016年 Chan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        SomeManager.shareInstance().addDelegate(delegate: self)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        SomeManager.shareInstance().action()
    }
}

extension ViewController:SomeManagerDelegate {
    func callBack() {
        title = NSStringFromClass(classForCoder)
    }
    func callback(msg: [String : String]) {
        print(msg)
    }
}


