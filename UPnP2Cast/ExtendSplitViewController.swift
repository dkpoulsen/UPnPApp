//
//  ExtendSplitViewController.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 26/03/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import UIKit

extension UISplitViewController {
    var primaryViewController: UIViewController? {
        return self.viewControllers.first
    }
    
    var secondaryViewController: UIViewController? {
        return self.viewControllers.count > 1 ? self.viewControllers[1] : nil
    }
}
