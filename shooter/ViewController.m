//
//  ViewController.m
//  shooter
//
//  Created by Deng Tao on 12/4/13.
//  Copyright (c) 2013 dev tdeng. All rights reserved.
//

#import "ViewController.h"
#import "ShooterScene.h"
#import "WelcomeScene.h"
#import <iAd/ADBannerView.h>

@interface ViewController () <FBLoginViewDelegate, ADBannerViewDelegate>
@end

@implementation ViewController
{
    FBLoginView* _loginview;    // Facebook login view
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    SKView *skView = (SKView *) self.view;
    WelcomeScene* welcome = [WelcomeScene sceneWithSize:skView.bounds.size];
    [skView presentScene: welcome];
    
    // initialize Facebook login view
    _loginview = [[FBLoginView alloc] init];
    _loginview.frame = CGRectOffset(_loginview.frame,
                                    CGRectGetMidX(self.view.bounds)-_loginview.bounds.size.width/2,
                                    CGRectGetMidY(self.view.bounds)*1.2);
    _loginview.delegate = self;
    [self.view addSubview:_loginview];
    [_loginview sizeToFit];
    
    ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, 0,320,50)];
    [self.view addSubview:adView];
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
}

#pragma mark - FBLoginViewDelegate
/* user login */
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    
    // don't show FBLoginView if already login
    _loginview.hidden = YES;

    // move to game scene
    SKView  *skview = (SKView*)self.view;
    ShooterScene *shooterScene  = [[ShooterScene alloc] initWithSize:self.view.bounds.size];
    SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:2];
    [skview presentScene:shooterScene transition:doors];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
}

/* user logout */
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    // back to welcome scene
    SKView  *skview = (SKView*)self.view;
    WelcomeScene* welcome = [WelcomeScene sceneWithSize:skview.bounds.size];
    [skview presentScene: welcome];
    
    // hide Facebook loginview
    _loginview.hidden = NO;
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    // Handle Facebook login error here
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
}
@end
