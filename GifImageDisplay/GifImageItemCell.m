//
//  GifImageItemCell.m
//  GifImageDisplay
//
//  Created by Manasi Shah on 29/01/15.
//  Copyright (c) 2015 Manasi Shah. All rights reserved.
//

#import "GifImageItemCell.h"

@implementation GifImageItemCell
@synthesize imageView;
@synthesize currentImageObject;
@synthesize view;

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
