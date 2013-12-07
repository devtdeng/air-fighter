//
//  ViewController.m
//  shooter
//
//  Created by Deng Tao on 12/4/13.
//  Copyright (c) 2013 dev tdeng. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"


@interface ViewController () <FBLoginViewDelegate>
@end

@implementation ViewController
{
    FBLoginView* _loginview;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Create Login View so that the app will be granted "status_update" permission.
    _loginview = [[FBLoginView alloc] init];
    
    _loginview.frame = CGRectOffset(_loginview.frame, CGRectGetMidY(self.view.frame)-_loginview.frame.size.width/2, CGRectGetMidX(self.view.frame)-_loginview.frame.size.height/2);
    
    _loginview.delegate = self;
    [self.view addSubview:_loginview];
    [_loginview sizeToFit];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    // Configure the view.
    // Configure the view after it has been sized for the correct orientation.
    // [self initMyScene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - FBLoginViewDelegate
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // first get the buttons set for login mode
    NSLog(@"loginViewShowingLoggedInUser");
    //_loginview.hidden = YES;
    [self initializeMyScene];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    NSLog(@"loginViewFetchedUserInfo");
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"loginViewShowingLoggedOutUser");
    [self finalizeMyScene];

}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    // Handle login error here
    NSLog(@"FBLoginView encountered an error=%@", error);
}

#pragma mark -
- (void)initializeMyScene
{
    SKView *skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = NO;
        skView.showsNodeCount = NO;
        
        // Create and configure the scene.
        MyScene *theScene = [MyScene sceneWithSize:skView.bounds.size];
        theScene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:theScene];
    }
}

- (void)finalizeMyScene
{
    SKView *skView = (SKView *)self.view;
    [skView presentScene:NULL];
}

@end
