//
//  AppColoursTableViewController.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 02/04/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import UIKit
import RxSwift

class AppColoursTableViewController: UIViewController, UITableViewDelegate {

    enum Colours {
        case primary
        case secondary
        case background
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dismissButton: UIButton!
    
    let table = Variable([Colours.primary, Colours.secondary, Colours.background])
    
    let appColours = AppColours.shared
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        
        self.dismissButton.rx.tap.asObservable().subscribe(onNext : {
            self.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
        
        table.asObservable().bindTo(self.tableView.rx.items(cellIdentifier: "Colours", cellType: ColourCell.self)){ (index , colour, cell) in
            switch(colour){
            case .primary:
                cell.name.text = "Primary"
                cell.colour.subscribe(onNext : {
                    self.appColours.primaryColour.onNext($0)
                }).addDisposableTo(self.disposeBag)
                break
            case .secondary:
                cell.name.text = "Secondary"
                cell.colour.subscribe(onNext : {
                    self.appColours.secondaryColour.onNext($0)
                }).addDisposableTo(self.disposeBag)
                break
            case .background:
                cell.name.text = "Background"
                cell.colour.subscribe(onNext : {
                    self.appColours.backgroundColour.onNext($0)
                }).addDisposableTo(self.disposeBag)
                break
            }
        }.addDisposableTo(disposeBag)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class ColourCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var rSlider: UISlider!
    @IBOutlet weak var gSlider: UISlider!
    @IBOutlet weak var bSlider: UISlider!
    @IBOutlet weak var oSlider: UISlider!
    
    @IBOutlet weak var colourView: UIView!
    
    let colour = PublishSubject<UIColor>()
    
    let disposeBag = DisposeBag()
    
    override func layoutSubviews() {
        Observable.combineLatest(rSlider.rx.value, gSlider.rx.value, bSlider.rx.value, oSlider.rx.value){$0}.subscribe(onNext : { r, g, b, o in
            let colour = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(o))
            self.colourView.backgroundColor = colour
            self.colour.onNext(colour)
        }).addDisposableTo(disposeBag)
    }
    
}
