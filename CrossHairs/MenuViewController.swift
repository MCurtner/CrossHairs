//
//  MenuViewController.swift
//  CrossHairs
//
//  Created by Matthew Curtner on 12/27/15.
//  Copyright © 2015 Matthew Curtner. All rights reserved.
//

import UIKit
import GameKit

class MenuViewController: UIViewController, GKGameCenterControllerDelegate {
    
    // MARK: - Menu ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        authenticateLocalPlayer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Actions

    @IBAction func newGameButtonPressed(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("gameViewController") as! GameViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func continueGameButtonPressed(sender: AnyObject) {
    }

    
    @IBAction func leaderboardButtonPressed(sender: AnyObject) {
        let vc = self.view.window?.rootViewController
        let gc = GKGameCenterViewController()
        
        gc.gameCenterDelegate = self
        vc?.presentViewController(gc, animated: true, completion: nil)
    }
    
    
    // MARK: - GameKit Methods
    // GameKit Methods
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = { (viewController, error) -> Void in
            if viewController != nil {
                self.presentViewController(viewController!, animated: true, completion: nil)
            } else {
                print(error)
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
