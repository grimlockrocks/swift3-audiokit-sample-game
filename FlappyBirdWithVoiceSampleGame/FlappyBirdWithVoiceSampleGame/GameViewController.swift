//
//  GameViewController.swift
//  FlappyBirdWithVoiceSampleGame
//
//  Created by Sheng Bi on 4/1/17.
//  Copyright © 2017 Sheng Bi. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AudioKit

class GameViewController: UIViewController {
    
    var skView:SKView! = nil
    var gameScene:GameScene! = nil
    
    let audioEngine = AVAudioEngine()
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    var lastFrequency = 0.0
    var lastAmplitude = 0.0
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the view
        skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        
        // Start the game
        startGame()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        gameScene = nil
        skView = nil
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func getAudioAnalysis() {
        
        // Get audio frequency & amplitude
        if (tracker.amplitude > 0.1) {
            lastFrequency = tracker.frequency
            lastAmplitude = tracker.amplitude
        } else {
            lastFrequency = 0.0
            lastAmplitude = 0.0
        }
        
        // Move player
        movePlayer()
        
        // Game over control
        if (gameScene.isGameOver()) {
            
            // Clean up
            timer.invalidate()
            AudioKit.stop()
            
            gameScene.removeAllActions()
            gameScene.removeAllChildren()
            
            // Present game over scene
            let gameOverScene = GameOverScene(size: view.bounds.size, score: gameScene.score)
            skView.presentScene(gameOverScene)
            
            // Restart the game after 3 seconds
            Timer.scheduledTimer(timeInterval: 3,
                                 target: self,
                                 selector: #selector(GameViewController.startGame),
                                 userInfo: nil,
                                 repeats: false)
        }
        
    }
    
    func movePlayer() {
        
        // Define player's movement based on audio frequency & amplitude
        let direction:String
        var speed:Int
        if (lastAmplitude < 0.2) {
            direction = "down"
            speed = 10
        } else {
            direction = "up"
            speed = Int(lastAmplitude / 0.1) * Int(lastFrequency / 100)
            if (speed % 5 >= 1) {
                speed = speed * (speed % 5)
            }
        }
        gameScene.movePlayer(direction: direction, speed: speed)
    }
    
    func startGame() {
        
        // Present the game scene
        let reveal = SKTransition.doorsOpenHorizontal(withDuration: 1)
        gameScene = GameScene(size: view.bounds.size)
        skView.presentScene(gameScene, transition: reveal)
        
        // Set up audio capture
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
        AudioKit.output = silence
        AudioKit.start()
        
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(GameViewController.getAudioAnalysis),
                                     userInfo: nil,
                                     repeats: true)
    }

}
