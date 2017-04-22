//
//  ExtendViewController.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 01/04/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import UIKit

extension UIViewController{
    func setNavigationTitle(_ title : String){
        self.navigationController?.navigationBar.topItem?.title = title
    }
    
    func setupColourScheme(){
        
    }
    
    func dismiss(sender:AnyObject?){
        self.dismiss(animated: true, completion: nil)
    }
}
