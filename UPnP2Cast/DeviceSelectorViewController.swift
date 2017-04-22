//
//  DeviceSelectorViewController.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 18/02/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CocoaUPnP

class DeviceSelectorViewController: AppColoursViewController {

    @IBOutlet weak var deviceTableView: UITableView!
    
    let disposeBag = DisposeBag()
    let discovery = RXUPPDiscovery.sharedInstance()
    let selectedPlayback = SelectedPlaybackDevice.Shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        discovery.devices.asObservable().map{$0.filter({ (device :UPPBasicDevice) -> Bool in
            device is UPPMediaRendererDevice
        })}.bindTo(deviceTableView.rx.items(cellIdentifier: "DeviceCell", cellType: DeviceTableViewCell.self)){(row, device, cell) in
            let device = (device as! UPPMediaRendererDevice)
            cell.device = device
            cell.textLabel?.text = device.friendlyName
        }.addDisposableTo(disposeBag)
        
        let itemSelected : Observable<IndexPath> = deviceTableView.rx.itemSelected.asObservable()
        selectedPlayback.device = itemSelected.map{self.deviceTableView.cellForRow(at: $0) as! DeviceTableViewCell}.map{$0.device}.filterNil()
        
        selectedPlayback.device = LastConnectedPlaybackDevice.get()
        
        selectedPlayback.device.subscribe(onNext : { device in
            self.tabBarController?.selectedIndex = 1
        }).addDisposableTo(disposeBag)
        itemSelected.map{self.deviceTableView.cellForRow(at: $0)}.subscribe(onNext : {
            $0?.editingAccessoryType = .checkmark
        }).addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class DeviceTableViewCell: AppColourTableViewCell {
    var device : UPPMediaRendererDevice?
}
