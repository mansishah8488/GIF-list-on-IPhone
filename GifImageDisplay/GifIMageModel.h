//
//  GifIMageModel.h
//  GifImageDisplay
//
//  Created by Manasi Shah on 29/01/15.
//  Copyright (c) 2015 Manasi Shah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GifIMageModel : NSObject{
  
}

@property(nonatomic, strong)NSString*   fixed_width_url;   // URL for fixed width Gif Image
@property(nonatomic, strong)NSString*   height;

-(id) initWithURL:(NSString *) fixed_width_url height:(NSString *)height;
@end



