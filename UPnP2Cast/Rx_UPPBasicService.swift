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
            self.base.browse(withObjectID: objectID, browseFlag: BrowseDirectChildren, filter: nil, startingIndex: nil, requestedCount: 100, sortCritera: nil, completion: { (dict : [AnyHashable : Any]?, e :Error?) in
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

extension Reactive where Base : UPPAVTransportService{
    
    func positionInfo() -> Observable<PositionInfo>{
        let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        let posi = Observable<PositionInfo>.create{ observable in
            self.base.positionInfo(withInstanceID: nil, completion: { (dict : [AnyHashable : Any]?, e :Error?) in
                if let dictUnwrapped = dict{
                    let posInfo = PositionInfo(dict: dictUnwrapped)
                    observable.onNext(posInfo)
                }else{
                    observable.onError(e!)
                }
            })
            
            return Disposables.create {
                observable.onCompleted()
            }
        }
        return interval.flatMap{ _ in
            return posi
        }
    }
    
}

class PositionInfo : Hashable{
    let track : String?
    let trackDuration : Int?
    let trackMetaData : UPPMediaItem?
    let trackURI : String?
    let relTime : Int?
    var hashValue: Int{
        return trackURI!.hashValue
    }
    
    public static func ==(lhs: PositionInfo, rhs: PositionInfo) -> Bool{
        return lhs.hashValue == rhs.hashValue
    }
    
    public required init(dict : [AnyHashable : Any]){
        self.track = dict["Track"] as? String
        let durationString = dict["TrackDuration"] as? String
        if let td = durationString{
            self.trackDuration = td.getIntFromTimeInterval()
        }else{
            self.trackDuration = nil
        }
        self.trackMetaData = dict["TrackMetaData"] as? UPPMediaItem
        self.trackURI = dict["TrackURI"] as? String
        let relString = dict["RelTime"] as? String
        if let rel = relString{
            self.relTime = rel.getIntFromTimeInterval()
        }else{
            self.relTime = nil
        }
    }

}
