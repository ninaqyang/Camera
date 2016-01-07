//
//  LibraryViewController.m
//  Camera App
//
//  Created by Nina Yang on 11/20/15.
//  Copyright © 2015 Nina Yang. All rights reserved.
//

#import "LibraryViewController.h"
#import "UINavigationBar+CustomNav.h"
#import "PhotoCell.h"
#import "VideoCell.h"
#import "ImageViewController.h"

@interface LibraryViewController ()

@end

static NSString * const PhotoCellIdentifier = @"photoCell";
static NSString * const VideoCellIdentifier = @"videoCell";

@implementation LibraryViewController

#pragma mark - Views

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UINavigationBar customizeNavigationBar:self.navigationController.navigationBar];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"Library";
    
    self.photoVideoFiles = [[NSMutableArray alloc]init];
    self.photoImageFiles = [[NSMutableArray alloc]init];
    self.videoImageFiles = [[NSMutableArray alloc]init];
    self.sectionArray = [[NSMutableArray alloc]init];
    [self loadDocumentsDirectoryFiles];
    
    self.mediaFiles = [[NSArray alloc] initWithObjects:self.photoImageFiles, self.videoImageFiles, nil];
        
    UICollectionViewFlowLayout *mediaFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    mediaFlowLayout.sectionInset = UIEdgeInsetsMake(20, 10, 20, 10);
    [mediaFlowLayout setItemSize:CGSizeMake(80, 80)];
    [mediaFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.mediaCV setCollectionViewLayout:mediaFlowLayout];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.mediaCV registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:nil] forCellWithReuseIdentifier:PhotoCellIdentifier];
    [self.mediaCV registerNib:[UINib nibWithNibName:@"VideoCell" bundle:nil] forCellWithReuseIdentifier:VideoCellIdentifier];
    
    NSLog(@"%@", self.photoImageFiles);
    NSLog(@"Photo Image Files: %lu", self.photoImageFiles.count);
    
    NSLog(@"%@", self.videoImageFiles);
    NSLog(@"Video Image Files: %lu", self.videoImageFiles.count);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Get Media Files

- (void)loadDocumentsDirectoryFiles {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *error;
    NSArray *directoryContents =  [[NSFileManager defaultManager]contentsOfDirectoryAtPath:documentsDirectory error:&error];
    NSLog(@"%@", directoryContents);
    
    for (NSString *aPath in directoryContents) {
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:aPath];
        [self.photoVideoFiles addObject:fullPath];
    }
    
    self.sortedFiles = [[self.photoVideoFiles reverseObjectEnumerator]allObjects];
    NSLog(@"%@", self.sortedFiles);
    
    NSPredicate *photoFilter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"];
    self.photoFiles = [self.sortedFiles filteredArrayUsingPredicate:photoFilter];
    NSLog(@"%@", self.photoFiles);
    
    NSPredicate *videoFilter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.mov'"];
    self.videoFiles = [self.sortedFiles filteredArrayUsingPredicate:videoFilter];
    NSLog(@"%@", self.videoFiles);
    
    for (NSString *photo in self.photoFiles) {
        UIImage *photoThumbnail = [UIImage imageWithContentsOfFile:photo];
        [self.photoImageFiles addObject:photoThumbnail];
    }
    NSLog(@"%@", self.photoImageFiles);

    for (NSString *video in self.videoFiles) {
        UIImage *videoThumbnail = [self generateThumbnailImage:video];
        [self.videoImageFiles addObject:videoThumbnail];
    }
    NSLog(@"%@", self.videoImageFiles);
}

- (UIImage *)generateThumbnailImage:(NSString *)filepath {
    NSURL *url = [NSURL fileURLWithPath:filepath];
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return thumbnail;
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.mediaFiles count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    self.sectionArray = [self.mediaFiles objectAtIndex:section];
    return [self.sectionArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier forIndexPath:indexPath];
        
        UIImage *image = [self.photoImageFiles objectAtIndex:indexPath.row];
        cell.photoImageView.image = image;
        
        return cell;
    } else {
        VideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:VideoCellIdentifier forIndexPath:indexPath];
        
        UIImage *image = [self.videoImageFiles objectAtIndex:indexPath.row];
        cell.videoImageView.image = image;
        
        return cell;
    }
}

#pragma mark - Collection View Data Source

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageViewController *imageVC = [[ImageViewController alloc]initWithNibName:@"ImageViewController" bundle:nil];
    
    if (indexPath.section == 0) {
        self.photoPath = [self.photoFiles objectAtIndex:indexPath.row];
        imageVC.filePath = self.photoPath;
        [self.navigationController pushViewController:imageVC animated:YES];
    }
    if (indexPath.section == 1) {
        self.videoPath = [self.videoFiles objectAtIndex:indexPath.row];
        imageVC.filePath = self.videoPath;
        [self.navigationController pushViewController:imageVC animated:YES];
    }
}

@end
