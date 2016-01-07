//
//  ViewController.h
//  Camera App
//
//  Created by Nina Yang on 11/5/15.
//  Copyright © 2015 Nina Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <QuartzCore/QuartzCore.h>
#import "PreviewView.h"

@interface CameraViewController : UIViewController <AVCaptureFileOutputRecordingDelegate, AVAudioRecorderDelegate>

@property (weak, nonatomic) IBOutlet PreviewView *imagePreview;
@property (weak, nonatomic) IBOutlet UIButton *changeCamera;
@property (weak, nonatomic) IBOutlet UIButton *photoOrVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *libraryFolder;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) int totalSeconds;

@property (strong, nonatomic) UIBarButtonItem *photoButton;
@property (strong, nonatomic) UIBarButtonItem *videoButton;
@property (strong, nonatomic) NSMutableArray *photoVideoFiles;
@property (strong, nonatomic) NSMutableArray *imageFiles;
@property (strong, nonatomic) UIImage *savedPhoto;
@property (strong, nonatomic) NSURL *savedVideo;

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, getter=isSessionRunning) BOOL sessionRunning;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;

- (void)takePhoto;

- (IBAction)openLibrary:(id)sender;
- (IBAction)changeCamera:(id)sender;

@end

