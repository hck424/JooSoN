//
//  NfcViewController.m
//  JooSoN
//
//  Created by 김학철 on 2020/01/10.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "NfcViewController.h"
#import <CoreNFC/CoreNFC.h>
#import <os/log.h>
#import <VYNFCKit/VYNFCKit.h>
#import "DBManager.h"

API_AVAILABLE(ios(13.0))
@interface NfcViewController () <NFCNDEFReaderSessionDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbLoc;
@property (weak, nonatomic) IBOutlet UIButton *btnRead;
@property (weak, nonatomic) IBOutlet UIButton *btnWrite;
@property (weak, nonatomic) IBOutlet UILabel *lbReadMsg;
@property (nonatomic, assign) BOOL isWriteMode;
@property (nonatomic, strong) NFCNDEFReaderSession *readSession;
@property (nonatomic, strong) NFCNDEFMessage *writeMsg;

@property (nonatomic, assign) CGFloat lat;
@property (nonatomic, assign) CGFloat lng;
@property (nonatomic, strong) NSString *address;
@end

@implementation NfcViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _btnWrite.layer.cornerRadius = _btnWrite.frame.size.height/2;
    _btnWrite.layer.borderWidth = 1.0f;
    _btnWrite.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _btnRead.layer.cornerRadius = _btnRead.frame.size.height/2;
    _btnRead.layer.borderWidth = 1.0f;
    _btnRead.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _lbAddress.text = @"";
    _lbLoc.text = @"";
    _lbReadMsg.text = @"";
    
    

    if (_passJooso != nil && _passJooso.address.length > 0 && _passJooso.geoLat != 0 && _passJooso.geoLng != 0) {
        _lbAddress.text = _passJooso.address;
        _lbLoc.text = [NSString stringWithFormat:@"lat : %lf, lng : %lf", _passJooso.geoLat, _passJooso.geoLng];
        self.lat = _passJooso.geoLat;
        self.lng = _passJooso.geoLng;
        self.address = _passJooso.address;
    }
    else if (_passPlaceInfo.jibun_address.length > 0 && _passPlaceInfo.x != 0 && _passPlaceInfo.y != 0) {
        _lbAddress.text = _passPlaceInfo.jibun_address;
        _lbLoc.text = [NSString stringWithFormat:@"lat : %lf, lng : %lf", _passPlaceInfo.y, _passPlaceInfo.x];
        self.lat = _passPlaceInfo.y;
        self.lng = _passPlaceInfo.x;
        self.address = _passPlaceInfo.jibun_address;
    }
    
    _isWriteMode = YES;
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.btnWrite sendActionsForControlEvents:UIControlEventTouchUpInside];
    });
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (IBAction)onClickedButtonAction:(id)sender {
    if (sender == _btnBack) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    else if (sender == _btnRead
             || sender == _btnWrite) {
        if (sender == _btnRead) {
            _isWriteMode = NO;
        }
        else {
            _isWriteMode = YES;
        }
        
        if ([NFCNDEFReaderSession readingAvailable]) {
            self.readSession = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT) invalidateAfterFirstRead:NO];
            
            _readSession.alertMessage = @"iPhone을 NFC 태그 가까이에 두십시오.";
            [_readSession beginSession];
            
        } else {
            [self showAlertNotAvailableNfc];
        }
    }
}
- (NFCNDEFPayload *)createTextPlayload {
    NSString *msg = [NSString stringWithFormat:@"%@|lant=(%lf, %lf)", _address, _lat, _lng];
    NFCNDEFPayload *playload = [NFCNDEFPayload wellKnownTypeTextPayloadWithString:msg locale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    return playload;
}
- (void)readUpdateUi:(NFCNDEFMessage *)message {
    NSMutableString *result = [NSMutableString string];
    _lbReadMsg.text = @"";
    for (NFCNDEFPayload *payload in message.records) {
        id parsedPayload = [VYNFCNDEFPayloadParser parse:payload];
        if (parsedPayload) {
            NSString *text = @"";
            NSString *urlString = nil;
            if ([parsedPayload isKindOfClass:[VYNFCNDEFTextPayload class]]) {
//                text = @"[Text] ";
                text = [NSString stringWithFormat:@"%@", ((VYNFCNDEFTextPayload *)parsedPayload).text];
            } else if ([parsedPayload isKindOfClass:[VYNFCNDEFURIPayload class]]) {
//                text = @"[URI] ";
                text = [NSString stringWithFormat:@"%@", ((VYNFCNDEFURIPayload *)parsedPayload).URIString];
                urlString = ((VYNFCNDEFURIPayload *)parsedPayload).URIString;
            } else if ([parsedPayload isKindOfClass:[VYNFCNDEFTextXVCardPayload class]]) {
//                text = @"[TextXVCard] ";
                text = [NSString stringWithFormat:@"%@", ((VYNFCNDEFTextXVCardPayload *)parsedPayload).text];
            } else if ([parsedPayload isKindOfClass:[VYNFCNDEFSmartPosterPayload class]]) {
//                text = @"[SmartPoster] ";
                VYNFCNDEFSmartPosterPayload *sp = parsedPayload;
                for (VYNFCNDEFTextPayload *textPayload in sp.payloadTexts) {
                    text = [NSString stringWithFormat:@"%@\n", textPayload.text];
                }
                text = [NSString stringWithFormat:@"%@%@", text, sp.payloadURI.URIString];
                urlString = sp.payloadURI.URIString;
            } else if ([parsedPayload isKindOfClass:[VYNFCNDEFWifiSimpleConfigPayload class]]) {
//                text = @"[WifiSimpleConfig] ";
                VYNFCNDEFWifiSimpleConfigPayload *wifi = parsedPayload;
                for (VYNFCNDEFWifiSimpleConfigCredential *credential in wifi.credentials) {
                    text = [NSString stringWithFormat:@"SSID: %@\nPassword: %@\nMac Address: %@\nAuth Type: %@\nEncrypt Type: %@", credential.ssid, credential.networkKey, credential.macAddress,
                            [VYNFCNDEFWifiSimpleConfigCredential authTypeString:credential.authType],
                            [VYNFCNDEFWifiSimpleConfigCredential encryptTypeString:credential.encryptType]];
                }
                if (wifi.version2) {
                    text = [NSString stringWithFormat:@"%@\nVersion2: %@",
                            text, wifi.version2.version];
                }
            } else {
                text = @"Parsed but unhandled payload type";
            }
            NSLog(@"=== %@", text);
            if (text != nil) {
                [result appendFormat:@"%@\n", text];
            }
        }
    }
    
    _lbReadMsg.text = result;
        
}
- (void)showAlertNotAvailableNfc {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"스캔이 지원되지 않습니다" message:@"이 장치는 태그 스캔을 지원하지 않습니다." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:NO completion:nil];
    });
}

#pragma mark - NFCNDEFReaderSessionDelegate
- (void)readerSession:(NFCNDEFReaderSession *)session didInvalidateWithError:(NSError *)error API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(watchos, macos, tvos) {
    if (error != nil
        && error.code == NFCReaderSessionInvalidationErrorFirstNDEFTagRead
        && error.code == NFCReaderSessionInvalidationErrorUserCanceled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"세션이 무효가 되었습니다." message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:NO completion:nil];
        });
    }
    self.readSession = nil;
}

- (void)readerSession:(NFCNDEFReaderSession *)session didDetectNDEFs:(NSArray<NFCNDEFMessage *> *)messages API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(watchos, macos, tvos) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [messages firstObject];
        [self readUpdateUi:messages.firstObject];
    });
}
- (void)readerSession:(NFCNDEFReaderSession *)session didDetectTags:(NSArray<__kindof id<NFCNDEFTag>> *)tags API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(watchos, macos, tvos) {
    
    if (tags.count > 1) {
        session.alertMessage = @"태그가 둘 이상 감지되었습니다. 모든 태그를 제거하고 다시 시도하십시오.";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [session restartPolling];
            return ;
        });
    }
    
    id <NFCNDEFTag>tag = tags.firstObject;
    [session connectToTag:tag completionHandler:^(NSError * _Nullable error) {
        if (nil != error) {
            session.alertMessage = @"태그에 연결할 수 없습니다.";
            [session invalidateSession];
            return;
        }
        
        [tag queryNDEFStatusWithCompletionHandler:^(NFCNDEFStatus status, NSUInteger capacity, NSError * _Nullable error) {
           
            if (status == NFCNDEFStatusNotSupported) {
                session.alertMessage = @"태그 NDEF 호환되지 않습니다.";
                [session invalidateSession];
            }
            else if (error != nil) {
                session.alertMessage = @"태그의 NDEF 상태를 쿼리 할 수 없습니다.";
                [session invalidateSession];
                return ;
            }
            
            if (self.isWriteMode == NO) {
                [tag readNDEFWithCompletionHandler:^(NFCNDEFMessage * _Nullable message, NSError * _Nullable error) {
                    NSString *statusMessage = nil;
                    if (error != nil && message == nil) {
                        statusMessage = @"태그에서 NDEF를 읽지 못했습니다";
                    }
                    else {
                        
                        statusMessage = @"NDEF 메시지 1 개 발견";
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self readUpdateUi:message];
                        });
                    }
                    session.alertMessage = statusMessage;
                    [session invalidateSession];
                }];
            }
            else {
                
                [tag writeNDEF:self.writeMsg completionHandler:^(NSError * _Nullable error) {
                    if (error != nil) {
                        session.alertMessage = @"업데이트 태그에 실패했습니다. 다시 시도하십시오.";
                    } else {
                        session.alertMessage = @"NDEF 메시지 쓰기 성공!";
                        [session invalidateSession];
                        NSMutableDictionary *param = [NSMutableDictionary dictionary];
                        
                        if (self.passJooso != nil
                            && self.passJooso.address.length > 0
                            && self.passJooso.geoLat != 0
                            && self.passJooso.geoLng != 0) {
                            [param setObject:self.passJooso.name forKey:@"name"];
                            [param setObject:[self.passJooso getMainPhone]  forKey:@"phoneNumber"];
                            [param setObject:[NSDate date] forKey:@"createDate"];
                            [param setObject:[NSNumber numberWithFloat:self.passJooso.geoLat] forKey:@"geoLat"];
                            [param setObject:[NSNumber numberWithFloat:self.passJooso.geoLng] forKey:@"geoLng"];
                            if (self.passJooso.address != nil) {
                                [param setObject:self.passJooso.address forKeyedSubscript:@"address"];
                            }
                        }
                        else if (self.passPlaceInfo.jibun_address.length > 0
                                 && self.passPlaceInfo.x != 0
                                 && self.passPlaceInfo.y != 0) {
                            
                            [param setObject:[NSNumber numberWithFloat:self.passPlaceInfo.y] forKey:@"geoLat"];
                            [param setObject:[NSNumber numberWithFloat:self.passPlaceInfo.x] forKey:@"geoLng"];
                            if (self.passPlaceInfo.jibun_address != nil) {
                                [param setObject:self.passPlaceInfo.jibun_address forKeyedSubscript:@"address"];
                            }
                            else if (self.passPlaceInfo.road_address != nil) {
                                [param setObject:self.passPlaceInfo.road_address forKeyedSubscript:@"address"];
                            }
                        }
                        [param setObject:[NSNumber numberWithInt:1] forKey:@"historyType"];
                        
                        [[DBManager instance] insertHistory:param success:nil fail:nil];
                    }
                }];
            }
        }];
    }];
}

- (void)readerSessionDidBecomeActive:(NFCNDEFReaderSession *)session API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(watchos, macos, tvos) {
    if (_isWriteMode) {
        NFCNDEFPayload *textPayload = [self createTextPlayload];
        self.writeMsg = [[NFCNDEFMessage alloc] initWithNDEFRecords:@[textPayload]];
    }
}


@end
