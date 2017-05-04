//
//  NSObject+Extension.swift
//  CalculateCellHeight
//
//  Created by Chan on 16/9/28.
//  Copyright © 2016年 Chan. All rights reserved.
//

import Foundation
private var DelegateBridgesKey = "delegateBridgesKey"
private var DeinitHandlerKey = "deinitHandlerKey"
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
    private var deinitHandler : DeallocHandlerObject {
        get{
            return objc_getAssociatedObject(self, &DeinitHandlerKey) as! DeallocHandlerObject
        }
        set(newValue){
            objc_setAssociatedObject(self, &DeinitHandlerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    private var delegateBridges : Array<WeakObjectBridge> {
        get {
            var bridges = objc_getAssociatedObject(self, &DelegateBridgesKey)
            if bridges == nil {
                bridges = Array<WeakObjectBridge>()
                objc_setAssociatedObject(self, &DelegateBridgesKey, bridges, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
            
            return bridges as! Array<WeakObjectBridge>
        }
        set(newValue) {
            objc_setAssociatedObject(self, &DelegateBridgesKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func addDelegateObj(delegate:AnyObject?) {
        var exist = false
        for (index,weakObjectBridge) in self.delegateBridges.enumerated().reversed() {
            if let weakobj = weakObjectBridge.weakObject {
                if delegate?.isEqual(weakobj) == true {
                    exist = true
                    break
                }
            }else {
                print(index)
            }
        }
        
        if exist == false {
            let weakObjectBridge = WeakObjectBridge(object: delegate)
            let obj = delegate as! NSObject
            let deinitHandler = DeallocHandlerObject(object: weakObjectBridge)
            deinitHandler.addDeinitHandler(handler: {[weak self] (weakObjectBridge) in
                if let index = self?.delegateBridges.index(of: weakObjectBridge){
                    self?.delegateBridges.remove(at: index)
                }
            })
            obj.deinitHandler = deinitHandler
            self.delegateBridges.append(weakObjectBridge)
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
        print(self.delegateBridges)
        for weakObjectBridge in self.delegateBridges {
            DispatchQueue.main.async {
                cb(weakObjectBridge.weakObject)
            }
        }
    }
}

