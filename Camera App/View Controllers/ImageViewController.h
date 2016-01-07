//
//  ImageViewController.h
//  Camera App
//
//  Created by Nina Yang on 11/27/15.
//  Copyright © 2015 Nina Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "PlayerView.h"

@interface ImageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *slowSpeed;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *normalSpeed;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *fastSpeed;
@property (strong, nonatomic) UIBarButtonItem *playButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolbarSpace;
@property (strong, nonatomic) UIBarButtonItem *pauseButton;
@property (strong, nonatomic) NSMutableArray *toolbarItemsCopy;
@property (nonatomic) float rateValue;

@property (strong, nonatomic) NSString *filePath;
@property (readonly) AVPlayer *player;
@property AVURLAsset *asset;

@end
