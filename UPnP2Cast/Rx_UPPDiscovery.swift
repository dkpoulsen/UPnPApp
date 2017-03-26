//
//  Rx_UPPDiscovery.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 18/02/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CocoaUPnP

class RxUPPDiscoveryDelegateProxy : DelegateProxy, UPPDiscoveryDelegate, DelegateProxyType {
    
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let service: UPPDiscovery = object as! UPPDiscovery
        service.addBrowserObserver(delegate as! UPPDiscoveryDelegate)
    }
    
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let service: UPPDiscovery = object as! UPPDiscovery
        let observers = service.value(forKey: "observers") as! NSSet
        let delegate = observers.first { this -> Bool in
            this is UPPDiscoveryDelegate
        }
        return delegate as AnyObject?
    }
    
    let didFindDevice = PublishSubject<UPPBasicDevice>()
    func discovery(_ discovery: UPPDiscovery, didFind device: UPPBasicDevice) {
        didFindDevice.on(.next(device))
    }
    
    let didRemoveDevice = PublishSubject<UPPBasicDevice>()
    func discovery(_ discovery: UPPDiscovery, didRemove device: UPPBasicDevice) {
        didRemoveDevice.on(.next(device))
    }
    
}

extension Reactive where Base: UPPDiscovery{

    public var delegate: DelegateProxy {
        return RxUPPDiscoveryDelegateProxy.proxyForObject(base)
    }
    
    public var didFindDevice: Observable<UPPBasicDevice>{
        let delegate = RxUPPDiscoveryDelegateProxy.proxyForObject(base)
        return delegate.didFindDevice
    }
    
    public var didRemoveDevice: Observable<UPPBasicDevice>{
        let delegate = RxUPPDiscoveryDelegateProxy.proxyForObject(base)
        return delegate.didRemoveDevice
    }
    
}

class RXUPPDiscovery: UPPDiscovery {
    
    let disposeBag = DisposeBag()
    let devices = Variable([UPPBasicDevice]())
    
    private static let shared = RXUPPDiscovery()
    override static func sharedInstance() -> RXUPPDiscovery{
        return shared
    }
    
    override init() {
        super.init()
        self.rx.didFindDevice.filter{!self.devices.value.contains($0)}.subscribe(onNext: {
            self.devices.value.append($0)
        }).addDisposableTo(disposeBag)
        self.rx.didRemoveDevice.filter{self.devices.value.contains($0)}.subscribe(onNext: {removeDevice in
            self.devices.value = self.devices.value.filter({ (device : UPPBasicDevice) -> Bool in
                removeDevice != device
            })
        }).addDisposableTo(disposeBag)
        self.startBrowsing(forServices: "ssdp:all")
    }
    
}
