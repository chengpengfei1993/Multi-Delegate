//
//  DeallocHandlerObject.swift
//  Multi-Delegate
//
//  Created by apple on 2017/5/4.
//  Copyright © 2017年 Chan. All rights reserved.
//

import Foundation
typealias DeinitHandler = (WeakObjectBridge) -> Void
class DeallocHandlerObject: NSObject {
    var deinitHandler : DeinitHandler?
    weak var weakObjectBridge : WeakObjectBridge!
    init(object:WeakObjectBridge!) {
        super.init()
        weakObjectBridge = object
    }
    func addDeinitHandler(handler:@escaping DeinitHandler){
        deinitHandler = handler
    }
    deinit {
        deinitHandler?(weakObjectBridge)
    }
}
