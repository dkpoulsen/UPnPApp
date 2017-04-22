//
//  PlayingViewController.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 24/03/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import CocoaUPnP

class PlayingViewController: AppColoursViewController {

    let selectedPlayback = SelectedPlaybackDevice.Shared
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playPause: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let splitV = self.splitViewController{
            navigationItem.leftBarButtonItem = splitV.displayModeButtonItem
        }else{
            let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss(sender:)))
            navigationItem.leftBarButtonItem = button
        }
        navigationItem.leftItemsSupplementBackButton = true
        /*selectedPlayback.device.flatMapLatest{$0.avTransportService()!.rx.trackLength()}.subscribe(onNext : {
            print($0)
        }).addDisposableTo(disposeBag)
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
