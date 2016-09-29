//
//  ViewController1.swift
//  Multi-Delegate
//
//  Created by Chan on 16/9/29.
//  Copyright © 2016年 Chan. All rights reserved.
//

import UIKit

class ViewController1: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        SomeManager.shareInstance().addDelegate(delegate: self)
    }

}
extension ViewController1:SomeManagerDelegate {
    func callBack() {
        title = NSStringFromClass(classForCoder)
    }
}
