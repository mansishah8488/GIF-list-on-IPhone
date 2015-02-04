//
//  AppDelegate.h
//  GifImageDisplay
//
//  Created by Manasi Shah on 28/01/15.
//  Copyright (c) 2015 Manasi Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GifViewController.h"

@class GifViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GifViewController *viewController;


@end

