//
//  GifImageWebService.m
//  GifImageDisplay
//
//  Created by Manasi Shah on 28/01/15.
//  Copyright (c) 2015 Manasi Shah. All rights reserved.
//

#import "GifImageWebService.h"
#import "GifViewController.h"


#define ShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()[UIApplication sharedApplication].networkActivityIndicatorVisible = NO
#define SERVER_IP @"api.giphy.com"

@implementation GifImageWebService


- (id)init:(id)classObject
{
    self = [super init];
    if (self){
        // Custom initialization of the delegate to the object of Viewcontroller handling the result
        delegate = (GifViewController *) classObject;        
    }
    return self;
}

#pragma mark - Custom Methods

-(void) showAlertMessage:(NSString *)errMsg alertViewTitle:(NSString *)tiltle
{
    
    UIAlertView *errorAlertView=[[UIAlertView alloc]initWithTitle:tiltle message:errMsg  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [errorAlertView show];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NoInternetConnection" object:nil userInfo:nil];
}

#pragma mark - Connect to Server method
 - (void) connectToServer:(NSString*)urlString andQueryString:(NSString*)queryString andKeyString:(NSString *) keyString limit:(NSInteger) limit offset:(NSInteger) offset isSearch:(BOOL) isSearch{
    
    ShowNetworkActivityIndicator();
    
    //Check if the reachability conditions are satisfied
    if ([self reachable]) {
        NSString *query;
        
        //Form the entire URL with query parameters
        if(isSearch ==YES)
        {
            query = [[NSString alloc]initWithFormat:@"?q=%@&api_key=%@&limit=%ld&offset=%ld",queryString ,keyString,limit,offset];
        }else{
            query = [[NSString alloc]initWithFormat:@"?api_key=%@",keyString];
        }
        
        urlString = [urlString stringByAppendingString:query];
     
        //Form NSMutableRequest oject with different properties appropriate for GET method
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",urlString]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1000.0];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        //allocate a new operation queue
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        //Loads the data for a URL request and executes a handler block on an
        //operation queue when the request completes or fails.
        
      [NSURLConnection
         sendAsynchronousRequest:request
         queue:queue
         completionHandler:^(NSURLResponse *response,
                             NSData *data,
                             NSError *error) {
             if ([data length] >0 && error == nil){
                 //process the JSON response
                 //use the main queue so that we can interact with the screen
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self startParser:data];
                 });
             }
             else if ([data length] == 0 && error == nil){
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [self showAlertMessage:@"Please check your connection and try again." alertViewTitle:@"No internet connection"];
                     
                 });
             }
             else if (error != nil){
                 dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertMessage:@"Please check your connection and try again." alertViewTitle:@"No internet connection"];
                 });
             }
         }];
        
    }
}
//Function to parse raw data using SBJSON into JSON data
-(void)startParser:(NSData *) data
{
    @try{
        
        NSError *myError = nil;
        
        parsedJSONResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
        if(parsedJSONResult){
            HideNetworkActivityIndicator();
        }
        [delegate completeServerContact:parsedJSONResult];
        
    }@catch (NSException *e) {
        NSLog(@"fetchData %@", [e reason]);
    }
}

//Function to check the reachability of Internet and the host using Reachability class
- (BOOL)reachable
{
    //Check for internet connection
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [hostReach currentReachabilityStatus];
    
    //Check for Host availability
    Reachability *reachable = [Reachability reachabilityWithHostName:SERVER_IP];
    NetworkStatus netHostStatus = [reachable currentReachabilityStatus];
    
    if (alert != nil) {
        [alert dismissWithClickedButtonIndex:0 animated:NO];
        alert = nil;
    }
    
    if (netStatus == NotReachable )
    {
        [self showAlertMessage:@"Please check your connection and try again." alertViewTitle:@"No internet connection"];
        
        return NO;
        
    }
    else if(netHostStatus == NotReachable)
    {
        [self showAlertMessage:@"Server is not reachable right now. Please try later." alertViewTitle:@"Host not reachable"];
        
        return NO;
    }
    return YES;
}


@end
