//
//  GameScene.swift
//  FlappyBirdWithVoiceSampleGame
//
//  Created by Sheng Bi on 4/1/17.
//  Copyright © 2017 Sheng Bi. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1
    static let Player    : UInt32 = 0b10
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player:SKSpriteNode!
    
    var score = 0
    
    var gameover = false
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.white
        
        // Add player
        player = SKSpriteNode(imageNamed: "Bird")
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.position = CGPoint(x: size.width * 0.2, y: size.height * 0.5)
        addChild(player)
        
        // Add score
        let scoreMessage = "Score: \(score)"
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.name = "scoreLabel"
        scoreLabel.text = scoreMessage
        scoreLabel.fontSize = 15
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: size.width * 0.2, y: size.height * 0.95)
        addChild(scoreLabel)
        
        // Create monster every 3 seconds
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: 3.0)
                ])), withKey: "createMonsters")
        
        // Set physics world
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
    }
    
    func updateScore() {
        
        let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabel?.text = "Score: \(score)"
    }
    
    func addMonster() {
        
        // Create monster
        let monster:SKSpriteNode
        monster = SKSpriteNode(imageNamed: "Ufo")
        monster.userData = NSMutableDictionary()
        monster.physicsBody = SKPhysicsBody(circleOfRadius: monster.size.width / 2)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height / 2, max: size.height - monster.size.height / 2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width / 2, y: actualY)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster (how long it will move over the screen)
        let actualDuration = random(min: CGFloat(5.0), max: CGFloat(10.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width / 2, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
        
        // Add score if no collision
        score = score + 1
        updateScore()
    }
    
    func playerDidCollideWithMonster(player: SKSpriteNode, monster: SKSpriteNode) {
        
        // If collision, game over
        gameover = true
        monster.removeFromParent()
    }
    
    func movePlayer(direction: String, speed: Int) {
        
        // Move up/down the player based on the speed
        if (direction == "up") {
            player.position = player.position + CGPoint(x: 0, y: speed)
            if (player.position.y > size.height - player.size.height / 2) {
                player.position.y = size.height - player.size.height / 2
            }
        } else {
            player.position = player.position - CGPoint(x: 0, y: speed)
        }
    }
    
    func isGameOver() -> Bool {
        
        // If player falls from the sky, game over
        if (player.position.y <= player.size.height / 2) {
            gameover = true
        }
        return gameover
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
            if let monster = firstBody.node as? SKSpriteNode, let
                player = secondBody.node as? SKSpriteNode {
                playerDidCollideWithMonster(player: player, monster: monster)
            }
        }
        
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}
