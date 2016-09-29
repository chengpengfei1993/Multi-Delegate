//
//  NSObject+Extension.swift
//  CalculateCellHeight
//
//  Created by Chan on 16/9/28.
//  Copyright © 2016年 Chan. All rights reserved.
//

import Foundation
private var delegateBridgesKey = "delegateBridgesKey"
class WeakObjectBridge : NSObject {
    weak var weakObject : AnyObject?
    override init() {
        super.init()
    }
    init(object:AnyObject?) {
        super.init()
        weakObject = object
    }
}
extension NSObject {
    private var delegateBridges : Array<WeakObjectBridge> {
        get {
            var bridges = objc_getAssociatedObject(self, &delegateBridgesKey)
            if bridges == nil {
                bridges = Array<WeakObjectBridge>()
                objc_setAssociatedObject(self, &delegateBridgesKey, bridges, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
            
            return bridges as! Array<WeakObjectBridge>
        }
        set(newValue) {
            objc_setAssociatedObject(self, &delegateBridgesKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func addDelegate(delegate:AnyObject?) {
        var exist = false
        for (index,weakObjectBridge) in self.delegateBridges.enumerated().reversed() {
            if let weakobj = weakObjectBridge.weakObject {
                if delegate?.isEqual(weakobj) == true {
                    exist = true
                    break
                }
            }else {
                self.delegateBridges.remove(at: index)
            }
        }
    
        if exist == false {
            self.delegateBridges.append(WeakObjectBridge(object: delegate))
        }
        
    }
    
    func removeDelegate(delegate:NSObject?) {
        for (index,weakObjectBridge) in self.delegateBridges.enumerated().reversed() {
            if delegate?.isEqual(weakObjectBridge.weakObject) == true {
                self.delegateBridges.remove(at: index)
                break
            }
        }
    }
    
    func operatDelegate(cb: @escaping (_ delegate:AnyObject?) -> ()){
        for weakObjectBridge in self.delegateBridges {
            DispatchQueue.main.async {
                cb(weakObjectBridge.weakObject)
            }
        }
    }
}
