//
//  SpeechAlertView.m
//  JooSoN
//
//  Created by 김학철 on 2020/09/22.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "SpeechAlertView.h"
#import "AppDelegate.h"
#import "CButton.h"
#import <Speech/Speech.h>
#import "RecordingButton.h"

#define TagAlertView 1110

typedef enum {
    SpeechStatusNotRuning,
    SpeechStatusRunning,
    SpeechStatusFailed
}SpeechStatus;

@interface SpeechAlertView () <SFSpeechRecognizerDelegate>
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet RecordingButton *btnMic;
@property (weak, nonatomic) IBOutlet UILabel *lbInfo;
@property (weak, nonatomic) IBOutlet CButton *btnReload;
@property (weak, nonatomic) IBOutlet UIButton *btnFullClose;


@property(nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property(nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property(nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property(nonatomic, strong) AVAudioEngine *audioEngine;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) void(^completion)(NSString *result);
@property (nonatomic, assign) BOOL isRunning;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSString *recodingTxt;
@end

@implementation SpeechAlertView
+ (void)showWithTitle:(NSString *)title
                completion:(void (^)(NSString *result))completion {
    SpeechAlertView *alert = [[SpeechAlertView alloc] initWithTitle:title completion:completion];
    [alert show];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (id)initWithTitle:(NSString *)title completion:(void(^)(NSString *result))competion {
    if (self = [self initWithFrame:[UIScreen mainScreen].bounds]) {
        
        self.title = title;
        self.completion = competion;
        [self loadXib];
        [self createSpeechReconizer];
    }
    return  self;
}
- (void)loadXib {
    self.bgView = [[NSBundle bundleForClass:[self class]] loadNibNamed:@"SpeechAlertView" owner:self options:nil].firstObject;
    _bgView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_bgView];
    
    [_bgView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0].active = YES;
    [_bgView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0].active = YES;
    [_bgView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0].active = YES;
    [_bgView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0].active = YES;
}

- (void)show {
    self.backgroundColor = [UIColor clearColor];
    
    UIWindow *window = [AppDelegate instance].window;
    
    if ([window viewWithTag:TagAlertView]) {
        [[window viewWithTag:TagAlertView] removeFromSuperview];
    }
    self.tag = TagAlertView;
    [window addSubview:self];
    _btnReload.hidden = YES;
    _lbInfo.text = @"아무 말이나 해 보세요";
    _lbTitle.text = _title;
    _containerView.layer.cornerRadius = 8.0;
    
    _bgView.backgroundColor = [UIColor clearColor];
    _containerView.alpha = 0.0;
    _containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.bgView.backgroundColor = RGBA(0, 0, 0, 0.2);
        self.containerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.containerView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.btnMic sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
    }];
}


- (void)createSpeechReconizer {
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"ko_KR"]];
    _speechRecognizer.delegate = self;
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        switch (status) {
                    case SFSpeechRecognizerAuthorizationStatusAuthorized:
                        NSLog(@"Authorized");
                        break;
                    case SFSpeechRecognizerAuthorizationStatusDenied:
                        NSLog(@"Denied");
                        break;
                    case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                        NSLog(@"Not Determined");
                        break;
                    case SFSpeechRecognizerAuthorizationStatusRestricted:
                        NSLog(@"Restricted");
                        break;
                    default:
                        break;
                }
    }];
}

- (void)startListening {
    // Initialize the AVAudioEngine
    self.audioEngine = [[AVAudioEngine alloc] init];

    // Make sure there's not a recognition task already running
    if (_recognitionTask) {
        [_recognitionTask cancel];
        self.recognitionTask = nil;
    }

    // Starts an AVAudio Session
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];

    // Starts a recognition process, in the block it logs the input or stops the audio
    // process if there's an error.
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    AVAudioInputNode *inputNode = _audioEngine.inputNode;
    _recognitionRequest.shouldReportPartialResults = YES;
    _recognitionTask = [_speechRecognizer recognitionTaskWithRequest:_recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        if (result) {
            // Whatever you say in the microphone after pressing the button should be being logged
            // in the console.
            NSLog(@"RESULT:%@",result.bestTranscription.formattedString);
            self.recodingTxt = result.bestTranscription.formattedString;
            isFinal = !result.isFinal;
            self.lbInfo.text = self.recodingTxt;
            
        }
        if (error) {
//            [inputNode removeTapOnBus:0];
            [self.audioEngine stop];
            self.recognitionRequest = nil;
            self.recognitionTask = nil;
        }
    }];

    // Sets the recording format
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];

    // Starts the audio engine, i.e. it starts listening.
    [_audioEngine prepare];
    [_audioEngine startAndReturnError:&error];
    NSLog(@"Say Something, I'm listening");
    _lbInfo.text = @"아무 말이나 해 보세요";
}

- (void)stopRecodingTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
- (IBAction)onclickedButtonActions:(UIButton *)sender {
    if (sender == _btnMic) {
        _isRunning = !_isRunning;
        self.recodingTxt = @"";
        if (_isRunning) {
            [self startRecoding];
        }
        else {
            [self stopRecoding];
        }
    }
    else if (sender == _btnReload) {
        [self startRecoding];
    }
    else if (sender == _btnFullClose) {
        if (self.completion) {
            self.completion(nil);
        }
        [self dismiss];
    }
}
- (void)startRecoding {
    [self startListening];
    
    [_btnMic animation:YES];
    self.btnReload.hidden = YES;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self stopRecoding];
        if (self.recodingTxt.length == 0) {
            self.lbInfo.text = @"인식하지 못했습니다.\n다시 말씀해 주세요.";
            self.btnReload.hidden = NO;
        }
        else {
            self.lbInfo.text = self.recodingTxt;
            if (self.completion) {
                self.completion(self.recodingTxt);
            }
            [self dismiss];
        }
    }];
}
- (void)stopRecoding {
    [_audioEngine stop];
    [_btnMic animation:NO];
}
- (void)dismiss {
    self.completion = nil;
    [UIView animateWithDuration:0.1
                     animations:^{
        self.transform = CGAffineTransformMakeScale(0, 0);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

//MARK:: SFSpeechRecognizerDelegate
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    
}

@end
