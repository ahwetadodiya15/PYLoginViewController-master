//
//  GrantAccessViewController.m
//  PYLoginViewController
//
//  Created by Indresh on 22/01/15.
//  Copyright (c) 2015 Pyrus. All rights reserved.
//

#import "GrantAccessViewController.h"
#import "GrantAccessCell.h"

#import <AddressBookUI/AddressBookUI.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"

#import "APIKeys.h"

static NSString *kGrantTitleKey     =   @"kGrantTitleKey";
static NSString *kGrantSubtitleKey  =   @"kGrantSubtitleKey";
static NSString *kGrantImageKey =   @"kGrantImageKey";

@interface GrantAccessViewController ()<UITableViewDataSource,UITableViewDelegate,GPPSignInDelegate,UIAlertViewDelegate>
{
    LIALinkedInHttpClient *_client;
    NSArray *accountOptions;
    IBOutlet UITableView *tableViewGrantAccess;
    IBOutlet UIButton *buttonFinish;
}

@end

@implementation GrantAccessViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _client = [self client];
    
    objAppDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    objAppDelegate.variableGoogleAddedGrantAccess = NO;

    accountOptions = @[@{kGrantTitleKey:@"Contacts",kGrantSubtitleKey:@"(Required)",kGrantImageKey:[UIImage imageNamed:@"contacts"]},
                       @{kGrantTitleKey:@"Notifications",kGrantSubtitleKey:@"(Required)",kGrantImageKey:[UIImage imageNamed:@"notification"]},
                       @{kGrantTitleKey:@"Gmail",kGrantImageKey:[UIImage imageNamed:@"google"]},
                       @{kGrantTitleKey:@"LinkedIn",kGrantImageKey:[UIImage imageNamed:@"linkedIn"]}];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [tableViewGrantAccess reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return accountOptions.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GrantAccessCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([GrantAccessCell class]) forIndexPath:indexPath];
    
    NSDictionary *dict = accountOptions[indexPath.row];
    cell.labelAccount.text  = dict[kGrantTitleKey];
    cell.labelDetail.text   = dict[kGrantSubtitleKey];
    cell.imageViewAccount.image = dict[kGrantImageKey];
    
    if (dict[kGrantSubtitleKey])
    {
        cell.labelAccount.frame = CGRectMake(40, 10, 172, 15);
        cell.labelDetail.frame  = CGRectMake(40, 25, 172, 15);
    }
    else
    {
        CGPoint center = cell.labelAccount.center;
        center.y = cell.contentView.center.y;
        cell.labelAccount.center = center;
    }
    
    cell.buttonAdd.tag = indexPath.row;
    
    [cell.buttonAdd addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL accessGranted = NO;
    UIColor *color = [UIColor whiteColor];
    NSString *title = @"Add";
    
    switch (indexPath.row)
    {
        case 0:
        {
            ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();

            accessGranted = (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized);

            switch (status)
            {
                case kABAuthorizationStatusNotDetermined:
                {
                    title = @"Add";
                    color = [UIColor whiteColor];
                } break;
                case kABAuthorizationStatusAuthorized:
                {
                    title = @"Added";
                    color = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0];
                } break;
                case kABAuthorizationStatusDenied:
                {
                    title = @"Denied";
                    color = [UIColor redColor];
                } break;
                case kABAuthorizationStatusRestricted:
                {
                    title = @"Restricted";
                    color = [UIColor redColor];
                } break;
                default:
                    break;
            }
        } break;
        case 1:
        {
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
            {
                accessGranted = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
            }
            else
            {
                UIRemoteNotificationType status = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
                accessGranted = (status != UIRemoteNotificationTypeNone);
            }
            
            if (accessGranted)
            {
                title = @"Added";
                color = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0];
            }
            else
            {
                title = @"Add";
                color = [UIColor whiteColor];
            }

        } break;
        case 2:
        {
//            GTMOAuth2Authentication *authentication = [[GPPSignIn sharedInstance] authentication];
//            
//            accessGranted = (authentication != nil);
            
            if (objAppDelegate.variableGoogleAddedGrantAccess == YES)
            {
                title = @"Added";
                color = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0];
            }
            else
            {
                title = @"Added";
                color = [UIColor whiteColor];
            }
        } break;
        case 3:
        {
            accessGranted = ([[self.client accessToken] length] != 0);
            
            if (accessGranted)
            {
                title = @"Added";
                color = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0];
            }
            else
            {
                title = @"Add";
                color = [UIColor whiteColor];
            }

        } break;
    }
    
    [cell.buttonAdd setTitle:title forState:UIControlStateNormal];
    [cell.buttonAdd setTitleColor:color forState:UIControlStateNormal];
    [cell.buttonAdd setUserInteractionEnabled:!accessGranted];
    
    if (accessGranted)
    {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryView = cell.buttonAdd;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

-(void)addButtonClicked:(UIButton*)button
{
    switch (button.tag)
    {
        case 0:
        {
            ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
            
            if (status == kABAuthorizationStatusNotDetermined)
            {
                // Request authorization to Address Book
                ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);

                ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                    
                    if (granted) {
                        [tableViewGrantAccess reloadData];
                    } else {
                        // User denied access
                        // Display an alert telling user the contact could not be added
                    }
                });
            }
            else if (status == kABAuthorizationStatusDenied)
            {
                BOOL isIOS8 = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0);
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"You've previously denied access. You can enable access in Settings->Privacy->Contacts" delegate:self cancelButtonTitle:(isIOS8? @"Cancel":@"OK") otherButtonTitles:(isIOS8? @"Settings":nil), nil];
                
                alertView.tag = 1;
                [alertView show];
            }
            else if (status == kABAuthorizationStatusRestricted)
            {
                BOOL isIOS8 = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0);
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"You're not authorized to access contacts possibly due to active restrictions such as parental controls being in place." delegate:self cancelButtonTitle:(isIOS8? @"Cancel":@"OK") otherButtonTitles:(isIOS8? @"Settings":nil), nil];
                
                alertView.tag = 1;
                [alertView show];
            }
        } break;
        case 1:
        {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            {
                [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
                [[UIApplication sharedApplication] registerForRemoteNotifications];
                
                
            }
            else
            {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
                 (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
            }
            
            [tableViewGrantAccess reloadData];
        } break;
        case 2:
        {
            GPPSignIn *signIn = [GPPSignIn sharedInstance];
            signIn.shouldFetchGooglePlusUser = YES;
            //signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
            
            // You previously set kClientId in the "Initialize the Google+ client" step
            signIn.clientID = kGoogleClientId;
            
            // Uncomment one of these two statements for the scope you chose in the previous step
            signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
            //signIn.scopes = @[ @"profile" ];            // "profile" scope
            
            // Optional: declare signIn.actions, see "app activities"
            signIn.delegate = self;
            
            [signIn authenticate];
        } break;
        case 3:
        {
            [self.client getAuthorizationCode:^(NSString *code) {
                [self.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
                    NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
                    [self requestMeWithToken:accessToken];
                    
                    [tableViewGrantAccess reloadData];
                }                   failure:^(NSError *error) {
                    NSLog(@"Quering accessToken failed %@", error);
                }];
            }                      cancel:^{
                NSLog(@"Authorization was cancelled by user");
            }                     failure:^(NSError *error) {
                NSLog(@"Authorization failed %@", error);
            }];
        } break;
    }
}

- (IBAction)finishAction:(UIButton *)sender
{

}

#pragma mark - AlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if (alertView.cancelButtonIndex != buttonIndex)
        {
            if (&UIApplicationOpenSettingsURLString != NULL)
            {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }
            else
            {
                NSURL *url = [NSURL URLWithString:@"prefs://"];
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}

#pragma mark - Google Plus Authentication

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth error: (NSError *) error {
    if (auth)
    {
        [tableViewGrantAccess reloadData];
    }
}

#pragma mark - LinkedIn Authentication

- (void)requestMeWithToken:(NSString *)accessToken {
    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"current user %@", result);
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

@end

