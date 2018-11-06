//
//  GameViewController.swift
//  FlappyBird
//
//  Created by Zhang, Frank on 08/05/2017.
//  Copyright © 2017 Zhang, Frank. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as! SKView? {
            let gameScene = GameScene(size: CGSize(width: view.frame.size.width, height: view.frame.size.height))
            
            gameScene.scaleMode = .aspectFill
            
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsDrawCount = true
            view.ignoresSiblingOrder = true
//            view.showsPhysics = true
            
            view.presentScene(gameScene)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
