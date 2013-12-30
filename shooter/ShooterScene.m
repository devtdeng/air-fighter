//
//  GameScene.m
//  AirPlanesGame
//
//  Created by Jorge Costa on 8/26/13.
//  Copyright (c) 2013 Jorge Costa. All rights reserved.
//

#import "ShooterScene.h"

#define kScale 0.2
#define kPropeller  22
#define kShadowX    15
#define kShadowY    0
#define kPlaneSpeed 300
#define kBulletDur  1

@implementation ShooterScene
{
    CGRect screenRect;
    CGFloat screenHeight;
    CGFloat screenWidth;
    CGPoint destPoint;
    
    SKSpriteNode *_plane;
    SKSpriteNode *_planeShadow;
    SKSpriteNode *_propeller;
    
    //SKEmitterNode *_smokeTrail;
    NSMutableArray *_explosionTextures;
    NSMutableArray *_cloudsTextures;
    
    double  _nextEnemy;
    double  _nextBullet;
    double  _nextCloud;

    // score
    int _score;
    SKLabelNode *_scoreLabel;
    BOOL    _gameOver;
    
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        //init several sizes used in all scene
        screenRect = [[UIScreen mainScreen] bounds];
        screenHeight = screenRect.size.height;
        screenWidth = screenRect.size.width;
        
        //adding background
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:background];
        
        //adding the smokeTrail
        /* TBD */
        
        //load explosions
        SKTextureAtlas *explosionAtlas = [SKTextureAtlas atlasNamed:@"EXPLOSION"];
        NSArray *textureNames = [explosionAtlas textureNames];
        _explosionTextures = [NSMutableArray new];
        for (NSString *name in textureNames) {
            SKTexture *texture = [explosionAtlas textureNamed:name];
            [_explosionTextures addObject:texture];
        }
        
        //load clouds
        SKTextureAtlas *cloudsAtlas = [SKTextureAtlas atlasNamed:@"Clouds"];
        NSArray *textureNamesClouds = [cloudsAtlas textureNames];
        _cloudsTextures = [NSMutableArray new];
        for (NSString *name in textureNamesClouds) {
            SKTexture *texture = [cloudsAtlas textureNamed:name];
            [_cloudsTextures addObject:texture];
        }
        
        _scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
        _scoreLabel.name = @"score";
        _scoreLabel.scale = 0.1;
        _scoreLabel.fontSize = 20;
        _scoreLabel.position = CGPointMake(40, self.frame.size.height*0.92);
        _scoreLabel.fontColor = [SKColor yellowColor];
        [self addChild:_scoreLabel];
        SKAction *labelScaleAction = [SKAction scaleTo:1.0 duration:1];
        [_scoreLabel runAction:labelScaleAction];
        
        [self startGame];
    }
    return self;
}

- (void) startGame
{
    //adding airplane
    _plane = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE.png"];
    _plane.scale = kScale;
    _plane.zPosition = 2;
    _plane.position = CGPointMake(screenWidth/2, _plane.size.height/2);
    _plane.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_plane.size];
    _plane.physicsBody.dynamic = YES;
    
    _plane.physicsBody.categoryBitMask = planeCategory;
    _plane.physicsBody.contactTestBitMask = enemyCategory;
    
    _plane.physicsBody.collisionBitMask = 0;
    [self addChild:_plane];
    
    //adding propeller animation
    _propeller = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE PROPELLER 1.png"];
    _propeller.scale = kScale;
    _propeller.position = CGPointMake(_plane.position.x, _plane.position.y+kPropeller);
    SKTexture *propeller1 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 1.png"];
    SKTexture *propeller2 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 2.png"];
    SKAction *spin = [SKAction animateWithTextures:@[propeller1,propeller2] timePerFrame:0.1];
    SKAction *spinForever = [SKAction repeatActionForever:spin];
    [_propeller runAction:spinForever];
    [self addChild:_propeller];
    
    //adding airplane shadow
    _planeShadow = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE SHADOW.png"];
    _planeShadow.scale = kScale;
    _planeShadow.zPosition = 1;
    _planeShadow.position = CGPointMake(_plane.position.x+kShadowX, _plane.position.y+kShadowY);
    [self addChild:_planeShadow];
    
    
    _score = 0;
    _scoreLabel.text = [NSString stringWithFormat:@"Score : %d", _score];

    _nextEnemy = 0;
    _nextBullet = 0;
    _gameOver = NO;
}

-(void)update:(NSTimeInterval)currentTime{
    double curTime = CACurrentMediaTime();
    // plane texture
    if(_plane.position.x == destPoint.x){
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE.png"];
    }
    
    // fire bullets as well
    if(_gameOver==NO && curTime > _nextBullet){
        _nextBullet = 0.2 + curTime;
        
        CGPoint location = [_plane position];
        SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithImageNamed:@"BULLET.png"];
        
        bullet.position = CGPointMake(location.x,location.y+_plane.size.height/2);
        bullet.zPosition = 1;
        bullet.scale = kScale*2;
        
        bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bullet.size];
        bullet.physicsBody.dynamic = NO;
        bullet.physicsBody.categoryBitMask = bulletCategory;
        bullet.physicsBody.contactTestBitMask = enemyCategory;
        bullet.physicsBody.collisionBitMask = 0;
        
        SKAction *action = [SKAction moveToY:self.frame.size.height+bullet.size.height duration:kBulletDur];
        SKAction *remove = [SKAction removeFromParent];
        [bullet runAction:[SKAction sequence:@[action,remove]]];
        [self addChild:bullet];
    }

    // enemy
    if (curTime > _nextEnemy) {
        float randSecs = [self randomValueBetween:0.5 andValue:2.0];
        _nextEnemy = randSecs + curTime;
        
        SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:@"ENEMY.png"];
        
        float randX = [self randomValueBetween:0.0 andValue:screenRect.size.width];
        enemy.position = CGPointMake(randX, screenRect.size.height);
        enemy.scale = kScale;
        enemy.zPosition = 1;
        enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemy.size];
        enemy.physicsBody.dynamic = YES;
        enemy.physicsBody.categoryBitMask = enemyCategory;
        enemy.physicsBody.contactTestBitMask = bulletCategory;
        enemy.physicsBody.collisionBitMask = 0;
        enemy.hidden = NO;
        
        CGMutablePathRef cgpath = CGPathCreateMutable();
        //random values
        float xStart = [self randomValueBetween:0.0 andValue:screenRect.size.width];
        float xEnd = [self randomValueBetween:0.0 andValue:screenRect.size.width];
        
        //ControlPoint1
        float cp1X = [self randomValueBetween:0.0 andValue:screenRect.size.width];
        float cp1Y = screenRect.size.height/1.5;
        
        //ControlPoint2
        float cp2X = [self randomValueBetween:0.0 andValue:screenRect.size.width];
        float cp2Y = screenRect.size.height/3;
        
        CGPoint s = CGPointMake(xStart, screenRect.size.height);
        CGPoint e = CGPointMake(xEnd, -100);
        
        CGPoint cp1 = CGPointMake(cp1X, cp1Y);
        CGPoint cp2 = CGPointMake(cp2X, cp2Y);
        CGPathMoveToPoint(cgpath,NULL, s.x, s.y);
        CGPathAddCurveToPoint(cgpath, NULL, cp1.x, cp1.y, cp2.x, cp2.y, e.x, e.y);
        
        SKAction *planeDestroy = [SKAction followPath:cgpath asOffset:NO orientToPath:YES duration:5];
        [self addChild:enemy];
        
        SKAction *remove = [SKAction removeFromParent];
        [enemy runAction:[SKAction sequence:@[planeDestroy,remove]]];
        CGPathRelease(cgpath);
    }
    
    // cloud
    if (curTime > _nextCloud) {
        float randSecs = [self randomValueBetween:1.0 andValue:4.0];
        _nextCloud = randSecs + curTime;
        
        int whichCloud = [self getRandomNumberBetween:0 to:3];
        SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithTexture:[_cloudsTextures objectAtIndex:whichCloud]];
        
        int randomYAxix = [self getRandomNumberBetween:0 to:screenRect.size.width];
        cloud.position = CGPointMake(randomYAxix, screenRect.size.height+cloud.size.width/2);
        cloud.zPosition = 1;
        cloud.scale = 0.5;
        
        int randomTimeCloud = [self getRandomNumberBetween:9 to:19];
        SKAction *move =[SKAction moveTo:CGPointMake(randomYAxix, 0-cloud.size.width) duration:randomTimeCloud];
        
        SKAction *remove = [SKAction removeFromParent];
        [cloud runAction:[SKAction sequence:@[move,remove]]];
        [self addChild:cloud];
    }
    
    /*TBD*/
    //_smokeTrail.position = CGPointMake(newX,newY-(_plane.size.height/2));
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self MoveAndFire:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self MoveAndFire:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)MoveAndFire:(NSSet* )touches
{
    // move plane to destination
    for (UITouch *touch in touches) {
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        if (n != self && [n.name isEqual: @"finalLabel"]) {
            [[self childNodeWithName:@"finalLabel"] removeFromParent];
            [self startGame];
            return;
        }
        else{
            if(_gameOver) return;
            
            destPoint = [touch locationInNode:self];
            float distance=sqrtf(pow(destPoint.x-_plane.position.x, 2)+pow(destPoint.y-_plane.position.y, 2));
            float duration = distance/kPlaneSpeed;
            
            SKAction *moveTo = [SKAction moveTo:destPoint duration:duration];
            [_plane runAction:moveTo];
            
            CGPoint propellerDest = CGPointMake(destPoint.x, destPoint.y+kPropeller);
            SKAction *moveToPropler = [SKAction moveTo:propellerDest duration:duration];
            [_propeller runAction:moveToPropler];
            
            CGPoint shadowDest = CGPointMake(destPoint.x+kShadowX, destPoint.y+kShadowY);
            SKAction *moveToShadow = [SKAction moveTo:shadowDest duration:duration];
            [_planeShadow runAction:moveToShadow];
            break;
        }
    }
}

- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

-(int)getRandomNumberBetween:(int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
}

-(void)didBeginContact:(SKPhysicsContact *)contact{
    SKPhysicsBody *firstBody;
    firstBody = contact.bodyA.categoryBitMask<contact.bodyB.categoryBitMask?contact.bodyA:contact.bodyB;

    if ((firstBody.categoryBitMask & bulletCategory) != 0) // bullet hits enemy
    {
        SKNode *projectile = (contact.bodyA.categoryBitMask & bulletCategory) ? contact.bodyA.node : contact.bodyB.node;
        SKNode *enemy = (contact.bodyA.categoryBitMask & bulletCategory) ? contact.bodyB.node : contact.bodyA.node;
        [projectile runAction:[SKAction removeFromParent]];
        [enemy runAction:[SKAction removeFromParent]];
        
        //add explosion
        SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:[_explosionTextures objectAtIndex:0]];
        explosion.zPosition = 1;
        explosion.scale = kScale;
        explosion.position = contact.bodyA.node.position;
        
        [self addChild:explosion];
        
        SKAction *explosionAction = [SKAction animateWithTextures:_explosionTextures timePerFrame:0.07];
        SKAction *remove = [SKAction removeFromParent];
        [explosion runAction:[SKAction sequence:@[explosionAction,remove]]];
        
        _score++;
        _scoreLabel.text = [NSString stringWithFormat:@"Score : %d", _score];
    }
    else if ((firstBody.categoryBitMask & enemyCategory) != 0) // enemy hits plane
    {
        SKNode *projectile = (contact.bodyA.categoryBitMask & enemyCategory) ? contact.bodyA.node : contact.bodyB.node;
        
        [projectile runAction:[SKAction removeFromParent]];
        [_plane runAction:[SKAction removeFromParent]];
        [_propeller runAction:[SKAction removeFromParent]];
        [_planeShadow runAction:[SKAction removeFromParent]];
        
        //add explosion
        SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:[_explosionTextures objectAtIndex:0]];
        explosion.zPosition = 1;
        explosion.scale = kScale*2;
        explosion.position = contact.bodyA.node.position;
        [self addChild:explosion];
        
        SKAction *explosionAction = [SKAction animateWithTextures:_explosionTextures timePerFrame:0.07];
        SKAction *remove = [SKAction removeFromParent];
        [explosion runAction:[SKAction sequence:@[explosionAction,remove]]];
        
        [self gameOver];
    }
}

- (void)gameOver
{
    if(_gameOver) return;
    
    SKLabelNode *finalLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    finalLabel.name = @"finalLabel";
    finalLabel.text = @"Play Again?";
    finalLabel.scale = 0.5;
    finalLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.4);
    finalLabel.fontColor = [SKColor yellowColor];
    [self addChild:finalLabel];
    SKAction *labelScaleAction = [SKAction scaleTo:1.0 duration:0.5];
    [finalLabel runAction:labelScaleAction];

    _gameOver = YES;
}
@end
