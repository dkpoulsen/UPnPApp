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
    
    let disposeBag = DisposeBag()
    
    let primaryColour = PublishSubject<UIColor>()
    let secondaryColour = PublishSubject<UIColor>()
    let backgroundColour = PublishSubject<UIColor>()
    
    let largeFont = PublishSubject<UIFont>()
    let mediumFont = PublishSubject<UIFont>()
    let smallFont = PublishSubject<UIFont>()
    
    let sharedAndCombined :  Observable<(UIColor, UIColor, UIColor)>
    
    let ud = UserDefaults.standard
    
    init() {
        sharedAndCombined = Observable.combineLatest(primaryColour, secondaryColour, backgroundColour){$0}.shareReplayLatestWhileConnected()
        
        sharedAndCombined.subscribe(onNext : { p, s, b in
            self.ud.setColor(color: p, forKey: "primaryColour")
            self.ud.setColor(color: s, forKey: "secondaryColour")
            self.ud.setColor(color: b, forKey: "backgroundColour")
        }).addDisposableTo(disposeBag)
        
        if let primary = ud.colorForKey(key: "primaryColour"){
            primaryColour.onNext(primary)
        }
        if let secondary = ud.colorForKey(key: "secondaryColour"){
            secondaryColour.onNext(secondary)
        }
        if let background = ud.colorForKey(key: "backgroundColour"){
            backgroundColour.onNext(background)
        }
    }
    
}
