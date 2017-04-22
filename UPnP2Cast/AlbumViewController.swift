//
//  AlbumViewController.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 27/03/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CocoaUPnP
import RxOptional

class AlbumViewController: AppColoursViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var mediaTableView: UITableView!
    
    let disposeBag = DisposeBag()

    public var server : UPPMediaServerDevice? = nil
    public let tableViewArray = Variable([UPPMediaItem]())
    public var mediaItem : UPPMediaItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        image.kf.setImage(with: mediaItem?.albumArtURL())
        albumLabel.text = mediaItem?.albumTitle
        artistLabel.text = mediaItem?.artist
        
        mediaTableView.register(MediaTableViewCell.self, forCellReuseIdentifier: "mediaCell")

        tableViewArray.asObservable().bindTo(mediaTableView.rx.items(cellIdentifier: "mediaCell", cellType: MediaTableViewCell.self)){(row, mediaItem, cell) in
            cell.mediaItem = mediaItem
            cell.textLabel?.text = mediaItem.itemTitle
            }.addDisposableTo(disposeBag)
        
        let selectedCell = mediaTableView.rx.itemSelected.asObservable().map{self.mediaTableView.cellForRow(at: $0) as! MediaTableViewCell}.shareReplayLatestWhileConnected()
        
        let selectedMedia = selectedCell.map{$0.mediaItem}.filterNil().filter{($0.firstPlayableResource() != nil)}

        Observable.combineLatest(selectedMedia, SelectedPlaybackDevice.Shared.device){$0}.subscribe(onNext : { (media : UPPMediaItem, device : UPPMediaRendererDevice) in
            device.avTransportService()?.setAVTransportURI((media.firstPlayableResource()?.resourceURLString)!, currentURIMetaData: UPPMetadataForItem(media), instanceID: "0", success: { (succes : Bool, e : Error?) in
                if(succes){
                    device.avTransportService()?.play(withInstanceID: "0", success: nil)
                }
            })
        }).addDisposableTo(disposeBag)
        
       let some =  "".lowercased()
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
