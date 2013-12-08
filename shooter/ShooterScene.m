//
//  ShooterScene.m
//  shooter
//
//  Created by Deng Tao on 12/4/13.
//  Copyright (c) 2013 dev tdeng. All rights reserved.
//

#define kNumAsteroids   15
#define kNumBullets     5

typedef enum {
    kEndReasonWin,
    kEndReasonLose
} EndReason;

#import "ShooterScene.h"
#import "FMMParallaxNode.h"

@implementation ShooterScene
{
    SKSpriteNode    *_ship;
    NSMutableArray *_shipBullets;
    int _nextShipBullet;
    
    FMMParallaxNode *_parallaxNodeBackgrounds;
    FMMParallaxNode *_parallaxSpaceDust;
    
    NSMutableArray *_asteroids;
    int _nextAsteroid;
    double _nextAsteroidSpawn;
    
    int _lives;
    double _gameOverTime;
    bool _gameOver;
    
    int _score;
    SKLabelNode *_scoreLabel;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor blackColor];
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        // Setup game background
        NSArray *parallaxBackgroundNames = @[@"bg_galaxy.png", @"bg_planetsunrise.png",
                                             @"bg_spacialanomaly.png", @"bg_spacialanomaly2.png"];
        CGSize planetSizes = CGSizeMake(200.0, 200.0);
        _parallaxNodeBackgrounds = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackgroundNames
                                                                           size:planetSizes
                                                           pointsPerSecondSpeed:10.0];
        _parallaxNodeBackgrounds.position = CGPointMake(size.width/2.0, size.height/2.0);
        [_parallaxNodeBackgrounds randomizeNodesPositions];
        [self addChild:_parallaxNodeBackgrounds];
        
        NSArray *parallaxBackground2Names = @[@"bg_front_spacedust.png",@"bg_front_spacedust.png"];
        _parallaxSpaceDust = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackground2Names
                                                                     size:size
                                                     pointsPerSecondSpeed:25.0];
        _parallaxSpaceDust.position = CGPointMake(0, 0);
        [self addChild:_parallaxSpaceDust];
        
        // Setup the ship
        _ship = [SKSpriteNode spriteNodeWithImageNamed:@"SpaceFlier_sm.png"];
        _ship.position = CGPointMake(self.frame.size.width * 0.1, CGRectGetMidY(self.frame));
        [self addChild:_ship];
        
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
        SKAction *labelScaleAction = [SKAction scaleTo:1.0 duration:0.5];
        [_scoreLabel runAction:labelScaleAction];
        
        // Start the actual game
        [self startTheGame];
    }
    
    return self;
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
            [[self childNodeWithName:@"winLoseLabel"] removeFromParent];
            [self startTheGame];
            return;
        }
        else if (n != self && [n.name isEqual: @"winLoseLabel"]) {
            [self ShareWithFacebookFriendsWith:_score];
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

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [_parallaxSpaceDust update:currentTime];
    [_parallaxNodeBackgrounds update:currentTime];
    
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
    
    // Add at end of update loop
    if (_lives <= 0) {
        [self endTheScene:kEndReasonLose];
    } else if (curTime >= _gameOverTime) {
        [self endTheScene:kEndReasonWin];
    }
}

- (void)endTheScene:(EndReason)endReason {
    if (_gameOver) {
        return;
    }
    
    [self removeAllActions];

    _ship.hidden = YES;
    _gameOver = YES;
    
    NSString *message;
    if (endReason == kEndReasonWin) {
        message = @"You win! Share to Facebook!";
    } else if (endReason == kEndReasonLose) {
        message = @"You lose! Share to Facebook!";
    }
    
    SKLabelNode *label;
    label = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    label.name = @"winLoseLabel";
    label.text = message;
    label.scale = 0.1;
    label.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.6);
    label.fontColor = [SKColor yellowColor];
    [self addChild:label];
    
    SKLabelNode *restartLabel;
    restartLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    restartLabel.name = @"restartLabel";
    restartLabel.text = @"Play Again?";
    restartLabel.scale = 0.5;
    restartLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.4);
    restartLabel.fontColor = [SKColor yellowColor];
    [self addChild:restartLabel];
    
    SKAction *labelScaleAction = [SKAction scaleTo:1.0 duration:0.5];
    
    [restartLabel runAction:labelScaleAction];
    [label runAction:labelScaleAction];
}

/* Publish game activities/score on current Facebook user's current status*/
- (void) ShareWithFacebookFriendsWith:(int)Score
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

@end
