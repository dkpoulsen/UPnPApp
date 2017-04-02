//
//  AppColoursViewController.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 02/04/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import UIKit
import RxSwift

class AppColoursViewController: UIViewController {
    
    let appColours = AppColours.shared
    
    let colourDisposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        appColours.backgroudnColour.subscribe(onNext : {
            self.view.backgroundColor = $0
        }).addDisposableTo(colourDisposeBag)
    }
}
