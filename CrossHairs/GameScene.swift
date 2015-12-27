//
//  GameScene.swift
//  CrossHairs
//
//  Created by Matthew Curtner on 12/20/15.
//  Copyright (c) 2015 Matthew Curtner. All rights reserved.
//

import SpriteKit

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
    
    var level = 1
    var movesRemaining = 1
    
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
            gameStarted = true
            tapToStartLabel.hidden = true
            setRandomMovingSquareDirection()
            setRandomSquareStartSide()
            
            let speed = Double(0.5) / Double(level)
            time = NSTimer.scheduledTimerWithTimeInterval(speed, target: self, selector: Selector("moveTargetSquare"), userInfo: nil, repeats: true)
            movingSquare.hidden = false
            
        } else {
            if movingSquare.position == CGPoint(x: frame.size.width/2, y: frame.size.height/2) {
                movesRemaining -= 1
                remainingCount.text = "\(movesRemaining)"
                
                if movesRemaining == 0 {
                    levelCompleted()
                }
                
                arrayIndexNumber = 0
                setRandomMovingSquareDirection()
            } else {
                gameOver()
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        
    }
    
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
        
        setupLabels()
        createCrossHairsBG()
        
        positionInArray(verticalPosArray, spritesArray: &verticalSquaresArray)
        positionInArray(horizontalPosArray, spritesArray: &horizontalSquaresArray)
        
        targetSquare()
        userInteractionEnabled = true
    }
    
    func setupLabels() {
        movesRemaining = level
        
        tapToStartLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        tapToStartLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + self.frame.height/2.5)
        tapToStartLabel.fontColor = SKColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        tapToStartLabel.text = "Tap To Start"
        addChild(tapToStartLabel)
        
        levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        levelLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + self.frame.height/3)
        levelLabel.fontColor = SKColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        levelLabel.text = "Level \(level)"
        addChild(levelLabel)
        
        remainingLabel = SKLabelNode(fontNamed: "AvenirNext")
        remainingLabel.fontSize = 15
        remainingLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/6)
        remainingLabel.fontColor = SKColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        remainingLabel.text = "Remaining"
        addChild(remainingLabel)
        
        remainingCount = SKLabelNode(fontNamed: "AvenirNext")
        remainingCount.fontSize = 15
        remainingCount.position = CGPoint(x: self.frame.width/2, y: self.frame.height/8)
        remainingCount.fontColor = SKColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        remainingCount.text = "\(movesRemaining)"
        addChild(remainingCount)
    }
    
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
    
    func createSquare(position: CGPoint) -> SKSpriteNode {
        let square = SKSpriteNode(color: UIColor.lightGrayColor(), size: CGSize(width: 40,height: 40))
        square.position = position
        square.zPosition = 1
        
        return square
    }

    func targetSquare() {
        movingSquare = createSquare(CGPoint(x: -200, y: -200))
        movingSquare.color = UIColor.yellowColor()
        movingSquare.zPosition = 2
        movingSquare.hidden = true
        
        addChild(movingSquare)
    }
    
    
    // MARK: - Move behaviors
    
    func setRandomMovingSquareDirection() {
        let randNumber = Int(arc4random_uniform(UInt32(2)))
        
        if randNumber == 0 {
            isHorizontal = true
        } else {
            isHorizontal = false
        }
    }
    
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

    
    // MARK: - Level Completed
    
    func levelCompleted() {
        // Disable user interaction.
        userInteractionEnabled = false
        
        gameStarted = false
        print("Win")
        time.invalidate()
        arrayIndexNumber = 0
        movingSquare.color = SKColor.greenColor()
        
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
        
        playSound(completedSound)
        
        let actionBack = SKAction.waitForDuration(2.0)
        self.scene?.runAction(SKAction.sequence([actionBack]), completion: { () -> Void in
            self.removeAllChildren()
            self.level++
            self.layoutGame()
        })
    }
    
    
    // MARK: - Game Over
    
    func gameOver() {
        userInteractionEnabled = false
        print("Lose")
        time.invalidate()
        gameStarted = false
        movingSquare.color = SKColor.redColor()
        playSound(errorSound)
        
        let actionBack = SKAction.waitForDuration(2.0)
        self.scene?.runAction(SKAction.sequence([actionBack]), completion: { () -> Void in
            self.removeAllChildren()
            self.layoutGame()
        })
    }
    
}
