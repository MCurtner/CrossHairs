//
//  GameScene.swift
//  CrossHairs
//
//  Created by Matthew Curtner on 12/20/15.
//  Copyright (c) 2015 Matthew Curtner. All rights reserved.
//

import SpriteKit
import GameKit

class GameScene: SKScene {
    
    // SKSpriteNode Arrays
    var verticalSquaresArray = [SKSpriteNode]()
    var horizontalSquaresArray = [SKSpriteNode]()
    
    // CGPoint Arrays
    var horizontalPosArray: [CGPoint]!
    var verticalPosArray: [CGPoint]!
    var movingSquareHorizontalPosArray: [CGPoint]!
    var movingSquareVerticalPosArray: [CGPoint]!
    
    // Label Nodes
    var levelLabel = SKLabelNode()
    var remainingLabel = SKLabelNode()
    var remainingCount = SKLabelNode()
    var tapToStartLabel = SKLabelNode()
    var personalBestLabel = SKLabelNode()
    var personalBestCountLabel = SKLabelNode()
    
    var level = 1
    var movesRemaining = 1
    var maxLevel = NSUserDefaults.standardUserDefaults().integerForKey("maxLevel")
    
    var movingSquare = SKSpriteNode()
    var arrayIndexNumber = 0
    var time = NSTimer()
    
    // Boolean Variables
    var moveRight = true
    var isHorizontal = false
    var startRightSide = true
    var gameStarted = false
    
    // Sound Actions
    var completedSound = SKAction()
    var errorSound = SKAction()
    
    // MARK: - Init
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // Horizontal and Vertical Arrays for square positions
        horizontalPosArray = [
            CGPoint(x: frame.size.width/2 - 135, y: frame.size.height/2),
            CGPoint(x: frame.size.width/2 - 90, y: frame.size.height/2),
            CGPoint(x: frame.size.width/2 - 45, y: frame.size.height/2),
            CGPoint(x: frame.size.width/2 + 45, y: frame.size.height/2),
            CGPoint(x: frame.size.width/2 + 90, y: frame.size.height/2),
            CGPoint(x: frame.size.width/2 + 135, y: frame.size.height/2)
        ]
        verticalPosArray = [
            CGPoint(x: frame.size.width/2, y: frame.size.height/2 - 135),
            CGPoint(x: frame.size.width/2, y: frame.size.height/2 - 90),
            CGPoint(x: frame.size.width/2, y: frame.size.height/2 - 45),
            CGPoint(x: frame.size.width/2, y: frame.size.height/2 + 45),
            CGPoint(x: frame.size.width/2, y: frame.size.height/2 + 90),
            CGPoint(x: frame.size.width/2, y: frame.size.height/2 + 135)
        ]
        
        // Horizontal and Vertical Arrays for moving square positions
        movingSquareHorizontalPosArray = [
            CGPoint(x: frame.size.width/2 - 135, y: frame.size.height/2),
            CGPoint(x: frame.size.width/2 - 90, y: frame.size.height/2),
            CGPoint(x: frame.size.width/2 - 45, y: frame.size.height/2),
            CGPoint(x: frame.size.width/2, y: frame.size.height/2),
            CGPoint(x: frame.size.width/2 + 45, y: frame.size.height/2),
            CGPoint(x: frame.size.width/2 + 90, y: frame.size.height/2),
            CGPoint(x: frame.size.width/2 + 135, y: frame.size.height/2)
        ]
        movingSquareVerticalPosArray = [
            CGPoint(x: frame.size.width/2, y: frame.size.height/2 - 135),
            CGPoint(x: frame.size.width/2, y: frame.size.height/2 - 90),
            CGPoint(x: frame.size.width/2, y: frame.size.height/2 - 45),
            CGPoint(x: frame.size.width/2, y: frame.size.height/2),
            CGPoint(x: frame.size.width/2, y: frame.size.height/2 + 45),
            CGPoint(x: frame.size.width/2, y: frame.size.height/2 + 90),
            CGPoint(x: frame.size.width/2, y: frame.size.height/2 + 135)
        ]
        
        // Initialize actions to play sound
        completedSound = SKAction.playSoundFileNamed("completed.mp3", waitForCompletion: false)
        errorSound = SKAction.playSoundFileNamed("error.wav", waitForCompletion: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Game Lifecycle
    
    override func didMoveToView(view: SKView) {
        layoutGame()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !gameStarted {
            
            // Game has starteds
            gameStarted = true
            
            // Hide 'Tap To Start' label
            tapToStartLabel.hidden = true
            
            // Randomly set moving square direction and side
            setRandomMovingSquareDirection()
            setRandomSquareStartSide()
            
            // Define speed of square
            let speed = Double(0.5) / Double(level)
            time = NSTimer.scheduledTimerWithTimeInterval(speed, target: self, selector: Selector("moveTargetSquare"), userInfo: nil, repeats: true)
            
            // Display the sqaure
            movingSquare.hidden = false
            
        } else {
            // Game is already started
            // Check is square is in center on touch
            if movingSquare.position == CGPoint(x: frame.size.width/2, y: frame.size.height/2) {
                
                // Subtract remaing moves
                movesRemaining -= 1
                remainingCount.text = "\(movesRemaining)"
                
                // Level completed if remaining moves is 0
                if movesRemaining == 0 {
                    levelCompleted()
                }
                
                arrayIndexNumber = 0
                
                // Randomly set moving square direction
                setRandomMovingSquareDirection()
            } else {
                // Game is over
                gameOver()
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {}
    
    // MARK: - Helper Methods
    
    // Loop through the positionsArray and store positions in spritesArray.
    // Using inout to pass array by reference
    func positionInArray(posArray: [CGPoint], inout spritesArray: [SKSpriteNode]) {
        var i=0
        for position in posArray {
            if spritesArray.count < 6 {
                spritesArray.append(createSquare(position))
            } else {
                spritesArray[i].position = posArray[i]
                i++
            }
        }
        
        // Add sprites to the scene
        for sprites in spritesArray {
            self.addChild(sprites)
        }
    }
    
    
    // MARK: - Setup Game
    
    func layoutGame() {
        backgroundColor = SKColor(red: 47.0/255.0, green: 47.0/255.0, blue: 47.0/255.0, alpha: 1/0)
        
        // Check is current level is greater than max level
        if level > maxLevel {
            // Set the new best level reached
            NSUserDefaults.standardUserDefaults().setInteger(level - 1, forKey: "maxLevel")
            maxLevel = NSUserDefaults.standardUserDefaults().integerForKey("maxLevel")
        }
        
        // Setup Labels and Cross background
        setupLabels()
        
        personalBestCountLabel.text = "\(maxLevel)"
        createCrossHairsBG()
        
        // Load squares
        positionInArray(verticalPosArray, spritesArray: &verticalSquaresArray)
        positionInArray(horizontalPosArray, spritesArray: &horizontalSquaresArray)
        
        // Load the moving square
        createMovingSquare()
        
        // Allow user interaction
        userInteractionEnabled = true
    }
    
    func setupLabels() {
        movesRemaining = level
        
        // Tap To Start
        tapToStartLabel = SKLabelNode(fontNamed: "GameFont7")
        tapToStartLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + self.frame.height/2.5)
        tapToStartLabel.fontColor = SKColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        tapToStartLabel.text = "Tap To Start"
        addChild(tapToStartLabel)
        
        // Level
        levelLabel = SKLabelNode(fontNamed: "GameFont7")
        levelLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + self.frame.height/3)
        levelLabel.fontColor = SKColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        levelLabel.text = "Level \(level)"
        addChild(levelLabel)
        
        // Remaining:
        remainingLabel = SKLabelNode(fontNamed: "GameFont7")
        remainingLabel.fontSize = 20
        remainingLabel.position = CGPoint(x: self.frame.width/1.5, y: self.frame.height/6)
        remainingLabel.fontColor = SKColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        remainingLabel.text = "Remaining: "
        addChild(remainingLabel)
        
        remainingCount = SKLabelNode(fontNamed: "GameFont7")
        remainingCount.fontSize = 20
        remainingCount.position = CGPoint(x: self.frame.width/1.2, y: self.frame.height/6)
        remainingCount.fontColor = SKColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        remainingCount.text = "\(movesRemaining)"
        addChild(remainingCount)
        
        // Personal Best
        personalBestLabel = SKLabelNode(fontNamed: "GameFont7")
        personalBestLabel.fontSize = 20
        personalBestLabel.position = CGPoint(x: self.frame.width/3.2, y: self.frame.height/6)
        personalBestLabel.fontColor = SKColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        personalBestLabel.text = "Best: "
        addChild(personalBestLabel)
        
        personalBestCountLabel = SKLabelNode(fontNamed: "GameFont7")
        personalBestCountLabel.fontSize = 20
        personalBestCountLabel.position = CGPoint(x: self.frame.width/2.4, y: self.frame.height/6)
        personalBestCountLabel.fontColor = SKColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        addChild(personalBestCountLabel)
    }
    
    // Create the Cross background
    func createCrossHairsBG() {
        // Vertical Row Container
        let verticalRect = SKSpriteNode(color: UIColor.blackColor(), size: CGSize(width: 50, height: 320))
        verticalRect.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        verticalRect.zPosition = 0
        addChild(verticalRect)
        
        // Horizonatal Row Container
        let horizontalRect = SKSpriteNode(color: UIColor.blackColor(), size: CGSize(width: 320, height: 50))
        horizontalRect.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        addChild(horizontalRect)
    }
    
    // Create indivdual squares
    func createSquare(position: CGPoint) -> SKSpriteNode {
        let square = SKSpriteNode(color: UIColor.lightGrayColor(), size: CGSize(width: 40,height: 40))
        square.position = position
        square.zPosition = 1
        
        return square
    }
    
    // Create the moving square
    func createMovingSquare() {
        movingSquare = createSquare(CGPoint(x: -200, y: -200))
        movingSquare.color = UIColor.yellowColor()
        movingSquare.zPosition = 2
        movingSquare.hidden = true
        
        addChild(movingSquare)
    }
    
    
    // MARK: - Move behaviors
    
    // Randomly assign square moving direction. Horizontal or Vertical
    func setRandomMovingSquareDirection() {
        let randNumber = Int(arc4random_uniform(UInt32(2)))
        
        if randNumber == 0 {
            isHorizontal = true
        } else {
            isHorizontal = false
        }
    }
    
    // Randomly assign square starting side. Left, Right, Top, or Bottom
    func setRandomSquareStartSide() {
        let randNumber = Int(arc4random_uniform(UInt32(2)))
        
        if randNumber == 0 {
            startRightSide = false
            arrayIndexNumber = 0
        } else {
            startRightSide = true
            arrayIndexNumber = 6
        }
    }
    
    // Move the moving square
    func moveTargetSquare() {
        // Horizontal Row
        if isHorizontal == true {
            movingSquare.position = movingSquareHorizontalPosArray[arrayIndexNumber]
            if arrayIndexNumber >= movingSquareHorizontalPosArray.count - 1 {
                moveRight = false
            }
            if arrayIndexNumber <= 0 {
                moveRight = true
            }
        } else {
            // Vertical Column
            movingSquare.position = movingSquareVerticalPosArray[arrayIndexNumber]
            
            // Check if the arrayIndexNumber is greater than or equal to
            // the array count. If so, move bottom to top.
            if arrayIndexNumber >= movingSquareVerticalPosArray.count - 1 {
                moveRight = false
            }
            
            // Check if the arrayIndexNumber is less than or equal to
            // 0. If so, move top to bottom.
            if arrayIndexNumber <= 0 {
                moveRight = true
            }
        }
        
        // Increment/Decrement the position on the indexValue
        if moveRight == true {
            arrayIndexNumber++
        } else {
            arrayIndexNumber--
        }
    }
    
    // MARK: - Sound Method
    func playSound(sound : SKAction) {
        runAction(sound)
    }
    
    
    // MARK: -  Game Center High Score
    
    func saveHighScore(score: Int) {
        // Check if the player is authenticated in GameCenter
        if GKLocalPlayer.localPlayer().authenticated {
            
            // Retrieve the leaderboard for the game
            let scoreReporter = GKScore(leaderboardIdentifier: "CenterLock_Leaderboard")
            scoreReporter.value = Int64(score)
            
            // Store the scores in an array
            let scoreArray: [GKScore] = [scoreReporter]
            
            // Report scores to GameCenter
            GKScore.reportScores(scoreArray, withCompletionHandler: { (error) -> Void in
                if error != nil {
                    print("Reporting Scores to GameCenter")
                } else {
                    print("Error \(error)")
                }
            })
        }
    }
    
    
    // MARK: - Level Completed
    
    // Animate all non-moving squares towards the center
    func animateSquaresTowardCenter() {
        // Animate the vertical sprites moving toward the center.
        let moveToYCenter = SKAction.moveToY(frame.size.height/2, duration: 0.5)
        
        // Animate the horizontal sprites moving toward the center.
        let moveToXCenter = SKAction.moveToX(frame.size.width/2, duration: 0.5)
        
        // Run action for vertical sprites.
        for sprites in verticalSquaresArray {
            sprites.runAction(moveToYCenter)
        }
        
        // Run action for horizontal sprites.
        for sprites in horizontalSquaresArray {
            sprites.runAction(moveToXCenter)
        }
        
        // Play the completed level sound.
        playSound(completedSound)
    }
    
    // Stop the timer, disable user interaction and stop the game
    
    func prepareGameEnded() {
        // Set that the game has not started
        gameStarted = false
        
        // Disable user interaction until layout is completed
        userInteractionEnabled = false
        
        // Stop the timer calls
        time.invalidate()
    }
    
    // Level is completed
    
    func levelCompleted() {
        prepareGameEnded()
        
        arrayIndexNumber = 0
        
        // Set moving square to green
        movingSquare.color = SKColor.greenColor()
        
        animateSquaresTowardCenter()
        
        // Wait for 2 seconds.  Upon completion, remove all children, increase
        // the level, and layout a new game
        let actionBack = SKAction.waitForDuration(2.0)
        self.scene?.runAction(SKAction.sequence([actionBack]), completion: { () -> Void in
            self.removeAllChildren()
            self.level++
            self.layoutGame()
            //self.personalBestCountLabel.text = "\(self.maxLevel)"
        })
    }
    
    
    // MARK: - Game Over
    
    func gameOver() {
        prepareGameEnded()
        
        // Set moving square to red
        movingSquare.color = SKColor.redColor()
        playSound(errorSound)
        
        if self.level > self.maxLevel {
            // Save the highest level completed
            self.saveHighScore(self.level - 1)
        }
        
        let actionBack = SKAction.waitForDuration(2.0)
        self.scene?.runAction(SKAction.sequence([actionBack]), completion: { () -> Void in
            self.removeAllChildren()
            self.layoutGame()
        })
    }
    
}
