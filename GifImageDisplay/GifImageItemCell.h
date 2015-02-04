//
//  GifImageItemCell.h
//  GifImageDisplay
//
//  Created by Manasi Shah on 29/01/15.
//  Copyright (c) 2015 Manasi Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImage.h"
#import "GifIMageModel.h"

@interface GifImageItemCell : UITableViewCell
{
}

//Custom cell contents

@property (strong, nonatomic) GifIMageModel *currentImageObject;
@property (weak,nonatomic) IBOutlet FLAnimatedImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *view;


@end
