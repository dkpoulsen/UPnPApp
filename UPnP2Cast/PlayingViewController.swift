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
import IBAnimatable

class PlayingViewController: AppColoursViewController {
    
    let selectedPlayback = SelectedPlaybackDevice.Shared
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var image: AnimatableImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playPause: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftSliderLabel: UILabel!
    @IBOutlet weak var rightSliderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leftSliderLabel.text = ""
        rightSliderLabel.text = ""
        self.slider.minimumValue = 0
        if let splitV = self.splitViewController{
            navigationItem.leftBarButtonItem = splitV.displayModeButtonItem
        }else{
            let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss(sender:)))
            navigationItem.leftBarButtonItem = button
        }
        navigationItem.leftItemsSupplementBackButton = true
        let positionInfo = selectedPlayback.device.flatMapLatest{$0.avTransportService()!.rx.positionInfo()}
        positionInfo.map{$0.relTime}.filterNil().subscribe(onNext : {
            self.slider.value = Float($0)
            self.leftSliderLabel.text = $0.GetTimeStringMinAndSec()
        }).addDisposableTo(disposeBag)
        positionInfo.map{$0.trackDuration}.filterNil().subscribe(onNext : {
            self.rightSliderLabel.text = $0.GetTimeStringMinAndSec()
            self.slider.maximumValue = Float($0)
            
        }).addDisposableTo(disposeBag)
        
        let placeholder = UIImage(named: "placeholder")
        self.image.image = placeholder
        positionInfo.map{$0.trackMetaData}.filterNil().subscribe(onNext : {
            self.image.kf.setImage(with: $0.albumArtURL(), placeholder: placeholder, options: nil, progressBlock: nil, completionHandler: nil)
            self.titleLabel.text = $0.itemTitle
            
        }).addDisposableTo(disposeBag)
        
        let sliderValue = self.slider.rx.value.asObservable().skip(1).throttle(1, scheduler: MainScheduler.instance).map{Int($0).getUPnPTimeFormat()}
        let device = selectedPlayback.device
        Observable.combineLatest(sliderValue, device){$0}.subscribe(onNext : { value, device in
            device.avTransportService()?.setSeekWithInstanceID(nil, unit: "REL_TIME", target: value, success: nil)
        }).addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
