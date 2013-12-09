//
//  ShooterScene.m
//  shooter
//
//  Created by Deng Tao on 12/4/13.
//  Copyright (c) 2013 dev tdeng. All rights reserved.
//

#define kNumAsteroids   15
#define kNumBullets     5

#import "ShooterScene.h"

@interface ShooterScene ()
@property BOOL contentCreated;
@end

@implementation ShooterScene
{
    SKSpriteNode    *_ship;
    SKSpriteNode    *_invtieButton;
    SKSpriteNode    *_settingButton;
    
    NSMutableArray *_shipBullets;
    int _nextShipBullet;
    
    NSMutableArray *_asteroids;
    int _nextAsteroid;
    double _nextAsteroidSpawn;
    
    int _lives;
    double _gameOverTime;
    bool _gameOver;
    
    int _score;
    SKLabelNode *_scoreLabel;
}

- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents
{
    // Setup game background
    self.backgroundColor = [SKColor blackColor];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
    // Setup the ship
    _ship = [SKSpriteNode spriteNodeWithImageNamed:@"SpaceFlier.png"];
    _ship.position = CGPointMake(self.frame.size.width * 0.1, CGRectGetMidY(self.frame));
    [self addChild:_ship];
    
    _invtieButton = [SKSpriteNode spriteNodeWithImageNamed:@"invite_40x40.png"];
    _invtieButton.position = CGPointMake(self.frame.size.width-65, self.frame.size.height-25);
    _invtieButton.name = @"inviteButton";
    [self addChild:_invtieButton];
    
    
    _settingButton = [SKSpriteNode spriteNodeWithImageNamed:@"setting_40x40.png"];
    _settingButton.position = CGPointMake(self.frame.size.width-25, self.frame.size.height-25);
    _settingButton.name = @"settingButton";
    [self addChild:_settingButton];
    
    // Setup the asteroids
    _asteroids = [[NSMutableArray alloc] initWithCapacity:kNumAsteroids];
    for (int i = 0; i < kNumAsteroids; ++i) {
        SKSpriteNode *asteroid = [SKSpriteNode spriteNodeWithImageNamed:@"asteroid"];
        asteroid.hidden = YES;
        [asteroid setXScale:0.5];
        [asteroid setYScale:0.5];
        [_asteroids addObject:asteroid];
        [self addChild:asteroid];
    }
    
    // Setup the ship bullets
    _shipBullets = [[NSMutableArray alloc] initWithCapacity:kNumBullets];
    for (int i = 0; i < kNumBullets; ++i) {
        SKSpriteNode *shipBullet = [SKSpriteNode spriteNodeWithImageNamed:@"bullet"];
        shipBullet.hidden = YES;
        [_shipBullets addObject:shipBullet];
        [self addChild:shipBullet];
    }
    
    // Setup the stars to appear as particles
    [self addChild:[self loadEmitterNode:@"stars1"]];
    [self addChild:[self loadEmitterNode:@"stars2"]];
    [self addChild:[self loadEmitterNode:@"stars3"]];
    
    // Setup score label at top left corner
    _score = 0;
    _scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    _scoreLabel.name = @"score";
    _scoreLabel.text = [NSString stringWithFormat:@"Score : %d", _score];
    _scoreLabel.scale = 0.1;
    _scoreLabel.fontSize = 20;
    _scoreLabel.position = CGPointMake(40, self.frame.size.height*0.92);
    _scoreLabel.fontColor = [SKColor yellowColor];
    [self addChild:_scoreLabel];
    SKAction *labelScaleAction = [SKAction scaleTo:1.0 duration:1];
    [_scoreLabel runAction:labelScaleAction];
    
    // Start the actual game
    [self startTheGame];
}

-(SKEmitterNode *)loadEmitterNode: (NSString *)emitterFileName
{
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:emitterFileName ofType:@"sks"];
    SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    
    //do some view specific tweaks
    emitterNode.particlePosition = CGPointMake(self.size.width/2.0, self.size.height/2.0);
    emitterNode.particlePositionRange = CGVectorMake(self.size.width+100, self.size.height);
    
    return emitterNode;
}

- (void)startTheGame
{
    // initialize game data
    _lives = 3;
    double curTime = CACurrentMediaTime();
    _gameOverTime = curTime + 20.0;
    _gameOver = NO;
    
    // initialize asteroid
    _nextAsteroidSpawn = 0;
    for (SKSpriteNode *asteroid in _asteroids) {
        asteroid.hidden = YES;
    }
    
    // display ship
    _ship.hidden = NO;
    //reset ship position for new game
    _ship.position = CGPointMake(self.frame.size.width * 0.1, CGRectGetMidY(self.frame));
    
    // initialize bullets
    for (SKSpriteNode *laser in _shipBullets) {
        laser.hidden = YES;
    }
    
    _score = 0;
}

/* Move ship from current position to touch event postion */
- (void)updateShipPositionFromTouchEvent:(UITouch*)touch
{
    CGPoint destPoint = [touch locationInView:self.view];
    destPoint.x = _ship.position.x;
    destPoint.y = self.frame.size.height - destPoint.y;
    SKAction *moveTo = [SKAction moveTo:destPoint duration:0.3];
    [_ship runAction:moveTo];
}

/* Called when a touch begins */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        
        if (n != self && [n.name isEqual: @"restartLabel"]) {
            [[self childNodeWithName:@"restartLabel"] removeFromParent];
            [[self childNodeWithName:@"shareFacebook"] removeFromParent];
            [self startTheGame];
            return;
        }
        else if (n != self && [n.name isEqual: @"shareFacebook"]) {
            [self shareWithFacebookFriends:_score];
        }
        else if (n != self && [n.name isEqual: @"settingButton"]) {
            // provide logout function only for setting button now
            [self logoutFacebook];
        }
        else if (n != self && [n.name isEqual: @"inviteButton"]) {
            [self inviteFacebookFriends];
        }
        else{
            [self updateShipPositionFromTouchEvent:touch];
        }
    }
    
    //do not process anymore touches since it's game over
    if (_gameOver) {
        return;
    }
    
    SKSpriteNode *shipBullet = [_shipBullets objectAtIndex:_nextShipBullet];
    _nextShipBullet++;
    if (_nextShipBullet >= _shipBullets.count) {
        _nextShipBullet = 0;
    }
    
    shipBullet.position = CGPointMake(_ship.position.x+shipBullet.size.width/2,_ship.position.y+0);
    shipBullet.hidden = NO;
    [shipBullet removeAllActions];
    
    CGPoint location = CGPointMake(self.frame.size.width, _ship.position.y);
    SKAction *laserMoveAction = [SKAction moveTo:location duration:0.5];
    
    SKAction *laserDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
        //NSLog(@"Animation Completed");
        shipBullet.hidden = YES;
    }];
    
    SKAction *moveLaserActionWithDone = [SKAction sequence:@[laserMoveAction,laserDoneAction]];
    
    [shipBullet runAction:moveLaserActionWithDone withKey:@"laserFired"];
}

- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

/* Called before each frame is rendered */
-(void)update:(CFTimeInterval)currentTime {
    double curTime = CACurrentMediaTime();
    if (curTime > _nextAsteroidSpawn) {
        //NSLog(@"spawning new asteroid");
        float randSecs = [self randomValueBetween:0.20 andValue:1.0];
        _nextAsteroidSpawn = randSecs + curTime;
        
        float randY = [self randomValueBetween:0.0 andValue:self.frame.size.height];
        float randDuration = [self randomValueBetween:2.0 andValue:10.0];
        
        SKSpriteNode *asteroid = [_asteroids objectAtIndex:_nextAsteroid];
        _nextAsteroid++;
        
        if (_nextAsteroid >= _asteroids.count) {
            _nextAsteroid = 0;
        }
        
        [asteroid removeAllActions];
        asteroid.position = CGPointMake(self.frame.size.width+asteroid.size.width/2, randY);
        asteroid.hidden = NO;
        
        CGPoint location = CGPointMake(-self.frame.size.width-asteroid.size.width, randY);
        
        SKAction *moveAction = [SKAction moveTo:location duration:randDuration];
        SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
            //NSLog(@"Animation Completed");
            asteroid.hidden = YES;
        }];
        
        SKAction *moveAsteroidActionWithDone = [SKAction sequence:@[moveAction, doneAction ]];
        [asteroid runAction:moveAsteroidActionWithDone withKey:@"asteroidMoving"];
    }
    
    //check for laser collision with asteroid
    for (SKSpriteNode *asteroid in _asteroids) {
        if (asteroid.hidden) {
            continue;
        }
        for (SKSpriteNode *shipBullet in _shipBullets) {
            if (shipBullet.hidden) {
                continue;
            }
            
            if ([shipBullet intersectsNode:asteroid]) {
                shipBullet.hidden = YES;
                asteroid.hidden = YES;
                
                NSLog(@"you just destroyed an asteroid");
                _score++;
                continue;
            }
        }
        if ([_ship intersectsNode:asteroid]) {
            asteroid.hidden = YES;
            SKAction *blink = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.1],
                                                   [SKAction fadeInWithDuration:0.1]]];
            SKAction *blinkForTime = [SKAction repeatAction:blink count:4];
            [_ship runAction:blinkForTime];
            _lives--;
            NSLog(@"your ship has been hit!");
        }
    }
    
    // refresh score label
    _scoreLabel.text = [NSString stringWithFormat:@"Score : %d", _score];
    
    // end of update loop
    if (_lives <= 0 || (curTime >= _gameOverTime)) {
        [self endTheScene];
    }
}

- (void)endTheScene {
    if (_gameOver) {
        return;
    }
    
    [self removeAllActions];
    
    _ship.hidden = YES;
    _gameOver = YES;
    
    SKLabelNode *label;
    label = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    label.name = @"shareFacebook";
    label.text = @"1. Share to Facebook!";
    label.scale = 0.1;
    label.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.6);
    label.fontColor = [SKColor yellowColor];
    [self addChild:label];
    
    SKLabelNode *restartLabel;
    restartLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    restartLabel.name = @"restartLabel";
    restartLabel.text = @"2. Play Again?";
    restartLabel.scale = 0.5;
    restartLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.4);
    restartLabel.fontColor = [SKColor yellowColor];
    [self addChild:restartLabel];
    
    SKAction *labelScaleAction = [SKAction scaleTo:1.0 duration:0.5];
    
    [restartLabel runAction:labelScaleAction];
    [label runAction:labelScaleAction];
}

/* Publish game activities/score on current Facebook user's current status*/
- (void) shareWithFacebookFriends:(int)Score
{
    NSString *shareMessage = [NSString stringWithFormat:@"Play game Shooter and get score: %d", Score];
    NSMutableDictionary *params =
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
     shareMessage, @"description",
     @"https://developers.facebook.com/ios", @"link",
     nil];
    
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error){
                                                  // TBD
                                              }
     ];
}

/* Send requests to Facebook friends*/
- (void) inviteFacebookFriends
{
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:@"Please join me to play the game!"
                                                    title:@"Invite Facebook Friends"
                                               parameters:nil
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      // TBD
                                                  }
     ];
}

- (void) logoutFacebook
{
    [FBSession.activeSession closeAndClearTokenInformation];
}

@end
