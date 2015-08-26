//
//  ViewController.m
//  CLRecordDemo
//
//  Created by Cheney Leung on 15/8/26.
//  Copyright (c) 2015年 PingAn. All rights reserved.
//

#import "ViewController.h"
#import "VoiceConverter.h"

@interface ViewController ()
@property (strong, nonatomic) NSString *wavFilePath;
@property (strong, nonatomic) NSString *amrFilePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
    [audioSession setActive:YES error: nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error: nil];
}

- (NSString *)wavFilePath {
    if (!_wavFilePath) {
        _wavFilePath = [self recordPath];
        _wavFilePath = [_wavFilePath stringByAppendingPathComponent:@"chat.wav"];
        NSLog(@"Chat wav record path: %@",_wavFilePath);
    }
    return _wavFilePath;
}

- (NSString *)amrFilePath {
    if (!_amrFilePath) {
        _amrFilePath = [self recordPath];
        _amrFilePath = [_amrFilePath stringByAppendingPathComponent:@"chat.amr"];
        NSLog(@"Chat amr record path: %@",_amrFilePath);
    }
    return _amrFilePath;
}

- (NSString *)recordPath {
    NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *_recordPath = [documentPath stringByAppendingPathComponent:@"record"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_recordPath]) {
        if (![fileManager createDirectoryAtPath:_recordPath withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSLog(@"Create Recorder directory fail.");
            return documentPath;
        }
    }
    return _recordPath;
}

- (IBAction)startRocord:(UIButton *)sender {
    NSLog(@"Start record");
    [self playBtnOff:@"recording..."];
    //配置录音参数
    NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc]init];
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    
    NSURL *recordUrl = [NSURL URLWithString:self.wavFilePath];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:recordUrl settings:recordSetting error:nil];
    self.recorder.delegate = self;
    [self.recorder prepareToRecord];
    [self.recorder record];
}

- (IBAction)endRecord:(UIButton *)sender {
    NSLog(@"End record");
    [self playBtnOn:@"click to play"];
    [self.recorder stop];
}

- (IBAction)playRecord:(UIButton *)sender {
    NSURL *recordUrl = [NSURL URLWithString:self.wavFilePath];
    self.avPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:recordUrl error:nil];
    self.avPlayer.delegate = self;
    NSLog(@"Record duration: %f, volume: %f",self.avPlayer.duration,self.avPlayer.volume);
    [self.avPlayer prepareToPlay];
    [self.avPlayer play];
    [self playBtnOff:@"playing..."];
}

#pragma mark - Private Method

- (void)playBtnOn:(NSString *)tips {
    [self.playBtn setTitle:tips forState:UIControlStateNormal];
    self.playBtn.alpha = 1.0;
    self.playBtn.userInteractionEnabled = YES;
}

- (void)playBtnOff:(NSString *)tips {
    [self.playBtn setTitle:tips forState:UIControlStateNormal];
    self.playBtn.alpha = 0.5;
    self.playBtn.userInteractionEnabled = NO;
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
        NSLog(@"Chat record success");
        int changeAmr = [VoiceConverter ConvertWavToAmr:self.wavFilePath amrSavePath:self.amrFilePath];
        if (changeAmr)
            NSLog(@"Wav 转 Amr 成功");
        else
            NSLog(@"Wav 转 Amr 失败");
    }
    else
        NSLog(@"Chat record fail");
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"Chat record error");
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"Finish playing");
    [self playBtnOn:@"click to play"];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Audio Player Decode Error");
}

@end
