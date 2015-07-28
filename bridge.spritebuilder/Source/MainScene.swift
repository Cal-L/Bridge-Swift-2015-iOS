import Foundation


class MainScene: CCNode {
    
    var _scrollSpeed : CGFloat = 80
    let _screenSize : CGRect = UIScreen.mainScreen().bounds
    var _groundsArray : [CCNode] = []
    var _physicsNode : CCPhysicsNode!
    var randPosUInt32 : UInt32!
    var randPosInt : UInt32!
    var randPosFinal : CGFloat!
    var isHolding = false
    var _heroLayer : [CCNode] = []
    var _rect : CCNodeColor!
    var _bridgeLength : CGFloat!
    var _won = false
    var _scoreLabel : CCLabelTTF!
    var _score = 0
    var time : CGFloat = 150.0
    var bridgeTime : CGFloat!
    var _waters : [CCNode] = []
    
    func didLoadFromCCB() {
        self.userInteractionEnabled = true
        self.spawnNewLand()
        self.spawnHero()
        var gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
        gesture.minimumPressDuration = 0.2
        CCDirector.sharedDirector().view.addGestureRecognizer(gesture)
        self.spawnWater()
        self.spawnWater()
        
    }
    
    func longPressed(longPress:UIGestureRecognizer) {
        
        if (_heroLayer.first?.numberOfRunningActions() == 0) {
            if (longPress.state == UIGestureRecognizerState.Began ) {
                isHolding = true
                _rect = CCNodeColor(color: CCColor.whiteColor(), width: 10, height: 0)
                _rect.position = ccp(_screenSize.width/5, _screenSize.height/2 - 40)
                self.addChild(_rect)
                NSLog("Started")
            } else if (longPress.state == UIGestureRecognizerState.Ended) {
                isHolding = false
                NSLog("Ended")
                self.moveBridgeAndCheck()
                if (_bridgeLength > (randPosFinal - _screenSize.width/5) - 20 && _bridgeLength < (randPosFinal - _screenSize.width/5) + 20){
                    NSLog("You Win!")
                    _won = true
                    _score++
                    _scoreLabel.string = String(_score)
                } else {
                    NSLog("You Lose!")
                    _won = false
                    _score = 0;
                    _scoreLabel.string = String(_score)
                }
            }
        }
    }
    
    func spawnWater() {
        let water = CCBReader.load("Water") as Water
        if (_waters.count == 0) {
            water.position = ccp(water.contentSize.width/2,0)
            _waters.append(water)
        }
        else if (_waters.count == 1) {
            water.position = ccp(water.contentSize.width,0)
            _waters.append(water)
        }
        self.addChild(water)
        
        let move = CCActionMoveBy.actionWithDuration(30, position: ccp(-water.contentSize.width*2,0)) as CCAction
        water.runAction(move)
    }
    
    func moveBridgeAndCheck() {
        _bridgeLength = _rect.contentSize.height
        bridgeTime = CGFloat(_bridgeLength/time)
        let drop = CCActionRotateBy.actionWithDuration(1, angle: 90) as CCAction
        let remove = CCActionCallBlock.actionWithBlock({self.removeBridge()}) as CCAction
        let delay = CCActionDelay.actionWithDuration(CCTime(bridgeTime)) as CCAction
        let check = CCActionCallBlock.actionWithBlock({self.checkHero()}) as CCAction
        let moveBlocks = CCActionCallBlock.actionWithBlock({self.moveAndSpawn()}) as CCAction
        let seq = CCActionSequence.actionWithArray([drop,check,delay,remove,moveBlocks]) as CCAction
        _rect.runAction(seq)
    }
    
    func checkHero() {
        var dropHero : CCAction
        if (_won == true) {
           dropHero = CCActionMoveBy.actionWithDuration(2, position: ccp(-(randPosFinal) + (_screenSize.width/5),0)) as CCAction
        } else {
           dropHero = CCActionMoveBy.actionWithDuration(2, position: ccp(0,-1000)) as CCAction
        }
        bridgeTime = CGFloat(_bridgeLength/time)
        
        var currentLandPos = randPosFinal
        let moveHero = CCActionMoveBy.actionWithDuration(CCTime(bridgeTime), position: ccp(_bridgeLength,0)) as CCAction
        let moveHeroBack = CCActionMoveTo.actionWithDuration(0, position: ccp(_screenSize.width/5, _screenSize.height/2 - 30)) as CCAction
        let seq = CCActionSequence.actionWithArray([moveHero,dropHero,moveHeroBack]) as CCAction
        _heroLayer.first?.runAction(seq)
        //var animate = _heroLayer.first?.userObject as CCAnimationManager
        //animate.runAnimationsForSequenceNamed("walking")
    }
    
    func moveAndSpawn() {
        
        if (_groundsArray.first?.numberOfRunningActions() == 0) {
            let moveLands = CCActionCallBlock.actionWithBlock({self.moveBothLands()}) as CCAction
            let spawnLands = CCActionCallBlock.actionWithBlock({self.spawnNewLand()}) as CCAction
            let delay = CCActionDelay.actionWithDuration(2) as CCAction
            let moveLandsAndSpawn = CCActionSequence.actionWithArray([moveLands,delay,spawnLands]) as CCAction
            self.runAction(moveLandsAndSpawn)
        }
        
    }
    
    func removeBridge() {
        _rect.removeFromParent()
    }
    
    func spawnNewLand() {
            //Spawns second land
            let newLand = CCBReader.load("Land") as Land
            newLand.position = ccp(_screenSize.width*1.5,_screenSize.height/8)
            _physicsNode.addChild(newLand)
            _groundsArray.append(newLand)
        
        if (_groundsArray.count == 1) {
            let move = CCActionMoveTo.actionWithDuration(1.5, position: ccp(_screenSize.width/5,_screenSize.height/8)) as CCAction
            let spawnSecond = CCActionCallBlock.actionWithBlock({self.spawnNewLand()}) as CCAction
            let actions = CCActionSequence.actionWithArray([move,spawnSecond]) as CCAction
            newLand.runAction(actions)
        } else {
            //Moves second land randomly
            randPosUInt32 = UInt32(_screenSize.width - _screenSize.width/3)
            randPosInt = arc4random_uniform(randPosUInt32) + UInt32(_screenSize.width/3)
            randPosFinal = CGFloat(randPosInt)
            let move = CCActionMoveTo.actionWithDuration(1.5, position: ccp(randPosFinal,_screenSize.height/8)) as CCAction
            newLand.runAction(move)
        }
    }
    
    func spawnHero() {
        
        let hero = CCBReader.load("Hero") as Hero
        hero.position = ccp(_screenSize.width/5, 260)
        _heroLayer.append(hero)
        _physicsNode.addChild(hero)
        var animate = _heroLayer.first?.userObject as CCAnimationManager
        animate.runAnimationsForSequenceNamed("Default Timeline")
        //animate.animationManager.paused = true
    }
    
    func moveBothLands() {
        
        for ground in _groundsArray {
            var distance : CGFloat!
            if (ground.position.x == _screenSize.width/5) {
                distance = -_screenSize.width
            } else {
                distance = -(randPosFinal) + (_screenSize.width/5)
            }
            let move = CCActionMoveBy.actionWithDuration(1, position: ccp(distance,0)) as CCAction
            ground.runAction(move)
        }
        
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        //For Debugging
        var count = String(_groundsArray[0].numberOfRunningActions())
        var arrayCount = String(_groundsArray.count)
        NSLog("Array Count" + arrayCount)
        NSLog("Running Actions" + count)
        
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
    }
    
    override func update(delta: CCTime) {
        //Checks if the first land is off the screen
        if (_groundsArray.first?.position.x < -200) {
                _groundsArray.first?.removeFromParent()
                _groundsArray.removeAtIndex(0)
        }
        if (isHolding == true && _heroLayer.first?.numberOfRunningActions() == 0) {
            _rect.contentSize = CGSize(width: 10, height: _rect.contentSize.height+4)
        }
        if (_waters.first?.position.x < 7) {
            _waters.first?.removeFromParent()
            _waters.removeAtIndex(0)
            
            self.spawnWater()
        }
    }
}
