//
//  WelcomeViewController.m
//  PYLoginViewController
//
//  Created by Michael Wojcieszek on 1/16/15.
//  Copyright (c) 2015 Pyrus. All rights reserved.
//

#import "WelcomeViewController.h"
#import "JSON.h"

#import "AFHTTPRequestOperation.h"
#import "LIALinkedInHttpClient.h"
//#import "LIALinkedInClientExampleCredentials.h"
#import "LIALinkedInApplication.h"

#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "GrantAccessViewController.h"

NSString *client_id = @"803684675628-m79pla412ln78p5j3fgpk4vjidcvmodh.apps.googleusercontent.com";
NSString *secret = @"vfYVTkZdWyrKmQ8ffbaWhUd7";
NSString *callbakc =  @"http://localhost";;
NSString *scope = @"https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile+https://www.google.com/reader/api/0/subscription";
NSString *visibleactions = @"http://schemas.google.com/AddActivity";



@interface WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *signInLinkedInButton;
@property (weak, nonatomic) GrantAccessViewController *grantAccessViewController;
@end
@implementation WelcomeViewController {
    LIALinkedInHttpClient *_client;
}
@synthesize signInGoogleButton;

- (void)viewDidLoad {
    [super viewDidLoad];
   
    ///////////////////  -   linkedin sign in  -   ///////////////////////
    self.signInLinkedInButton.layer.cornerRadius = 4;
    
    _client = [self client];
    
    objAppDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    ///////////////////  -   google sign in  -   ///////////////////////
    self.signInGoogleButton.layer.cornerRadius = 4;
    self.signInGoogleButton.style = kGPPSignInButtonStyleIconOnly;
    [self.signInGoogleButton.layer setFrame:CGRectMake(0,0,self.signInLinkedInButton.layer.frame.size.width,self.signInLinkedInButton.layer.frame.size.height)];
    self.signInGoogleButton.colorScheme = kGPPSignInButtonColorSchemeDark;
    NSLog(@"%@",self.signInGoogleButton.backgroundColor);
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    //signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
    //signIn.scopes = @[ @"profile" ];            // "profile" scope
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    
    //[signIn authenticate];
    //this method is one that inserted by gorou to test authentication.
    
}
///////////////////  -   linkedin sign in  -   ///////////////////////

- (IBAction)didTapConnectWithLinkedIn:(id)sender {
    [self.client getAuthorizationCode:^(NSString *code) {
        [self.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            [self requestMeWithToken:accessToken];
        }                   failure:^(NSError *error) {
            NSLog(@"Quering accessToken failed %@", error);
        }];
    }                      cancel:^{
        NSLog(@"Authorization was cancelled by user");
    }                     failure:^(NSError *error) {
        NSLog(@"Authorization failed %@", error);
    }];
}

- (void)requestMeWithToken:(NSString *)accessToken {
    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"current user %@", result);
        //
        [self performSegueWithIdentifier: @"grantAccessSegue" sender: self];
        //
    }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to fetch current user %@", error);
    }];
}

- (LIALinkedInHttpClient *)client {
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com/liaexample"
                                                                                    clientId:@"78q30qnwokkqz3"
                                                                                clientSecret:@"1sjgz7awtF7wZtit"
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:@[@"r_fullprofile", @"r_network"]];
    return [LIALinkedInHttpClient clientForApplication:application presentingViewController:self];
}
///////////////////  -   linkedin sign in end -   ///////////////////////

///////////////////  -   google sign in  -   ///////////////////////


//Implement the GPPSignInDelegate in the view controller to handle the sign-in process by defining the following method.

-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        // So here we can go to the next page and hide sign in buttons.
        
        self.signInGoogleButton.hidden = YES;
        self.signInLinkedInButton.hidden = YES;
        [self performSegueWithIdentifier: @"grantAccessSegue" sender: self];
        // Perform other actions here, such as showing a sign-out button
    } else {
        self.signInGoogleButton.hidden = NO;
        self.signInLinkedInButton.hidden = NO;
        // Perform other actions here
    }
}
- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    NSLog(@"Received Error %@ and auth object==%@", error, auth);
    
    if (error) {
        // Do some error handling here.
    } else {
        [self refreshInterfaceBasedOnSignIn];
        
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
        
        NSLog(@"email %@ ", [NSString stringWithFormat:@"Email: %@",[GPPSignIn sharedInstance].authentication.userEmail]);
        NSLog(@"Received error %@ and auth object %@",error, auth);
        
        // 1. Create a |GTLServicePlus| instance to send a request to Google+.
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init] ;
        plusService.retryEnabled = YES;
        
        // 2. Set a valid |GTMOAuth2Authentication| object as the authorizer.
        [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
        
        // 3. Use the "v1" version of the Google+ API.*
        plusService.apiVersion = @"v1";
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPerson *person,
                                    NSError *error) {
                    if (error) {
                        //Handle Error
                    } else {
                        NSLog(@"Email= %@", [GPPSignIn sharedInstance].authentication.userEmail);
                        NSLog(@"GoogleID=%@", person.identifier);
                        NSLog(@"User Name=%@", [person.name.givenName stringByAppendingFormat:@" %@", person.name.familyName]);
                        NSLog(@"Gender=%@", person.gender);
                    }
                }];
    }
}
- (IBAction)google_loginclick:(id)sender {
    NSString *url = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=%@&redirect_uri=%@&scope=%@&data-requestvisibleactions=%@",client_id,callbakc,scope,visibleactions];
    
    
    self.view.backgroundColor=[UIColor colorWithRed:44.0f/255.0f green:193.0f/255.0f blue:212.0f/255.0f alpha:1.0f];
    view=[[UIView alloc] initWithFrame:self.view.frame];
    view.backgroundColor=[UIColor colorWithRed:44.0f/255.0f green:193.0f/255.0f blue:212.0f/255.0f alpha:1.0f];
    [self.view addSubview:view];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(close_click:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"X" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    button.frame = CGRectMake(10.0, 20.0, 60.0, 60.0);
    [view addSubview:button];
    
    
    UILabel *lab_top=[[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 60)];
    lab_top.text=@"Google Login";
    lab_top.textAlignment=NSTextAlignmentCenter;
    lab_top.textColor=[UIColor whiteColor];
    lab_top.font = [UIFont boldSystemFontOfSize:20];
    [view addSubview:lab_top];
    
    webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 80, 320,self.view.frame.size.height - 80)];
    webview.delegate=self;
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [webview loadRequest:nsrequest];
    [view addSubview:webview];

}
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    //    [indicator startAnimating];
    if ([[[request URL] host] isEqualToString:@"localhost"]) {
        
        // Extract oauth_verifier from URL query
        NSString* verifier = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"code"]) {
                verifier = [keyValue objectAtIndex:1];
                NSLog(@"verifier %@",verifier);
                break;
            }
        }
        
        if (verifier) {
            NSString *data = [NSString stringWithFormat:@"code=%@&client_id=%@&client_secret=%@&redirect_uri=%@&grant_type=authorization_code", verifier,client_id,secret,callbakc];
            NSString *url = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/token"];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
            NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
            receivedData = [[NSMutableData alloc] init];
            
        } else {
            // ERROR!
        }
        
        [webView removeFromSuperview];
        
        return NO;
    }
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data

{
    [receivedData appendData:data];
    NSLog(@"verifier %@",receivedData);
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[NSString stringWithFormat:@"%@", error]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *response = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    SBJsonParser *jResponse = [[SBJsonParser alloc]init];
    NSDictionary *tokenData = [jResponse objectWithString:response];
    //  WebServiceSocket *dconnection = [[WebServiceSocket alloc] init];
    //   dconnection.delegate = self;
    
    
    NSLog(@"tokenData====>%@",tokenData);
    NSString *pdata = [NSString stringWithFormat:@"type=3&token=%@&secret=123&login=%@", [tokenData objectForKey:@"refresh_token"],@""];
    //  NSString *pdata = [NSString stringWithFormat:@"type=3&token=%@&secret=123&login=%@",[tokenData accessToken.secret,self.isLogin];
    //  [dconnection fetch:1 withPostdata:pdata withGetData:@"" isSilent:NO];
    
    if (pdata)
    {
        [webview removeFromSuperview];
        objAppDelegate.variableGoogleAddedGrantAccess = YES;
        GrantAccessViewController *objGrantAccessVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GrantAccessViewController"];
        [self presentViewController:objGrantAccessVC animated:YES completion:nil];
        
    }
//    UIAlertView *alertView = [[UIAlertView alloc]
//                              initWithTitle:@"Google Access TOken"
//                              message:pdata
//                              delegate:nil
//                              cancelButtonTitle:@"OK"
//                              otherButtonTitles:nil];
//    [alertView show];
}
-(IBAction)close_click:(id)sender{
    [view removeFromSuperview];

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [view removeFromSuperview];

}

///////////////////  -   google sign in end  -   ///////////////////////

@end
