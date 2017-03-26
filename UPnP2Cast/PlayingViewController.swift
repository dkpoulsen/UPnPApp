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

class PlayingViewController: UIViewController {

    let selectedPlayback = SelectedPlaybackDevice.Shared
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
