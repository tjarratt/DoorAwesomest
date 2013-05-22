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
    
    NSError *error;
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"DoorAwesomerUsername"];
    NSString *password = [STKeychain getPasswordForUsername:username andServiceName:@"DoorAwesomer" error:&error];
    NSLog(@"authenticating as %@:%@", username, password);
    
    BOOL authenticated = false;
    if (password != NULL) {
        authenticated = [self authenticateWithUsername:username andPassword:password];
        if (authenticated) {
            return [self show_door_buttons];
        }
    }

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

#pragma mark - UI twiddling
- (void) show_door_buttons {
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

#pragma mark - authentication
- (void) start_authentication {
    [[self password_field] resignFirstResponder];
    
    NSString *username = [[self username_field] text];
    NSString *password = [[self password_field] text];
    BOOL authenticated = [self authenticateWithUsername:username andPassword:password];
    
    if (authenticated) {
        NSError *error;
        NSString *username = [[self username_field] text];
        NSString *password = [[self password_field] text];
        
        [STKeychain storeUsername:username andPassword:password forServiceName:@"DoorAwesomer" updateExisting:true error:&error];
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"DoorAwesomerUsername"];
        
        NSString *read_username = [[NSUserDefaults standardUserDefaults] objectForKey:@"DoorAwesomerUsername"];
        NSLog(@"%@", read_username);
        
        [self show_door_buttons];
    }
}

- (BOOL)authenticateWithUsername: (NSString *) username andPassword:(NSString *) password {
    NSURL *auth_url = [NSURL URLWithString:@"https://door.nearbuysystems.com/auth"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:auth_url];
    [request setPostValue:username forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
    [request startSynchronous];

    NSLog(@"Request: %@, code %d, body: %@", [[request url] absoluteString], [request responseStatusCode], [request responseString]);
    
    NSError *error;
    NSData *data = [[request responseString] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json_response = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSString *auth_status = [json_response objectForKey:@"auth_status"];
    
    BOOL http_success = [request responseStatusCode] == 200;
    BOOL auth_failure = [auth_status isEqualToString:@"fail"];
    return http_success && !auth_failure;
}

#pragma mark - door opening methods
- (void) open_door: (NSString *)door {
    NSURL *open_url = [NSURL URLWithString:@"https://door.nearbuysystems.com/open"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:open_url];
    [request setPostValue:door forKey:@"door"];
    [request startSynchronous];
    
    NSString *response = [request responseString];
    NSLog(@"response body : %@", response);
}

- (void)open_front_door {
    [self open_door:@"Front Door"];
}

- (void)open_side_door {
    [self open_door:@"Side Door"];
}

#pragma mark - Memory warning
- (void)didReceiveMemoryWarning
{
    NSLog(@"Memory warning. Interesting");
    [super didReceiveMemoryWarning];
}

#pragma mark - ASINetwork delegate methods
- (void)requestFinished:(ASIHTTPRequest *)req {
    NSString *url = [[req url] absoluteString];
    
    int statusCode = [req responseStatusCode];
    NSString *responseBody = [req responseString];
    NSString *statusMessage = [req responseStatusMessage];
    NSLog(@"request: %@, got response code %d, message %@, body %@", url, statusCode, statusMessage, responseBody);
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSString *url = [[request url] absoluteString];
    NSError *error = [request error];
    NSLog(@"request %@ failed: %@", url, [error localizedDescription]);
}

@end
