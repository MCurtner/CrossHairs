//
//  GameViewController.swift
//  CrossHairs
//
//  Created by Matthew Curtner on 12/20/15.
//  Copyright (c) 2015 Matthew Curtner. All rights reserved.
//

import UIKit
import SpriteKit
import iAd

class GameViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIViewController.prepareInterstitialAds()
        self.interstitialPresentationPolicy = .Automatic
        
        let scene = GameScene(size: view.bounds.size)
        // Configure the view.
        let skView = self.view as! SKView
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: Menu Button Action
    
    @IBAction func menuButtonWasPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
