//
//  PreviewView.m
//  Camera App
//
//  Created by Nina Yang on 11/12/15.
//  Copyright © 2015 Nina Yang. All rights reserved.
//

#import "PreviewView.h"
#import "CameraViewController.h"

@implementation PreviewView

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session {
    AVCaptureVideoPreviewLayer *videoPreviewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    return videoPreviewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session {
    AVCaptureVideoPreviewLayer *videoPreviewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    videoPreviewLayer.session = session;
}

@end
