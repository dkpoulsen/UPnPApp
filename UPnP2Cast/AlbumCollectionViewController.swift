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

class AlbumCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let disposeBag = DisposeBag()
    
    public var objectID : String? = nil
    public var server : UPPMediaServerDevice? = nil
    
    private let collectionArray = Variable([UPPMediaItem]())

    override func viewDidLoad() {
        super.viewDidLoad()

        server?.contentDirectoryService().browse(withObjectID: objectID, browseFlag: BrowseDirectChildren, filter: nil, startingIndex: 0, requestedCount: 0, sortCritera: nil, completion: { (dict : [AnyHashable : Any]?, e :Error?) in
            if let array = dict?["Result"] as? [UPPMediaItem]{
                self.collectionArray.value = array
            }else{
                print(e)
            }
        })
        
        navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        collectionView!.delegate = nil
        collectionArray.asObservable().bindTo(collectionView!.rx.items(cellIdentifier: "albumCell", cellType: AlbumCell.self)) { row, mediaItem, cell in
            cell.mediaItem = mediaItem
        }.addDisposableTo(disposeBag)
        collectionView!.rx.setDelegate(self).addDisposableTo(disposeBag)

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let cellWidth = (width - 30) / 3 // compute your cell width
        return CGSize(width: cellWidth, height: cellWidth / 0.6)
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
            title.text = mediaItem?.albumTitle
        }
    }
}
