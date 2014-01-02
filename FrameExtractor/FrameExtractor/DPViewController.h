//
//  DPViewController.h
//  FrameExtractor
//
//  Created by Dipen on 02/01/14.
//  Copyright (c) 2014 Dipen Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UILabel *lblFileStatus, *lblVideoLength, *lblFrames;
    IBOutlet UIButton *btnProcess;
    IBOutlet UITextField *tfFileName;
}

@property (nonatomic, retain) AVAssetImageGenerator *generator;
@property (nonatomic, retain) AVVideoComposition *composition;


@property (nonatomic) CMTime requestedTimeToleranceBefore NS_AVAILABLE(10_7, 5_0);
@property (nonatomic) CMTime requestedTimeToleranceAfter NS_AVAILABLE(10_7, 5_0);

- (void)extractFrames;

@end
