//
//  ExtendWindow.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 01/04/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import UIKit

#if DEBUG
extension UIWindow {
    
    override open var canBecomeFirstResponder: Bool {
        return true
    }
    
    override open func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let storyboard = UIStoryboard(name: "Main", bundle:nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AppColours") as! AppColoursTableViewController
            self.rootViewController?.show(vc, sender: self)
        }
    }
}
#endif
