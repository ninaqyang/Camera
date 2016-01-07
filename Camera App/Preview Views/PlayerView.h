//
//  PlayerView.h
//  Camera App
//
//  Created by Nina Yang on 11/30/15.
//  Copyright © 2015 Nina Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class AVPlayer;

@interface PlayerView : UIView

@property AVPlayer *player;
@property (readonly) AVPlayerLayer *playerLayer;

@end
