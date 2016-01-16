//
//  ViewController.h
//  WatchSugar
//
//  Created by Adam A. Wolf on 12/14/15.
//  Copyright © 2015 Flairify. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AuthenticationController;
@class WebRequestController;

@interface ViewController : UIViewController

@property (nonatomic, strong) AuthenticationController *authenticationController;
@property (nonatomic, strong) WebRequestController *webRequestController;

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray <UIView *> *loginViews;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray <UIView *> *loggedInViews;

@property (nonatomic, strong) IBOutlet UILabel *loginInformationLabel;
@property (nonatomic, strong) IBOutlet UITextField *accountNameTextView;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextView;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;

- (IBAction)loginButtonTapped:(id)sender;
- (IBAction)logoutButtonTapped:(id)sender;

@end

