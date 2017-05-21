//
//  ServerBrowseViewController.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 20/02/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import UIKit
import RxSwift
import CocoaUPnP
import RxCocoa

class ServerBrowseViewController: AppColoursViewController {

    @IBOutlet weak var deviceTableView: UITableView!
    
    let disposeBag = DisposeBag()
    let discovery = RXUPPDiscovery.sharedInstance()
    let selectedServer = SelectedServerDevice.Shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        discovery.devices.asObservable().map{$0.filter({ (device :UPPBasicDevice) -> Bool in
            device is UPPMediaServerDevice
        })}.bindTo(deviceTableView.rx.items(cellIdentifier: "serverCell", cellType: ServerTableViewCell.self)){(row, device, cell) in
            cell.device = device as! UPPMediaServerDevice
            cell.textLabel?.text = device.friendlyName
            }.addDisposableTo(disposeBag)
    
        let itemSelected : Observable<IndexPath> = deviceTableView.rx.itemSelected.asObservable()
        
        selectedServer.device = itemSelected.map{self.deviceTableView.cellForRow(at: $0) as! ServerTableViewCell}.map{$0.device}.filterNil()
        
        selectedServer.device = LastConnectedServerDevice.get()
        
        selectedServer.device.throttle(0.2, scheduler: MainScheduler.instance).subscribe(onNext : { device in
            let storyboard = UIStoryboard(name: "Main", bundle:nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "mediaViewController") as! MediaBrowseViewController
            
            device.contentDirectoryService().browse(withObjectID: nil, browseFlag: BrowseDirectChildren, filter: nil, startingIndex: 0, requestedCount: 0, sortCritera: nil, completion: { (dict : [AnyHashable : Any]?, e :Error?) in
                if let array = dict?["Result"] as? [UPPMediaItem]{
                    for m in array{
                        print(m.objectClass)
                    }
                    vc.tableViewArray.value = array
                    vc.server = device
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    print(e)
                }
            })
        }).addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class ServerTableViewCell: AppColourTableViewCell {
    
    var device : UPPMediaServerDevice! = nil
    
}
