//
//  MediaBrowseViewController.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 22/02/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CocoaUPnP
import RxOptional


class MediaBrowseViewController: AppColoursViewController {
    
    @IBOutlet weak var mediaTableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    public var objectID : String? = nil
    public var server : UPPMediaServerDevice? = nil
    
    public let tableViewArray = Variable([UPPMediaItem]())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaTableView.register(MediaTableViewCell.self, forCellReuseIdentifier: "mediaCell")

        tableViewArray.asObservable().bindTo(mediaTableView.rx.items(cellIdentifier: "mediaCell", cellType: MediaTableViewCell.self)){(row, mediaItem, cell) in
            cell.mediaItem = mediaItem
            cell.textLabel?.text = mediaItem.itemTitle
            }.addDisposableTo(disposeBag)
        
        let selectedCell = mediaTableView.rx.itemSelected.asObservable().map{self.mediaTableView.cellForRow(at: $0) as! MediaTableViewCell}.shareReplayLatestWhileConnected()
        
        let selectedMedia = selectedCell.map{$0.mediaItem}.filterNil().filter{($0.firstPlayableResource() != nil)}
        let selectedFolder = selectedCell.map{$0.mediaItem}.filterNil().filter{$0.isContainer}.flatMap{self.server!.contentDirectoryService().rx.browse(objectID: $0.objectID)}
        let selectedAlbumContainer = selectedFolder.filter{$0.contains(where: { item -> Bool in
            item.objectClass == "object.container.album.musicAlbum" ||
            item.objectClass == "object.container.genre.musicGenre" ||
            item.objectClass == "object.container.person.musicArtist" ||
            item.objectClass == "object.item.videoItem" ||
            item.objectClass == "object.container.person"
        })}
        let selectedContainer = selectedFolder.filter{!$0.contains(where: { item -> Bool in
            item.objectClass == "object.container.album.musicAlbum" ||
            item.objectClass == "object.container.genre.musicGenre" ||
            item.objectClass == "object.container.person.musicArtist" ||
            item.objectClass == "object.item.videoItem" ||
            item.objectClass == "object.container.person"
        })}
        
        selectedContainer.subscribe(onNext : { media in
            let storyboard = UIStoryboard(name: "Main", bundle:nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "mediaViewController") as! MediaBrowseViewController
            vc.server = self.server
            vc.tableViewArray.value = media
            self.navigationController?.pushViewController(vc, animated: true)
        }).addDisposableTo(disposeBag)
        
        selectedAlbumContainer.subscribe(onNext : { album in
            let storyboard = UIStoryboard(name: "Main", bundle:nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "albumCollectionViewController") as! AlbumCollectionViewController
            vc.server = self.server
            vc.collectionArray.value = album
            let naviVC = UINavigationController(rootViewController: vc)
            self.splitViewController!.showDetailViewController(naviVC, sender: nil)
        }).addDisposableTo(disposeBag)
        
        Observable.combineLatest(selectedMedia, SelectedPlaybackDevice.Shared.device){$0}.subscribe(onNext : { (media : UPPMediaItem, device : UPPMediaRendererDevice) in
            device.avTransportService()?.setAVTransportURI((media.firstPlayableResource()?.resourceURLString)!, currentURIMetaData: UPPMetadataForItem(media), instanceID: "0", success: { (succes : Bool, e : Error?) in
                if(succes){
                    device.avTransportService()?.play(withInstanceID: "0", success: nil)
                }
            })
        }).addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class MediaTableViewCell: UITableViewCell {
    
    var mediaItem : UPPMediaItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
