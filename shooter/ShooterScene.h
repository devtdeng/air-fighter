//
//  ShooterScene.h
//  shooter
//

//  Copyright (c) 2013 dev tdeng. All rights reserved.
//

#import "AppDelegate.h"
#import <SpriteKit/SpriteKit.h>

static const uint8_t bulletCategory = 1;
static const uint8_t enemyCategory = 2;
static const uint8_t planeCategory = 4;

@interface ShooterScene : SKScene<SKPhysicsContactDelegate>

@end
