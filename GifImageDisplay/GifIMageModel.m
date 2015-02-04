//
//  GifIMageModel.m
//  GifImageDisplay
//
//  Created by Manasi Shah on 29/01/15.
//  Copyright (c) 2015 Manasi Shah. All rights reserved.
//

#import "GifIMageModel.h"

@implementation GifIMageModel

@synthesize fixed_width_url = _fixed_width_url;
@synthesize height = _height;


-(id) initWithURL:(NSString *) fixed_width_url height:(NSString *)height
{
    self.fixed_width_url = fixed_width_url;
    self.height = height;
    
    return self;
}



@end
