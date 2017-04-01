//
//  GameOverScene.swift
//  FlappyBirdWithVoiceSampleGame
//
//  Created by Sheng Bi on 4/1/17.
//  Copyright © 2017 Sheng Bi. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, score:Int) {
        
        super.init(size: size)

        backgroundColor = SKColor.white
        
        let message = "Game Over. Score: \(score)"
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 30
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
