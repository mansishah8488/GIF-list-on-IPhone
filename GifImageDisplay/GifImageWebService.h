//
//  GifImageWebService.h
//  GifImageDisplay
//
//  Created by Manasi Shah on 28/01/15.
//  Copyright (c) 2015 Manasi Shah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJSON.h"
#import "Reachability.h"
#import <UIKit/UIKit.h>


@interface GifImageWebService : NSObject
{
    NSMutableData *webData;
    NSMutableDictionary *parsedJSONResult;
    id delegate;
    UIAlertView * alert;
    NSURLConnection *conn;
}

//Server comminication method to retrieve the JSON result from GIPHY-API

- (id) init:(id)classObject;
- (void) startParser:(NSData *) data;
- (void) connectToServer:(NSString*)urlString andQueryString:(NSString*)queryString andKeyString:(NSString *) keyString limit:(NSInteger) limit offset:(NSInteger) offset isSearch:(BOOL) isSearch;
- (BOOL) reachable;

@end
