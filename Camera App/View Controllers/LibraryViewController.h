//
//  LibraryViewController.h
//  Camera App
//
//  Created by Nina Yang on 11/20/15.
//  Copyright © 2015 Nina Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LibraryViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *mediaCV;
@property (weak, nonatomic) IBOutlet UICollectionView *videoCV;

@property (strong, nonatomic) NSMutableArray *photoVideoFiles;
@property (strong, nonatomic) NSArray *sortedFiles;
@property (strong, nonatomic) NSArray *photoFiles;
@property (strong, nonatomic) NSArray *videoFiles;
@property (strong, nonatomic) NSMutableArray *photoImageFiles;
@property (strong, nonatomic) NSMutableArray *videoImageFiles;
@property (strong, nonatomic) NSArray *mediaFiles;
@property (strong, nonatomic) NSMutableArray *sectionArray;

@property (strong, nonatomic) NSString *photoPath;
@property (strong, nonatomic) NSString *videoPath;

- (UIImage *)generateThumbnailImage:(NSString *)filepath;

@end
