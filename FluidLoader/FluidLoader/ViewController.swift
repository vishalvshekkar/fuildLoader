//
//  ViewController.swift
//  FluidLoader
//
//  Created by Vishal on 30/08/16.
//  Copyright © 2016 Vishal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let layer = WigglySpin(withNumberOfItems: 6)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.darkGrayColor()
        view.layer.addSublayer(layer)
        layer.color = UIColor.redColor()
        spin(nil)
    }
    
    // Wire these up to two UIButtons on your Storyboard. But for now I'll just call the first above.
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        layer.startAnimating()
//    }
    
    @IBAction func spin(sender: AnyObject?) {
        layer.startAnimating()
    }
    
    @IBAction func halt(sender: AnyObject) {
        layer.stopAnimating()
    }


}

