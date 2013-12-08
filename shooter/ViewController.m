//
//  ViewController.m
//  shooter
//
//  Created by Deng Tao on 12/4/13.
//  Copyright (c) 2013 dev tdeng. All rights reserved.
//

#import "ViewController.h"
#import "ShooterScene.h"

@interface ViewController () <FBLoginViewDelegate>
@end

@implementation ViewController
{
    FBLoginView* _loginview;
    UIButton*   _invtieButton;
    UIButton*   _settingButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Create Login View so that the app will be granted "status_update" permission.
    _loginview = [[FBLoginView alloc] init];
    _loginview.frame = CGRectOffset(_loginview.frame,
                                    CGRectGetMidX(self.view.bounds)-_loginview.bounds.size.width/2,
                                    CGRectGetMidY(self.view.bounds)-_loginview.bounds.size.height/2);
    
    _loginview.delegate = self;
    [self.view addSubview:_loginview];
    [_loginview sizeToFit];
    
    // add invite button, hidden until facebook login
    _invtieButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _invtieButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds)-105,
                                     0, 50, 50);
    
    [_invtieButton setBackgroundImage:[UIImage imageNamed:@"invite_40x40.png"]forState:UIControlStateNormal];
    
    [_invtieButton addTarget:self action:@selector(inviteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _invtieButton.hidden = YES;
    [self.view addSubview:_invtieButton];
    
    // add setting button, hidden until facebook login
    _settingButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _settingButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds)-50,0,50,50);
    [_settingButton setBackgroundImage:[UIImage imageNamed:@"setting_40x40.png"]forState:UIControlStateNormal];
    [_settingButton addTarget:self action:@selector(settingButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _settingButton.hidden = YES;
    [self.view addSubview:_settingButton];
    
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
    
    _loginview.hidden = YES;
    _settingButton.hidden = NO;
    _invtieButton.hidden = NO;
    [self initializeMyScene];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    NSLog(@"loginViewFetchedUserInfo");
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSLog(@"loginViewShowingLoggedInUser, session stat=%d", appDelegate.session.state);
    
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
        ShooterScene *theScene = [ShooterScene sceneWithSize:skView.bounds.size];
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

- (void)inviteButtonClicked
{
    //1.stop game
    //2.send requests
    //3.resume game
    [self finalizeMyScene];
    
    // Send requests to friends directly
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"Please join me to play the game!"
     title:@"Invite Facebook Friends"
     parameters:nil
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         [self initializeMyScene];
     }
     ];
}

- (void)settingButtonClicked
{
#pragma mark - TBD - add more settings feature here(eg. achievement)
    NSLog(@"ViewController:settingButtonClicked");
}
@end
