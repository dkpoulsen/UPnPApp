//
//  AlbumCollectionViewController.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 26/03/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CocoaUPnP
import Kingfisher

private let reuseIdentifier = "Cell"

class AlbumCollectionViewController: AppColoursViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let disposeBag = DisposeBag()
    
    public var objectID : String? = nil
    public var server : UPPMediaServerDevice? = nil
    
    public let collectionArray = Variable([UPPMediaItem]())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let splitV = self.splitViewController{
            navigationItem.leftBarButtonItem = splitV.displayModeButtonItem
        }else{
            let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss(sender:)))
            navigationItem.leftBarButtonItem = button
        }
        navigationItem.leftItemsSupplementBackButton = true

        collectionView!.delegate = nil
        collectionArray.asObservable().bindTo(collectionView!.rx.items(cellIdentifier: "albumCell", cellType: AlbumCell.self)) { row, mediaItem, cell in
            cell.mediaItem = mediaItem
        }.addDisposableTo(disposeBag)
        collectionView!.rx.setDelegate(self).addDisposableTo(disposeBag)
        
        let selectedCell = collectionView.rx.itemSelected.asObservable().map{self.collectionView.cellForItem(at: $0)! as! AlbumCell}

        let selectedMedia = selectedCell.map{$0.mediaItem}.filterNil().filter{($0.firstPlayableResource() != nil)}
        
        let selectedFolder = selectedCell.map{$0.mediaItem}.filterNil().filter{$0.isContainer}.flatMap{self.server!.contentDirectoryService().rx.browse(objectID: $0.objectID)}

        let combined = Observable.zip(selectedCell, selectedFolder){$0}
        
        combined.subscribe(onNext : { media in
            let storyboard = UIStoryboard(name: "Main", bundle:nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AlbumViewController") as! AlbumViewController
            vc.server = self.server
            vc.mediaItem = media.0.mediaItem
            vc.tableViewArray.value = media.1
            self.navigationController?.pushViewController(vc, animated: true)
        }).addDisposableTo(disposeBag)
        
        Observable.combineLatest(selectedMedia, SelectedPlaybackDevice.Shared.device){$0}.subscribe(onNext : { (media : UPPMediaItem, device : UPPMediaRendererDevice) in
            device.avTransportService()?.setAVTransportURI((media.firstPlayableResource()?.resourceURLString)!, currentURIMetaData: UPPMetadataForItem(media), instanceID: "0", success: { (succes : Bool, e : Error?) in
                if(succes){
                    device.avTransportService()?.play(withInstanceID: "0", success: nil)
                    let storyboard = UIStoryboard(name: "Main", bundle:nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "PlayingViewController")
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }).addDisposableTo(disposeBag)
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 125, height: 150)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class AlbumCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    var mediaItem : UPPMediaItem?{
        didSet{
            if let url = mediaItem?.albumArtURL(){
                image.kf.setImage(with: url)
            }
            title.text = mediaItem?.itemTitle
        }
    }
}
