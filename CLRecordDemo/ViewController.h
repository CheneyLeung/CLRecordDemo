//
//  ViewController.h
//  CLRecordDemo
//
//  Created by Cheney Leung on 15/8/26.
//  Copyright (c) 2015年 PingAn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<AVAudioRecorderDelegate,AVAudioPlayerDelegate>
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *avPlayer;
@property (strong, nonatomic) IBOutlet UIButton *playBtn;

@end

