//
//  NBViewController.m
//  Door Awesomest
//
//  Created by Tim Jarratt on 5/19/13.
//  Copyright (c) 2013 Nearbuy Systems. All rights reserved.
//

#import "NBViewController.h"

@interface NBViewController ()

@end

@implementation NBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.username_field = [[UITextField alloc] initWithFrame:CGRectMake(80, 80, 160, 40)];
    [[self username_field] setBorderStyle:UITextBorderStyleRoundedRect];
    [[self username_field] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [[self username_field] setTextAlignment:NSTextAlignmentCenter];
    [self username_field].contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    self.password_field = [[UITextField alloc] initWithFrame:CGRectMake(80, 140, 160, 40)];
    [[self password_field] setBorderStyle:UITextBorderStyleRoundedRect];
    [[self password_field] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [[self password_field] setSecureTextEntry:YES];
    [[self password_field] setTextAlignment:NSTextAlignmentCenter];
    [self password_field].contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    UIButton *submit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [submit setTitle:@"Authenticate" forState:UIControlStateNormal];
    [submit setFrame:CGRectMake(80, 210, 160, 40)];
    [submit addTarget:self action:@selector(start_authentication) forControlEvents:UIControlEventTouchUpInside];
    
    [[self view] addSubview:self.username_field];
    [[self view] addSubview:self.password_field];
    [[self view] addSubview:submit];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss_keyboard)];
    [[self view] addGestureRecognizer:tap];
}

- (void) dismiss_keyboard {
    [[self username_field] resignFirstResponder];
    [[self password_field] resignFirstResponder];
}

- (void) start_authentication {
    BOOL authenticated = [self authenticate];
    
    if (authenticated) {
        UIButton *side_door = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [side_door setTitle: @"Side Door" forState:UIControlStateNormal];
        [side_door addTarget:self action:@selector(open_side_door) forControlEvents:UIControlEventTouchUpInside];
        [side_door setFrame:CGRectMake(80, 210, 160, 40)];
        
        UIButton *front_door = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [front_door setTitle: @"Front Door" forState:UIControlStateNormal];
        [front_door addTarget:self action:@selector(open_front_door) forControlEvents:UIControlEventTouchUpInside];
        [front_door setFrame:CGRectMake(80, 300, 160, 40)];
        
        [[self view] addSubview:side_door];
        [[self view] addSubview:front_door];
    }
}

- (BOOL)authenticate {
    NSString *username = [[self username_field] text];
    NSString *password = [[self password_field] text];
    
    NSURL *auth_url = [NSURL URLWithString:@"https://door.nearbuysystems.com/auth"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:auth_url];
    [request setPostValue:username forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
    [request startSynchronous];

    NSLog(@"Request: %@, code %d, body: %@", [[request url] absoluteString], [request responseStatusCode], [request responseString]);
    
    return [request responseStatusCode] == 200;
}

- (void) open_door: (NSString *)door {
    NSURL *open_url = [NSURL URLWithString:@"https://door.nearbuysystems.com/open"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:open_url];
    [request setPostValue:door forKey:@"door"];
    [request startAsynchronous];
}

- (void)open_front_door {
    [self open_door:@"Front Door"];
}

- (void)open_side_door {
    [self open_door:@"Side Door"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
