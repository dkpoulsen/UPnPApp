//
//  AppColours.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 01/04/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import UIKit
import RxSwift

class AppColours {
    
    static let shared = AppColours()
    
    let primaryColour = PublishSubject<UIColor>()
    let secondaryColour = PublishSubject<UIColor>()
    let backgroudnColour = PublishSubject<UIColor>()
    
    let largeFont = PublishSubject<UIFont>()
    let mediumFont = PublishSubject<UIFont>()
    let smallFont = PublishSubject<UIFont>()

}
