//
//  WelcomeScene.m
//  shooter
//
//  Created by Deng Tao on 12/9/13.
//  Copyright (c) 2013 dev tdeng. All rights reserved.
//

#import "WelcomeScene.h"

@interface WelcomeScene ()
@property BOOL contentCreated;
@end

@implementation WelcomeScene
- (void)didMoveToView: (SKView *)view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents
{
    self.backgroundColor = [SKColor grayColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    [self addChild: [self newHelloNode]];
}

- (SKLabelNode *)newHelloNode
{
    SKLabelNode *welcomeNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    welcomeNode.text = @"Space Shooter!";
    welcomeNode.fontSize = 42;
    welcomeNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)*1.2);
    return welcomeNode;
}

@end
