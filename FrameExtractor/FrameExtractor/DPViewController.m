//
//  DPViewController.m
//  FrameExtractor
//
//  Created by Dipen on 02/01/14.
//  Copyright (c) 2014 Dipen Panchasara. All rights reserved.
//

#import "DPViewController.h"

@interface DPViewController ()

@end

@implementation DPViewController

@synthesize generator, composition;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [tfFileName setDelegate:self];
    [tfFileName setPlaceholder:@"Enter FileName"];
    
    [lblFileStatus setText:@"Enter filename"];
    [lblFileStatus setFont:[UIFont fontWithName:@"Arial" size:12.0f]];
    
    [lblFrames setText:@""];
    [lblVideoLength setText:@""];
    
    [btnProcess addTarget:self action:@selector(extractFrames) forControlEvents:UIControlEventTouchUpInside];
    [btnProcess setEnabled:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self removeAllFiles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)extractFrames
{
    [lblFileStatus setText:@"Processing..."];
    NSString *fileName = [[tfFileName text] stringByDeletingPathExtension];
    NSString *ext = [[tfFileName text] pathExtension];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:ext];
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    
    //setting up generator & compositor
    self.generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    
    //    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    self.generator.requestedTimeToleranceBefore = kCMTimeZero;
    self.generator.requestedTimeToleranceAfter = kCMTimeZero;
    
    generator.appliesPreferredTrackTransform = YES;
    self.composition = [AVVideoComposition videoCompositionWithPropertiesOfAsset:asset];
    
    NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
    NSTimeInterval frameDuration = CMTimeGetSeconds(composition.frameDuration);
    CGFloat totalFrames = round(duration/frameDuration);
    
    [lblFrames setText:[NSString stringWithFormat:@"%.2f Frames",totalFrames]];
    [lblVideoLength setText:[NSString stringWithFormat:@"Video Duration : %f",duration]];
    
    NSMutableArray * times = [[NSMutableArray alloc] init];
    // *** Fetch First 200 frames only ***
    for (int i=0; i<200; i++) {
        NSValue * time = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(i*frameDuration, composition.frameDuration.timescale)];
        [times addObject:time];
    }
    
//    for (int i=0; i<totalFrames; i++) {
//        NSValue * time = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(i*frameDuration, composition.frameDuration.timescale)];
//        [times addObject:time];
//    }
    __block NSInteger count = 0;
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        // If actualTime is not equal to requestedTime image is ignored
        if(CMTimeCompare(actualTime, requestedTime) == 0)
        {
            if (result == AVAssetImageGeneratorSucceeded) {
//                NSLog(@"%.02f     %.02f", CMTimeGetSeconds(requestedTime), CMTimeGetSeconds(actualTime));
                // Each log have differents actualTimes.
                // frame extraction is here...                
                NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                NSString *filePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.jpg",CMTimeGetSeconds(requestedTime)]];
                [UIImageJPEGRepresentation([UIImage imageWithCGImage:im], 0.8f) writeToFile:filePath atomically:YES];
                count++;
                [self performSelector:@selector(updateStatusWithFrame:) onThread:[NSThread mainThread] withObject:[NSString stringWithFormat:@"Processing %d of %.0f",count,totalFrames] waitUntilDone:NO];


            }
            else if(result == AVAssetImageGeneratorFailed)
                [lblFileStatus setText:@"Failed to Extract"];
            else if(result == AVAssetImageGeneratorCancelled)
                [lblFileStatus setText:@"Process Cancelled"];
        }
    };
    
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    [generator generateCGImagesAsynchronouslyForTimes:times completionHandler:handler];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *strFileName = [[textField.text stringByAppendingString:string] stringByDeletingPathExtension];
    NSString *strExtension = [[textField.text stringByAppendingString:string] pathExtension];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:strFileName ofType:strExtension];

    if(filePath != NULL)
    {
        [btnProcess setEnabled:YES];
        [lblFileStatus setText:@"File Found, Tap Process button"];
    }
    else
    {
        [lblFrames setText:@""];
        [lblVideoLength setText:@""];
        [btnProcess setEnabled:NO];
        [lblFileStatus setText:@"File not found, Please type correct filename"];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)removeAllFiles
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", directory, file] error:&error];
        if (!success || error) {
            // it failed.
        }
    }
}


- (void)updateStatusWithFrame:(NSString *)msg
{
    [lblFileStatus setText:msg];
}

@end
