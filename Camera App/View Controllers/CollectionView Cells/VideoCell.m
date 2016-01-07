//
//  VideoCell.m
//  Camera App
//
//  Created by Nina Yang on 11/27/15.
//  Copyright © 2015 Nina Yang. All rights reserved.
//

#import "VideoCell.h"

@implementation VideoCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor blackColor];
    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
}

@end
