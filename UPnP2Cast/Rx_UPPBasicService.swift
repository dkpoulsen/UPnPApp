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

extension Reactive where Base : UPPContentDirectoryService{

    func browse(objectID : String?) -> Observable<[UPPMediaItem]>{
        return Observable.create{ observable in
            self.base.browse(withObjectID: objectID, browseFlag: BrowseDirectChildren, filter: nil, startingIndex: nil, requestedCount: nil, sortCritera: nil, completion: { (dict : [AnyHashable : Any]?, e :Error?) in
                if let array = dict?["Result"] as? [UPPMediaItem]{
                    observable.onNext(array)
                }else{
                    observable.onError(e!)
                }
            })
            
            return Disposables.create {
                observable.onCompleted()
            }

        }
        
    }
}
