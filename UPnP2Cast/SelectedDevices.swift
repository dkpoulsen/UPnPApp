//
//  SelectedDevices.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 18/02/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import Foundation
import RxSwift
import CocoaUPnP
import UserNotifications
import BRYXBanner
import RxAppState

class SelectedServerDevice {
    private let disposeBag = DisposeBag()
    private var _device = PublishSubject<UPPMediaServerDevice>()
    private let sharedDevice : Observable<UPPMediaServerDevice>
    static let Shared = SelectedServerDevice()
    
    init() {
        sharedDevice = _device.throttle(1, scheduler: MainScheduler.instance).shareReplayLatestWhileConnected()
        sharedDevice.subscribe(onNext:{
            print($0.friendlyName)
            let banner = Banner(title: "Server connected", subtitle: "Connected to " + $0.friendlyName, image:nil, backgroundColor: UIColor.green)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
        }).addDisposableTo(disposeBag)
    }
    
    public var device : Observable<UPPMediaServerDevice> {
        get{
            return sharedDevice
        }
        set(value){
            value.subscribe(onNext :{
                self.setDevice(device: $0)
            }).addDisposableTo(disposeBag)
        }
    }
    
    public func setDevice(device : UPPMediaServerDevice){
        _device.on(.next(device))
        LastConnectedServerDevice.set(deviceID: device.friendlyName)
    }
}

class SelectedPlaybackDevice {
    private let disposeBag = DisposeBag()
    private var _device = PublishSubject<UPPMediaRendererDevice>()
    private let sharedDevice : Observable<UPPMediaRendererDevice>
    static let Shared = SelectedPlaybackDevice()
    
    init() {
        sharedDevice = _device.throttle(1, scheduler: MainScheduler.instance).shareReplayLatestWhileConnected()
        sharedDevice.subscribe(onNext:{
            print($0.friendlyName)
            let banner = Banner(title: "Playback connected", subtitle: "Connected to " + $0.friendlyName, image:nil, backgroundColor: UIColor.red)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
        }).addDisposableTo(disposeBag)
    }
    
    public var device : Observable<UPPMediaRendererDevice> {
        get{
            return sharedDevice
        }
        set(value){
            value.subscribe(onNext :{
                self.setDevice(device: $0)
            }).addDisposableTo(disposeBag)
        }
    }
    
    public func setDevice(device : UPPMediaRendererDevice){
        _device.on(.next(device))
        LastConnectedPlaybackDevice.set(deviceID: device.friendlyName)
    }
}

struct LastConnectedPlaybackDevice {
    
    private static let lastConnectedKeyForID = "lastConnectedPlayback"
    private static let ud = UserDefaults(suiteName: "group.dkpoulsen.container")!
    
    static func get() -> Observable<UPPMediaRendererDevice>{
        let lastID = ud.rx.observe(String.self, lastConnectedKeyForID).filterNil().distinctUntilChanged()
        let devices = RXUPPDiscovery.sharedInstance().devices.asObservable().map{$0.filter({ (device :UPPBasicDevice) -> Bool in
            device is UPPMediaRendererDevice
        })}.flatMap{list in
            return Observable.from(list)
            }.map{$0 as! UPPMediaRendererDevice}
        let found = Observable.combineLatest(lastID, devices){$0}.filter{
            $0.1.friendlyName == $0.0
            }.map{return $0.1}
        return found
    }
    
    static func set(deviceID : String){
        ud.set(deviceID, forKey: lastConnectedKeyForID)
        ud.synchronize()
    }
}

struct LastConnectedServerDevice {
    
    private static let lastConnectedKeyForID = "lastConnectedServer"
    private static let lastConnectedKeyForURL = "lastConnectedServerURL"
    private static let ud = UserDefaults(suiteName: "group.dkpoulsen.container")!
    
    static func get() -> Observable<UPPMediaServerDevice>{
        let lastID = ud.rx.observe(String.self, lastConnectedKeyForID).filterNil().distinctUntilChanged()
        let devices = RXUPPDiscovery.sharedInstance().devices.asObservable().map{$0.filter({ (device :UPPBasicDevice) -> Bool in
            device is UPPMediaServerDevice
        })}.flatMap{list in
            return Observable.from(list)
            }.map{$0 as! UPPMediaServerDevice}
        let found = Observable.combineLatest(lastID, devices){$0}.filter{
            $0.1.friendlyName == $0.0
            }.map{
                return $0.1
        }
        return found
    }
    
    static var url : Observable<String>{
        get{
            return ud.rx.observe(String.self, lastConnectedKeyForURL).filterNil().distinctUntilChanged()
        }
        set(value){
            
        }
    }
    
    static func set(deviceID : String){
        ud.set(deviceID, forKey: lastConnectedKeyForID)
        ud.synchronize()
    }
}
