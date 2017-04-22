//
//  AppColourTableViewCell.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 02/04/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import UIKit
import RxSwift

class AppColourTableViewCell: UITableViewCell {
    
    let appColours = AppColours.shared
    
    let colourDisposeBag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        appColours.sharedAndCombined.subscribe(onNext : {
            self.setSubViewColour(subView: self, backgroundColour: $0.2, tintColour: $0.0)
        }).addDisposableTo(colourDisposeBag)
    }
 
    func setSubViewColour(subView : UIView, backgroundColour : UIColor, tintColour : UIColor){
        subView.backgroundColor = UIColor.clear
        if let label = subView as? UILabel{
            label.textColor = tintColour
        }
        for i in subView.subviews{
            setSubViewColour(subView: i, backgroundColour: UIColor.clear, tintColour: tintColour)
        }
    }
    
}
