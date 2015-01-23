//
//  WelcomeViewController.h
//  PYLoginViewController
//
//  Created by Michael Wojcieszek on 1/16/15.
//  Copyright (c) 2015 Pyrus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import "AppDelegate.h"
static NSString * const kClientId = @"8794258615-ckluesplngp7sd6garboohsc0gf7dhal.apps.googleusercontent.com";

@class GPPSignInButton;

@interface WelcomeViewController : UIViewController <UIWebViewDelegate,GPPSignInDelegate>
{
    AppDelegate *objAppDelegate;
    NSMutableData *receivedData;
    UIView *view;
    UIWebView *webview;
}
@property (retain, nonatomic) IBOutlet GPPSignInButton *signInGoogleButton;
@property (retain, nonatomic) UIWebView *web_view;

@end
