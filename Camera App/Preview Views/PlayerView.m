//
//  PlayerView.m
//  Camera App
//
//  Created by Nina Yang on 11/30/15.
//  Copyright © 2015 Nina Yang. All rights reserved.
//

#import "PlayerView.h"

@implementation PlayerView

- (AVPlayer *)player {
    return self.playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

- (void)setVideoFillMode: (NSString *)fillMode {
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}

@end
