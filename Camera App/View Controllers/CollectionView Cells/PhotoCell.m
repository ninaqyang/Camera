//
//  PhotoCell.m
//  Camera App
//
//  Created by Nina Yang on 11/20/15.
//  Copyright © 2015 Nina Yang. All rights reserved.
//

#import "PhotoCell.h"

@implementation PhotoCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor blackColor];
    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
//    self.layer.shadowColor = [[UIColor blackColor]CGColor];
//    self.layer.shadowOpacity = 0.3;
//    self.layer.shadowRadius = 3.0;
//    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}

@end
