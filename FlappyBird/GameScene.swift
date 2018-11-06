//
//  GameScene.swift
//  FlappyBird
//
//  Created by Zhang, Frank on 08/05/2017.
//  Copyright © 2017 Zhang, Frank. All rights reserved.
//

import UIKit
import Foundation
import SpriteKit

enum layer: CGFloat {
    case background
    case foreground
    case player
}

enum gameState {
    case mainMenu
    case tutorial
    case play
    case faling
    case showScore
    case gameOver
}

struct physicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 1 << 0
    static let pipe: UInt32 = 1 << 1
    static let ground: UInt32 = 1 << 2
    static let score: UInt32 = 1 << 3
}

let kGravity:CGFloat = -1500.0
let kImpulse:CGFloat = 400

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    let worldNode = SKNode()
    var playableStart: CGFloat = 0
    var playableHeight: CGFloat = 0
    
    // MARK: - Music
    let dingAction = SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false)
    let flapAction = SKAction.playSoundFileNamed("flapping", waitForCompletion: false)
    let whackAction = SKAction.playSoundFileNamed("whack.wav", waitForCompletion: false)
    let fallingAction = SKAction.playSoundFileNamed("falling.wav", waitForCompletion: false)
    let hitGroundAction = SKAction.playSoundFileNamed("hitGround.wav", waitForCompletion: false)
    let popAction = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let coinAction = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    
    // MARK: - Sky color
    let skyColor: SKColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0)

    let player = SKSpriteNode(imageNamed: "bird-01")
    let scoreLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
    
    var state: gameState = .mainMenu
    var score = 0
    var firstTime = true
    
    override func didMove(to view: SKView) {
        self.backgroundColor = skyColor
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        addChild(worldNode)
        setBackground()
        setMainMenu()
//        setPlayer()
//        setScoreLabel()
        
        
        physicsWorld.contactDelegate = self
        
        
    }
    
    func setBackground() {
        // setland
        let groundTexture = SKTexture(imageNamed: "land")
        
        let moveGroundSprite = SKAction.moveBy(x: -groundTexture.size().width * 2.0, y: 0, duration: TimeInterval(0.02 * groundTexture.size().width * 2.0))
        let resetGroundSprite = SKAction.moveBy(x: groundTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))

        for i in 0..<2{
            let foreground = SKSpriteNode(texture: groundTexture)
            foreground.name = "ground"
            foreground.setScale(2.0)
            foreground.anchorPoint = CGPoint(x: 0, y: 0)
            foreground.position = CGPoint(x: CGFloat(i) * groundTexture.size().width * 2.0, y: 0)
            foreground.run(moveGroundSpritesForever)
            worldNode.addChild(foreground)
        }
        
        
        //set sky background
        let skyTexture = SKTexture(imageNamed: "sky")
        let moveSkySprite = SKAction.moveBy(x: -skyTexture.size().width * 2.0, y: 0, duration: TimeInterval(0.2 * skyTexture.size().width * 2.0))
        let resetSkySprite = SKAction.moveBy(x: skyTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveSkySpritesForever = SKAction.repeatForever(SKAction.sequence([moveSkySprite,resetSkySprite]))
        for i in 0..<2{
            let background = SKSpriteNode(texture: skyTexture)
            background.name = "sky"
            background.anchorPoint = CGPoint(x: 0, y: 0)
            background.setScale(2.0)
            background.position = CGPoint(x: CGFloat(i) * skyTexture.size().width * 2.0, y: groundTexture.size().height * 2.0)
            //        background.physicsBody = SKPhysicsBody(
            background.zPosition = -20
            background.run(moveSkySpritesForever)
            worldNode.addChild(background)
        }
        
        
        playableStart = groundTexture.size().height * 2.0
        playableHeight = self.frame.size.height - groundTexture.size().height * 2.0
        
        let groundLeft = CGPoint(x: 0, y: playableStart)
        let groundRight = CGPoint(x: size.width, y: playableStart)
        
        self.physicsBody = SKPhysicsBody(edgeFrom: groundLeft, to: groundRight)
        self.physicsBody?.categoryBitMask = physicsCategory.ground
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = physicsCategory.player
        
    }
    
    func setPlayer() {
        player.position = CGPoint(x: size.width * 0.2, y: playableHeight * 0.4 + playableStart)
        player.zRotation = 0
//        player.zPosition = layer.foreground.rawValue
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2.0)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        player.physicsBody?.categoryBitMask = physicsCategory.player
        player.physicsBody?.collisionBitMask = physicsCategory.ground | physicsCategory.pipe
        player.physicsBody?.contactTestBitMask = physicsCategory.ground | physicsCategory.pipe | physicsCategory.score
//        player.physicsBody?.usesPreciseCollisionDetection = true
        
        worldNode.addChild(player)
    }
    
    func setScoreLabel() {
        score = 0
        scoreLabel.position = CGPoint(x: self.frame.midX, y: 3 * self.frame.size.height / 4)
        scoreLabel.zPosition = 100
        scoreLabel.text = String(score)
        worldNode.addChild(scoreLabel)
    }
    
    func setMainMenu() {
        let mainMenu = SKSpriteNode(imageNamed: "menu")
        mainMenu.name = "menu"
        mainMenu.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        mainMenu.zPosition = 100
        worldNode.addChild(mainMenu)
    }
    
    func setTutorial() {
        let tutorial = SKSpriteNode(imageNamed: "tap")
        tutorial.name = "tutorial"
        tutorial.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        tutorial.zPosition = 100
        worldNode.addChild(tutorial)
        worldNode.enumerateChildNodes(withName: "menu") { (node, stop) in
            node.removeFromParent()
        }
        setPlayer()
    }
    
    func createObstacle(imageName: String) -> SKSpriteNode {
        let obstacleTexture = SKTexture(imageNamed: imageName)
        let obstacleNode = SKSpriteNode(texture: obstacleTexture)
        obstacleNode.name = "pipe"
        obstacleNode.zPosition = -10
        
        obstacleNode.physicsBody = SKPhysicsBody(rectangleOf: obstacleNode.size)
        obstacleNode.physicsBody?.isDynamic = false
        
        obstacleNode.physicsBody?.categoryBitMask = physicsCategory.pipe
        obstacleNode.physicsBody?.contactTestBitMask = 0
        obstacleNode.physicsBody?.contactTestBitMask = physicsCategory.player
        
        return obstacleNode
    }
    
    func spawnObstacle() {
        let pipeUp = createObstacle(imageName: "PipeUp")
        pipeUp.setScale(2.0)
        pipeUp.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        pipeUp.position = CGPoint(x: size.width + pipeUp.size.width / 2.0, y: CGFloat(arc4random()).truncatingRemainder(dividingBy: pipeUp.size.height * 0.5) + pipeUp.size.height  * 0.3)
        worldNode.addChild(pipeUp)
        
        let pipeDown = createObstacle(imageName: "PipeDown")
        pipeDown.setScale(2.0)
//        pipeDown.zRotation = .pi
        pipeDown.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        pipeDown.position = CGPoint(x: size.width + pipeUp.size.width / 2.0, y: pipeUp.position.y + pipeUp.size.height / 2.0 + 3.5 * player.size.height + pipeDown.size.height / 2.0)
        worldNode.addChild(pipeDown)
        
        let lowPoint = CGPoint(x: size.width + pipeUp.size.width + player.size.width / 2.0, y: 0)
        let heightPoint = CGPoint(x: lowPoint.x, y: self.frame.size.height)
        let scoreNode = SKNode()
        scoreNode.name = "score"
        scoreNode.physicsBody = SKPhysicsBody(edgeFrom: lowPoint, to: heightPoint)
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = physicsCategory.score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = physicsCategory.player
        worldNode.addChild(scoreNode)

        
        let move = SKAction.sequence([SKAction.moveBy(x: -(size.width + pipeUp.size.width) , y: 0, duration: TimeInterval(0.02 * (size.width + pipeUp.size.width))),
                                      SKAction.removeFromParent()])
        
        pipeUp.run(move)
        pipeDown.run(move)
        scoreNode.run(move)
        
        
    }
    
    func startSpawning() {
        let firstDelay = SKAction.wait(forDuration: 1.75)
        let spawn = SKAction.run(spawnObstacle)
        let everyDelay = SKAction.wait(forDuration: 4.0)
        let spawnSequence = SKAction.sequence([spawn, everyDelay])
        let foreverSpawn = SKAction.repeatForever(spawnSequence)
        let overallSequence = SKAction.sequence([firstDelay, foreverSpawn])
        
        run(overallSequence, withKey: "spawn")
        
    }
    
    func flappyBird() {
        let atlas = SKTextureAtlas(named: "bird")
        let f1 = atlas.textureNamed("bird-01")
        let f2 = atlas.textureNamed("bird-02")
        let f3 = atlas.textureNamed("bird-03")
        let f4 = atlas.textureNamed("bird-04")
        
        let birdFlyTextures = [f1,f2, f3, f4]
        
        let flyAction = SKAction.animate(with: birdFlyTextures, timePerFrame: 0.1)
        player.run(flyAction)
        
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 6))
        run(flapAction)

    }
    
    func reSet() {
        run(SKAction.wait(forDuration: 5.0))
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        state = .tutorial
        worldNode.removeAllChildren()
        setBackground()
        setPlayer()
        setScoreLabel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            switch state {
            case .mainMenu:
                setTutorial()
                state = .tutorial
            case .tutorial:
                physicsWorld.gravity = CGVector(dx: 0, dy: -8)
                if firstTime {
                    firstTime = false
                    setScoreLabel()
                    worldNode.enumerateChildNodes(withName: "tutorial") { (node, stop) in
                        node.removeFromParent()
                    }
                }
                startSpawning()
                state = .play
            case .play:
                flappyBird()
            case.showScore:
                setupScoreCard()
                state = .faling
            case .faling:
                reSet()
            default:
                break
            }
        }
    }
    
    func stopSpawnng() {
        removeAction(forKey: "spawn")
        
        worldNode.enumerateChildNodes(withName: "pipe") { (node, stop) in
            node.removeAllActions()
        }
        worldNode.enumerateChildNodes(withName: "sky") { (node, stop) in
            node.removeAllActions()
        }
        worldNode.enumerateChildNodes(withName: "ground") { (node, stop) in
            node.removeAllActions()
        }
        worldNode.enumerateChildNodes(withName: "score") { (node, stop) in
            node.removeAllActions()
        }
//        worldNode.enumerateChildNodes(withName: "scoreCard") { (node, stop) in
//            node.removeAllActions()
//        }

    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        switch state {
        case .play:
            let value = (player.physicsBody?.velocity.dy)! * ( (player.physicsBody?.velocity.dy)! < CGFloat(0) ? 0.003 : 0.001 )
            player.zRotation = min( max(-1, value), 0.5 )
        case .showScore:
            let value = (player.physicsBody?.velocity.dy)! * ( (player.physicsBody?.velocity.dy)! < CGFloat(0) ? 0.003 : 0.001 )
            player.zRotation = min( max(-1, value), 0.5 )
        default:
            break
        }
    }

    
    //MARK - Physics contact delegate
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == physicsCategory.player ? contact.bodyB : contact.bodyA
        
        if(other.categoryBitMask == physicsCategory.score){
            score += 1
            scoreLabel.text = String(score)
            run(coinAction)
            scoreLabel.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.1),
                                              SKAction.scale(to: 1.0, duration: 0.1)]))
        }else{
            let fallAction = SKAction.sequence([SKAction.run({ self.backgroundColor = SKColor.red}),
                                                SKAction.wait(forDuration: 0.05),
                                                SKAction.run({ self.backgroundColor = self.skyColor}),
                                                SKAction.wait(forDuration: 0.05)])
            run(SKAction.repeat(fallAction, count: 4))
//            setupScoreCard()
            state = .showScore
            run(SKAction.sequence([whackAction, SKAction.wait(forDuration: 0.5), fallingAction]))
            stopSpawnng()

        }
    }
    
    func getBestScore() -> Int {
        return UserDefaults.standard.integer(forKey: "BestScore")
    }
    
    func setBestScore(bestScore: Int) {
        UserDefaults.standard.set(bestScore, forKey: "BestScore")
        UserDefaults.standard.synchronize()
    }
    
    func setupScoreCard() {
        if score > getBestScore() {
            setBestScore(bestScore: score)
        }
        
        let scoreCard = SKSpriteNode(imageNamed: "scoreboard")
        scoreCard.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        scoreCard.zPosition = 200
        scoreCard.name = "scoreCard"
        worldNode.addChild(scoreCard)
        
        let lastScore = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        lastScore.fontSize = 17
        lastScore.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        lastScore.position = CGPoint(x: scoreCard.size.width * 0.3, y: scoreCard.size.height * 0.06)
        lastScore.zPosition = 220
        lastScore.text = String(score)
        scoreCard.addChild(lastScore)
        
        let bestScore = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        bestScore.fontSize = 17
        bestScore.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        bestScore.position = CGPoint(x: scoreCard.size.width * 0.3, y: -scoreCard.size.height * 0.08)
        bestScore.zPosition = 220
        bestScore.text = String(getBestScore())
        scoreCard.addChild(bestScore)
        
//        run(popAction)
    }

}
