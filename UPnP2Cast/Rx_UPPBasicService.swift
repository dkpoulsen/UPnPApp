//
//  Rx_UPPBasicService.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 26/02/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import Foundation
import CocoaUPnP
import RxSwift
import RxCocoa

extension Reactive where Base : UPPAVTransportService{
    
    func setAVTransportURI() -> Observable<Any>{
        Observable.create{
            
            $0.on(.next())
        }
        
    }
}
