//
//  ImageViewController.m
//  Camera App
//
//  Created by Nina Yang on 11/27/15.
//  Copyright © 2015 Nina Yang. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () {
    AVPlayer *_player;
    AVURLAsset *_asset;
    id<NSObject> _timeObserverToken;
    AVPlayerItem *_playerItem;
}

@property (readonly) AVPlayerLayer *playerLayer;
@property (nonatomic) AVPlayerItem * playerItem;

@end

@implementation ImageViewController

static int ImageViewControllerKVOContext = 0;

#pragma mark - Views

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserver:self forKeyPath:@"asset" options:NSKeyValueObservingOptionNew context:&ImageViewControllerKVOContext];
    [self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&ImageViewControllerKVOContext];
    [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&ImageViewControllerKVOContext];
    
    self.slowSpeed = [[UIBarButtonItem alloc]initWithTitle:@"Slow" style:UIBarButtonItemStylePlain target:self action:@selector(slowSpeedMode)];
    self.normalSpeed = [[UIBarButtonItem alloc]initWithTitle:@"Normal" style:UIBarButtonItemStylePlain target:self action:@selector(normalSpeedMode)];
    self.fastSpeed = [[UIBarButtonItem alloc]initWithTitle:@"Fast" style:UIBarButtonItemStylePlain target:self action:@selector(fastSpeedMode)];
    self.toolbarSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    self.playButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playVideo)];
    self.pauseButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(playVideo)];
    
    self.toolbar.items = [NSArray arrayWithObjects:self.slowSpeed, self.normalSpeed, self.fastSpeed, self.toolbarSpace, self.playButton, nil];
    self.toolbarItemsCopy = [self.toolbar.items mutableCopy];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSPredicate *photoFilter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"];
    NSPredicate *videoFilter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.mov'"];
    
    NSLog(@"%@", self.filePath);
    
    if ([photoFilter evaluateWithObject:self.filePath] == YES) {
        NSLog(@"It's a photo");
        self.previewImageView.hidden = NO;
        self.toolbar.hidden = YES;
        self.previewImageView.image = [UIImage imageWithContentsOfFile:self.filePath];
    }
    if ([videoFilter evaluateWithObject:self.filePath] == YES) {
        NSLog(@"It's a video");
        self.previewImageView.hidden = YES;
        [self videoMode];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (_timeObserverToken) {
        [self.player removeTimeObserver:_timeObserverToken];
        _timeObserverToken = nil;
    }
    
    [self.player pause];
    
    [self removeObserver:self forKeyPath:@"asset" context:&ImageViewControllerKVOContext];
    [self removeObserver:self forKeyPath:@"player.rate" context:&ImageViewControllerKVOContext];
    [self removeObserver:self forKeyPath:@"player.currentItem.status" context:&ImageViewControllerKVOContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Video Mode

- (void)videoMode {
    self.playerView.hidden = NO;
    self.toolbar.hidden = NO;
    NSURL *fileURL = [NSURL fileURLWithPath:self.filePath];
    NSLog(@"%@", fileURL);
    
    self.playerView.playerLayer.player = self.player;
    self.playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    self.asset = [AVURLAsset assetWithURL:fileURL];
    [self normalSpeedMode];
}

#pragma mark - Player Properties

+ (NSArray *)assetKeysRequiredToPlay {
    return @[@"playable", @"hasProtectedContent"];
}

- (AVPlayer *)player {
    if (!_player)
        _player = [[AVPlayer alloc] init];
    return _player;
}

- (CMTime)currentTime {
    return self.player.currentTime;
}

- (void)setCurrentTime:(CMTime)newCurrentTime {
    [self.player seekToTime:newCurrentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (CMTime)duration {
    return self.player.currentItem ? self.player.currentItem.duration : kCMTimeZero;
}

- (float)rate {
    return self.player.rate;
}

- (void)setRate:(float)newRate {
    self.player.rate = newRate;
}

- (AVPlayerLayer *)playerLayer {
    return self.playerView.playerLayer;
}

- (AVPlayerItem *)playerItem {
    return _playerItem;
}

- (void)setPlayerItem:(AVPlayerItem *)newPlayerItem {
    if (_playerItem != newPlayerItem) {
        
        _playerItem = newPlayerItem;
        
        // If needed, configure player item here before associating it with a player
        // (example: adding outputs, setting text style rules, selecting media options)
        [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    }
}

#pragma mark - Asset Loading

- (void)asynchronouslyLoadURLAsset:(AVURLAsset *)newAsset {
    [newAsset loadValuesAsynchronouslyForKeys:ImageViewController.assetKeysRequiredToPlay completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (newAsset != self.asset) {
                return;
            }
            for (NSString *key in self.class.assetKeysRequiredToPlay) {
                NSError *error = nil;
                if ([newAsset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
                    
                    NSString *message = [NSString localizedStringWithFormat:NSLocalizedString(@"error.asset_key_%@_failed.description", @"Can't use this AVAsset because one of it's keys failed to load"), key];
                    
                    [self handleErrorWithMessage:message error:error];
                    
                    return;
                }
            }
            if (!newAsset.playable || newAsset.hasProtectedContent) {
                NSString *message = NSLocalizedString(@"error.asset_not_playable.description", @"Can't use this AVAsset because it isn't playable or has protected content");
                
                [self handleErrorWithMessage:message error:nil];
                
                return;
            }
            
            self.playerItem = [AVPlayerItem playerItemWithAsset:newAsset];
        });
    }];
}

#pragma mark - Actions

- (void)slowSpeedMode {
    NSLog(@"Slow speed mode");
    [self.slowSpeed setEnabled:NO];
    [self.normalSpeed setEnabled:YES];
    [self.fastSpeed setEnabled:YES];
    
    self.rateValue = 0.5;
    if (self.player.rate != 0) {
        [self setRate:self.rateValue];
    }
}

- (void)normalSpeedMode {
    NSLog(@"Normal speed mode");
    [self.slowSpeed setEnabled:YES];
    [self.normalSpeed setEnabled:NO];
    [self.fastSpeed setEnabled:YES];
    
    self.rateValue = 1.0;
    if (self.player.rate != 0) {
        [self setRate:self.rateValue];
    }
}

- (void)fastSpeedMode {
    NSLog(@"Fast speed mode");
    [self.slowSpeed setEnabled:YES];
    [self.normalSpeed setEnabled:YES];
    [self.fastSpeed setEnabled:NO];
    
    self.rateValue = 2.0;
    if (self.player.rate != 0) {
        [self setRate:self.rateValue];
    }
}

- (void)playVideo {
    if (self.player.rate == 0) {
        // not playing foward so play
        if (CMTIME_COMPARE_INLINE(self.currentTime, ==, self.duration)) {
            // at end so got back to begining
            self.currentTime = kCMTimeZero;
        }
        NSLog(@"%f", self.rateValue);
        [self setRate:self.rateValue];
    } else {
        // playing so pause
        [self.player pause];
    }
}

#pragma mark - Key Value Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context != &ImageViewControllerKVOContext) {
        // KVO isn't for us.
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"asset"]) {
        if (self.asset) {
            [self asynchronouslyLoadURLAsset:self.asset];
        }
    }
    else if ([keyPath isEqualToString:@"player.rate"]) {
        // Update playPauseButton image
        
        double newRate = [change[NSKeyValueChangeNewKey] doubleValue];
        
        if (newRate != 0) {
            [self.toolbarItemsCopy removeObject:self.playButton];
            [self.toolbarItemsCopy addObject:self.pauseButton];
            self.toolbar.items = self.toolbarItemsCopy;
        } else {
            [self.toolbarItemsCopy removeObject:self.pauseButton];
            [self.toolbarItemsCopy addObject:self.playButton];
            self.toolbar.items = self.toolbarItemsCopy;
        }
    }
    else if ([keyPath isEqualToString:@"player.currentItem.status"]) {
        // Display an error if status becomes Failed
        
        // Handle NSNull value for NSKeyValueChangeNewKey, i.e. when player.currentItem is nil
        NSNumber *newStatusAsNumber = change[NSKeyValueChangeNewKey];
        AVPlayerItemStatus newStatus = [newStatusAsNumber isKindOfClass:[NSNumber class]] ? newStatusAsNumber.integerValue : AVPlayerItemStatusUnknown;
        
        if (newStatus == AVPlayerItemStatusFailed) {
            [self handleErrorWithMessage:self.player.currentItem.error.localizedDescription error:self.player.currentItem.error];
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"currentTime"]) {
        return [NSSet setWithArray:@[ @"player.currentItem.currentTime" ]];
    } else if ([key isEqualToString:@"rate"]) {
        return [NSSet setWithArray:@[ @"player.rate" ]];
    } else {
        return [super keyPathsForValuesAffectingValueForKey:key];
    }
}

#pragma mark - Error Handling

- (void)handleErrorWithMessage:(NSString *)message error:(NSError *)error {
    NSLog(@"Error occured with message: %@, error: %@.", message, error);
    
    NSString *alertTitle = NSLocalizedString(@"alert.error.title", @"Alert title for errors");
    NSString *defaultAlertMesssage = NSLocalizedString(@"error.default.description", @"Default error message when no NSError provided");
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:alertTitle message:message ?: defaultAlertMesssage preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *alertActionTitle = NSLocalizedString(@"alert.error.actions.OK", @"OK on error alert");
    UIAlertAction *action = [UIAlertAction actionWithTitle:alertActionTitle style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    
    [self presentViewController:controller animated:YES completion:nil];
}

@end
