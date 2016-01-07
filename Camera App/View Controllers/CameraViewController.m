//
//  ViewController.m
//  Camera App
//
//  Created by Nina Yang on 11/5/15.
//  Copyright © 2015 Nina Yang. All rights reserved.
//

#import "CameraViewController.h"
#import "UINavigationBar+CustomNav.h"
#import "LibraryViewController.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * SessionRunningContext = &SessionRunningContext;

@interface CameraViewController ()

@end

@implementation CameraViewController

#pragma mark - Views

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UINavigationBar customizeNavigationBar:self.navigationController.navigationBar];
    [self navigationItemStyle];
    
    self.videoButton.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.timeLabel.hidden = YES;

    [self sessionSetup];
    
    [self photoButtonClicked];
    
    self.photoVideoFiles = [[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.timeLabel.hidden = YES;
    
    [self sessionRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation Item Style

- (void)navigationItemStyle {
    UIImage *photoImage = [UIImage imageNamed:@"photo"];
    self.photoButton = [[UIBarButtonItem alloc] initWithImage:photoImage landscapeImagePhone:photoImage style:UIBarButtonItemStylePlain target:self action:@selector(photoButtonClicked)];
    [self.photoButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = self.photoButton;
    
    UIImage *videoImage = [UIImage imageNamed:@"video"];
    self.videoButton = [[UIBarButtonItem alloc] initWithImage:videoImage landscapeImagePhone:videoImage style:UIBarButtonItemStylePlain target:self action:@selector(videoButtonClicked)];
    [self.videoButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = self.videoButton;
}

#pragma mark - UIBarButtonItems Mode

- (void)photoButtonClicked {
    NSLog(@"In photo capture mode");
    self.videoButton.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.photoButton.tintColor = [UIColor whiteColor];
    
    self.photoOrVideoButton.selected = NO;
    [self photoOrVideoMode:self.photoOrVideoButton];
    
//    [self.photoOrVideoButton setImage:[UIImage imageNamed:@"photo_button"] forState:UIControlStateNormal];
//    [self.photoOrVideoButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
}

- (void)videoButtonClicked {
    NSLog(@"In video capture mode");
    self.photoButton.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.videoButton.tintColor = [UIColor whiteColor];
    
    self.photoOrVideoButton.selected = YES;
    [self photoOrVideoMode:self.photoOrVideoButton];
    
//    [self.photoOrVideoButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
//    [self.photoOrVideoButton addTarget:self action:@selector(takeVideo) forControlEvents:UIControlEventTouchUpInside];
}

- (void)photoOrVideoMode:(UIButton *)button {
    if (self.photoOrVideoButton.selected == NO) {
        [self.photoOrVideoButton removeTarget:self action:@selector(takeVideo) forControlEvents:UIControlEventTouchUpInside];
        [self.photoOrVideoButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    } if (self.photoOrVideoButton.selected == YES) {
        [self.photoOrVideoButton removeTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
        [self.photoOrVideoButton addTarget:self action:@selector(takeVideo) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - AVCaptureSession

- (void)sessionSetup {
    self.captureSession = [[AVCaptureSession alloc]init];
    self.imagePreview.session = self.captureSession;
    
    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(self.sessionQueue, ^{
        self.backgroundRecordingID = UIBackgroundTaskInvalid;
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [CameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (!videoDeviceInput) {
            NSLog(@"Could not create video device input: %@", error);
        }
        
        [self.captureSession beginConfiguration];
        
        if ([self.captureSession canAddInput:videoDeviceInput]) {
            [self.captureSession addInput:videoDeviceInput];
            self.videoDeviceInput = videoDeviceInput;
            
            dispatch_async( dispatch_get_main_queue(), ^{
                UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
                AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
                if (statusBarOrientation != UIInterfaceOrientationUnknown) {
                    initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
                }
                
                AVCaptureVideoPreviewLayer *videoPreviewLayer = (AVCaptureVideoPreviewLayer *)self.imagePreview.layer;
                [videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
                
                videoPreviewLayer.connection.videoOrientation = initialVideoOrientation;
            });
        } else {
            NSLog(@"Could not add video device input to the session");
        }
        
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if (!audioDeviceInput) {
            NSLog( @"Could not create audio device input: %@", error );
        }
        
        if ([self.captureSession canAddInput:audioDeviceInput]) {
            [self.captureSession addInput:audioDeviceInput];
        } else {
            NSLog(@"Could not add audio device input to the session");
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc]init];
        if ([self.captureSession canAddOutput:movieFileOutput]) {
            [self.captureSession addOutput:movieFileOutput];
            
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if (connection.isVideoStabilizationSupported) {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            self.movieFileOutput = movieFileOutput;
        } else {
            NSLog(@"Could not add movie file output to the session");
        }
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
        if ([self.captureSession canAddOutput:stillImageOutput]) {
            stillImageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
            [self.captureSession addOutput:stillImageOutput];
            self.stillImageOutput = stillImageOutput;
        } else {
            NSLog(@"Could not add still image output to the session");
        }
        
        [self.captureSession commitConfiguration];
    });
}

- (void)sessionRunning {
    dispatch_async( self.sessionQueue, ^{
        [self addObservers];
        [self.captureSession startRunning];
        self.sessionRunning = self.captureSession.isRunning;
    });

}

#pragma mark - Device Configuration

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark - Notifications

- (void)addObservers {
    [self.captureSession addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:SessionRunningContext];
    [self.stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:CapturingStillImageContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == CapturingStillImageContext) {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (isCapturingStillImage) {
            dispatch_async( dispatch_get_main_queue(), ^{
//                self.photoOrVideoButton.highlighted = NO;
                
                self.imagePreview.layer.opacity = 0.0;
                [UIView animateWithDuration:0.25 animations:^{
                    self.imagePreview.layer.opacity = 1.0;
                }];
            } );
        }
    }
    else if (context == SessionRunningContext) {
        BOOL isSessionRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // Only enable the ability to change camera if the device has more than one camera.
            self.changeCamera.enabled = isSessionRunning && ([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1);
            self.photoOrVideoButton.enabled = isSessionRunning;
            self.libraryFolder.enabled = isSessionRunning;
        } );
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Actions

- (IBAction)changeCamera:(id)sender {
    self.changeCamera.enabled = NO;
    self.photoOrVideoButton.enabled = NO;
    self.libraryFolder.enabled = NO;
    
    dispatch_async(self.sessionQueue, ^{
        AVCaptureDevice *currentVideoDevice = self.videoDeviceInput.device;
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = currentVideoDevice.position;
        
        switch (currentPosition) {
            case AVCaptureDevicePositionUnspecified:
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
        }
        
        AVCaptureDevice *videoDevice = [CameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.videoDeviceInput];
        
        if ([self.captureSession canAddInput:videoDeviceInput]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nilSymbol) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            
            [self.captureSession addInput:videoDeviceInput];
            self.videoDeviceInput = videoDeviceInput;
        } else {
            [self.captureSession addInput:self.videoDeviceInput];
        }
        
        AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if (connection.isVideoStabilizationSupported) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        
        [self.captureSession commitConfiguration];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            self.changeCamera.enabled = YES;
            self.photoOrVideoButton.enabled = YES;
            self.libraryFolder.enabled = YES;
        });
    });
}

- (void)takePhoto {
    self.photoOrVideoButton.highlighted = NO;
    
    NSLog(@"Taking photo");
    
    dispatch_async( self.sessionQueue, ^{
        AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.imagePreview.layer;
        
        connection.videoOrientation = previewLayer.connection.videoOrientation;
        
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^( CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                
                // Saving to documents directory
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"Photo: %@.jpg", [self setTimeStamp]]];
                [imageData writeToFile:savedImagePath atomically:NO];
                
                [self.photoVideoFiles addObject:savedImagePath];
                NSLog(@"Photo Video Files: %@", self.photoVideoFiles);
                
//                self.savedPhoto = [UIImage imageWithContentsOfFile:savedImagePath];
//                [self.photoVideoFiles addObject:self.savedPhoto];
//                NSLog(@"%@", self.photoVideoFiles);
                
                // Saving to photo library
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                    
                        if ([PHAssetCreationRequest class]) {
                            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:imageData options:nil];
                            } completionHandler:^(BOOL success, NSError *error) {
                                if (! success) {
                                    NSLog(@"Error occurred while saving image to photo library: %@", error);
                                }
                            }];
                        } else {
                            NSString *temporaryFileName = [NSProcessInfo processInfo].globallyUniqueString;
                            NSString *temporaryFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[temporaryFileName stringByAppendingPathExtension:@"jpg"]];
                            NSURL *temporaryFileURL = [NSURL fileURLWithPath:temporaryFilePath];
                            
                            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                NSError *error = nil;
                                [imageData writeToURL:temporaryFileURL options:NSDataWritingAtomic error:&error];
                                if (error) {
                                    NSLog(@"Error occured while writing image data to a temporary file: %@", error);
                                } else {
                                    [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:temporaryFileURL];
                                }
                            } completionHandler:^(BOOL success, NSError *error) {
                                if (! success) {
                                    NSLog(@"Error occurred while saving image to photo library: %@", error);
                                }
                                
                                [[NSFileManager defaultManager] removeItemAtURL:temporaryFileURL error:nil];
                            }];
                        }
                    }
                }];
            } else {
                NSLog(@"Could not capture still image: %@", error);
            }
        }];
    } );
}

- (void)takeVideo {
    NSLog(@"Video will start recording");
    
    self.changeCamera.enabled = NO;
    self.photoOrVideoButton.enabled = NO;
    self.libraryFolder.enabled = NO;
    self.timeLabel.hidden = NO;
    
    dispatch_async( self.sessionQueue, ^{
        if (!self.movieFileOutput.isRecording) {
            if ([UIDevice currentDevice].isMultitaskingSupported) {
                self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }
            AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.imagePreview.layer;
            connection.videoOrientation = previewLayer.connection.videoOrientation;
            
            NSString *outputFileName = [NSProcessInfo processInfo].globallyUniqueString;
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"mov"]];
            [self.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
        } else {
            [self.movieFileOutput stopRecording];
            [self stopTimer];
        }
    });
}

- (IBAction)openLibrary:(id)sender {
    LibraryViewController *libraryVC = [[LibraryViewController alloc]initWithNibName:@"LibraryViewController" bundle:nil];
    [self.navigationController pushViewController:libraryVC animated:YES];
}

#pragma mark - File Output Recording Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.photoOrVideoButton.enabled = YES;
        self.photoOrVideoButton.selected = NO;
        self.photoOrVideoButton.highlighted = YES;
        
        self.totalSeconds = 0;
        [self startTimerWithTotalSeconds:self.totalSeconds];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
    });
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    UIBackgroundTaskIdentifier currentBackgroundRecordingID = self.backgroundRecordingID;
    self.backgroundRecordingID = UIBackgroundTaskInvalid;
    
    dispatch_block_t cleanup = ^{
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        if (currentBackgroundRecordingID != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:currentBackgroundRecordingID];
        }
    };
    
    BOOL success = YES;

    if (error) {
        NSLog(@"Movie file finishing error: %@", error);
        success = [error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] boolValue];
    }
    if (success) {
        // Saving to documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"Video: %@.mov", [self setTimeStamp]]];
        NSData *videoData = [NSData dataWithContentsOfURL:outputFileURL];
        [videoData writeToFile:savedImagePath atomically:NO];
        
        [self.photoVideoFiles addObject:savedImagePath];
        NSLog(@"Photo Video Files: %@", self.photoVideoFiles);
        
//        self.savedVideo = [NSURL fileURLWithPath:savedImagePath];
//        [self.photoVideoFiles addObject:self.savedVideo];
//        NSLog(@"%@", self.photoVideoFiles);
        
        // Saving to photo library
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    if ([PHAssetResourceCreationOptions class]) {
                        PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc]init];
                        options.shouldMoveFile = YES;
                        PHAssetCreationRequest *changeRequest = [PHAssetCreationRequest creationRequestForAsset];
                        [changeRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:outputFileURL options:options];
                    } else {
                        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
                    }
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    if (!success) {
                        NSLog( @"Could not save movie to photo library: %@", error );
                    }
                    cleanup();
                }];
            } else {
                cleanup();
            }
        }];
    } else {
        cleanup();
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.photoOrVideoButton.enabled = ( [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1 );
        self.changeCamera.enabled = YES;
        self.libraryFolder.enabled = YES;
        self.timeLabel.hidden = YES;
        
        self.photoOrVideoButton.highlighted = NO;
        self.photoOrVideoButton.selected = YES;
    });
}

#pragma mark - Timesstamp, Timer

- (NSString *)setTimeStamp {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
    
    NSDate *now = [[NSDate alloc] init];
    NSString *dateString = [format stringFromDate:now];

    return dateString;
}

- (void)startTimerWithTotalSeconds:(int)totalSeconds {
    int remainder = 0;
    
    int hours = totalSeconds/3600;
    remainder = totalSeconds%3600;
    
    int minutes = remainder/60;
    remainder = remainder%60;
    
    int seconds = remainder;
    
    NSString *timeNow = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    self.timeLabel.text = timeNow;
}

- (void)updateTimer:(NSTimer *)timer {
    self.totalSeconds += 1;
    [self startTimerWithTotalSeconds:self.totalSeconds];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

@end
