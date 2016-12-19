//
//  ViewController.swift
//  KNAutoLayoutPaddingFix
//
//  Created by vbn on 2016/12/19.
//  Copyright © 2016年 vbn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label1: UILabel!
    
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var label2HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var label3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            KNAutoLayoutPaddingFix.fixViews(views: [self.label2], axis: [.KNAutoLayoutPaddingFixAxisHorizontal,.KNAutoLayoutPaddingFixAxisVertical])
            self.label2HeightConstraint.constant = 0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3, execute: { 
                KNAutoLayoutPaddingFix.restoreViews(views: [self.label2])
                self.label2HeightConstraint.constant = 21
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

