## 什么是多代理
用过环信SDK的同学应该对多代理不陌生了，请看下面代码：
```
 @method
 @brief 注册一个监听对象到监听列表中
 @discussion 把监听对象添加到监听列表中准备接收相应的事件
 @param delegate 需要注册的监听对象
 @param queue 通知监听对象时的线程
 @result
 */
- (void)addDelegate:(id<EMChatManagerDelegate>)delegate delegateQueue:(dispatch_queue_t)queue;
```
平时我们写得比较多的代理:
`
@property (nonatomic,weak) id<EMChatManagerDelegate>delegate;
`
写了上面属性后系统会默认生成set方法:
`- (void)setDelegate:(id<EMChatManagerDelegate>)delegate;
`
通过对两个接口的比较就不难看出：`单代理只能设置一个，而多代理可以设置多个，准确来说应该是多代理可以添加多个`
## 多代理有什么用
有些同学可能会问为什么要用多代理？用通知也能实现多个对象同时监听啊。是的，用监听通知的方式也能达到目的。

举个例子：服务端通过 socket 传来一个红点消息`{"type":21,"content":"某某消息"}`，
现在多个页面都想拿到这个消息来判断自己是否需要显示红点。

###用通知实现
#####监听通知
```
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveMsg:) name:@"kNotificationName_OnReceiveRedPointMsg" object:nil];
```
#####实现通知方法
```
- (void)onReceiveRedPointMsg:(NSNotification *)noti {
    NSDictionary *info = noti.userInfo;
    if ([info[@"type"] integerValue] == 21) {
        <#code#>
    }
}
```
###用代理实现
#####注册代理
```
[[RedPointManager sharedInstance] addDelegate:<#(id<RedPointManagerDelegate>)#>]
```
#####实现代理方法
```
- (void)redPointManagerDidReceive:(RedPointModel *)redPointModel {
    if (redPointModel.type == 21) {
        <#code#>
    }
}
```
显然，用代理实现更直观明了。

## 如何实现多代理
上面提到过`setDelegate:(id<EMChatManagerDelegate>)delegate 
`的方式是不可行的，当第二次`set`的时候第一次设置的代理就不被持有了。只能通过`addDelegate:(id<EMChatManagerDelegate>)delegate` 这种方式来实现。

是不是有点不淡定了，将代理对象`add`到数组(或者字典)中，会使对象`引用计数+1`，导致代理对象不能释放。没错，直接把代理加到数组中是不可行的。但是要持有多个代理对象，又要考虑到释放问题怎么搞。看看平时写的代理属性 `@property (nonatomic,weak) id<EMChatManagerDelegate>delegate;` 突然想到了用`weak`修饰不就行了吗。

所以，可以通过`桥接`来实现对多个代理对象的持有。
这样就好办了，数组持有桥接对象，桥接对象再拥有自己的delegate。
```
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
```
操作代理
```
func operatDelegate(cb: @escaping (_ delegate:AnyObject?) -> ()){
        for weakObjectBridge in self.delegateBridges {
            DispatchQueue.main.async {
                cb(weakObjectBridge.weakObject)
            }
        }
    }
```

具体调用
```
func action() {
        operatDelegate { (delegate) in
            if let myDelegate = delegate as? SomeManagerDelegate {
                myDelegate.callBack()
                myDelegate.callback?(msg: ["msg":"hello world!"])
            }
        }
    }
```

##Demo演示
![demo.gif](http://upload-images.jianshu.io/upload_images/958781-32bb08f43f93a050.gif?imageMogr2/auto-orient/strip)

##更新内容
之前写的有一个bug，`在addDelegate之后，在代理对象被释放之后，但是代理桥接对象还是存在的` ，虽然可以在代理对象的dealloc方法里手动移除代理，但我们没必要那样做`weak修饰的属性是不需要在dealloc里面置空的`。
在参考了[CYLDeallocBlockExecutor【你好 block，再见 dealloc】](https://github.com/ChenYilong/CYLDeallocBlockExecutor)之后，做了如下修改：
```
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
```

DeallocHandlerObject 代码如下：
```
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
```
借助DeallocHandlerObject我们就可以知道代理对象何时被释放了，从而达到自动移除不需要的代理桥接对象


##Demo下载
点击这里下载[demo](https://github.com/Czzzz/Multi-Delegate/tree/master/Multi-Delegate).
