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
#import "TMobilePass-Swift.h"
#import <CoreBluetooth/CoreBluetooth.h>

@import CoreNFC;
@import CoreBluetooth;
@import AudioToolbox;

@interface TMobilePass()

@end

@interface NfcViewController () <NFCNDEFReaderSessionDelegate , CBCentralManagerDelegate, NORBluetoothManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UIButton *btnScan;

@property (nonatomic, strong) NFCNDEFReaderSession *session;

@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lng;
@property (nonatomic, strong) NSString *address;

@property (nonatomic, strong)   CBCentralManager *bluetoothManager;
@property (nonatomic, strong)   NORBluetoothManager *norblueManager;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData *data;
@property (strong, nonatomic) CBUUID *filterUUID;
@property (nonatomic, strong) TMobilePass *mobilepass;

@property (nonatomic, strong ) NSString *TokenValue;
@property (nonatomic, strong ) NSString *trnValue;
@property (nonatomic, assign) int iBleFound;
@property (nonatomic, assign) BOOL bNefDetected;
@property (nonatomic, strong) NSTimer* timerAction;
@property (nonatomic, assign) BOOL isWriteSuccess;
@end

@implementation NfcViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _btnScan.layer.cornerRadius = 16.0;
    _btnScan.layer.borderWidth = 1.0f;
    _btnScan.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _lbAddress.text = @"";
    _lbName.text = @"";

    _lbName.text = _passPlaceInfo.name;
    _lbAddress.text = _passPlaceInfo.jibun_address;

    self.lat = _passPlaceInfo.x;
    self.lng = _passPlaceInfo.y;
    self.address = _passPlaceInfo.jibun_address;

    
    self.bNefDetected = false;
    enum MOBILEPASS_OPERATION_MODE mode;
    mode = MOBILEPASS_OPERATION_MODENFC_BLE_PLAIN_TEXT_MODE ;
    
    self.mobilepass = [[TMobilePass alloc]initWithOperationmode:(mode)];
    
    //@"{12345678901234567890}";
    self.TokenValue = [self createTokenJsonString];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_TokenValue.length > 0) {
        [self beginSession];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (NSString *)createTokenJsonString {
    if (_address.length == 0) {
        _address = _passPlaceInfo.name;
    }
    if (_address.length > 0 && _lat != 0 && _lng != 0) {

        //            {“type”:1,“dest”:{“name”: “신세계백화점 천안신부동점”,“latitude”: 36.8195602,“longitude”: 127.1543738}}
        NSLog(@"==== address: %@", _address);
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:7];
        [formatter setRoundingMode: NSNumberFormatterRoundUp];
        NSString *lat = [formatter stringFromNumber:[NSNumber numberWithDouble:_passPlaceInfo.x]];
        NSString *lng = [formatter stringFromNumber:[NSNumber numberWithDouble:_passPlaceInfo.y]];
        
        NSString *name = _passPlaceInfo.name;
        if (name == nil) {
            name = @"";
        }
        //한글 넣으면 nfc 라이브러리에서 죽는다. 안넣어도 위경도 좌표만 있으면 인식함
        //참고 type을 앞으로 땡겼더니 인식 못함
        //별찌랄 끝에 dest 앞으로 땡기고 type을 뒤로 옮겼더니 잘 인식함 이것 땜에 고생 깨함 미침
        NSString *mmm = [NSString stringWithFormat:@"{\"dest\":{\"name\":\"%s\",\"latitude\": %@,\"longitude\": %@},\"type\":1}\r", "jooson", lat, lng];

        NSLog(@"====nfc write : %@", mmm);
        
        return  mmm;
    }
    return nil;
}
- (IBAction)onclickedButtonActions:(UIButton *)sender {
    if (sender == _btnBack) {
        [self stopForPeripherals];
        [self.navigationController popViewControllerAnimated:NO];
    }
    else if (sender == _btnScan) {
        [self stopForPeripherals];
        [self beginSession];
    }
}
- (NSString *)jsonStringWithDictionary:(NSDictionary *)dic {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingFragmentsAllowed
                                                         error:&error];
    
    if (error != nil) {
        NSLog(@"%s: error: %@", __func__, error.localizedDescription);
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)dealloc {
    [_session invalidateSession];
}

#pragma mark - NFCNDEFReaderSessionDelegate

- (void)readerSessionDidBecomeActive:(nonnull NFCNDEFReaderSession *)session
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.logView.text = [NSString stringWithFormat:@"[%@] readerSessionDidBecomeActive:\n%@",
//                         [NSDate date],
//                         self.logView.text];
//    });
}

- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didInvalidateWithError:(nonnull NSError *)error
{
    if (error.code == NFCReaderSessionInvalidationErrorUserCanceled) {
        // User cancellation.

        [ self stopForPeripherals];
        return;
    }
    NSLog(@"didInvalidateWithError Error: %@", [error debugDescription]);
    
    
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.bNefDetected = true;
    });
}

- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didDetectNDEFs:(nonnull NSArray<NFCNDEFMessage *> *)messages
{
    
    [_session invalidateSession];
    
    NSString *rtnstring = [_mobilepass ndefmessageparseWithDidDetectNDEFs:(messages)];

    self.bNefDetected = true;
}

#pragma mark - Methods

- (void)beginSession
{
    NSLog(@"Call beginSession");
    // 2. MOBILE PASS가 NDEF DETECTION MODE,  NFC EVENT MODE 인 경우 CLEAR FLAG
    [_mobilepass NdefCompletedWithNdefcompleteflag:(false)];
    
    NSLog(@"Call NFC");
    // 3. NFC Reader 동작을 시작한다.
    _session
    = [[NFCNDEFReaderSession alloc] initWithDelegate:self
                                               queue:dispatch_queue_create(NULL,
                                                                           DISPATCH_QUEUE_CONCURRENT)
                            invalidateAfterFirstRead:NO];
    NSLog(@"Call Session");
    
    _session.alertMessage = @"iPhone 상단을\n NFC 안테나 위에 터치 하십시오.";
    
    [_session beginSession];
    
    
    NSLog(@"Clear _trnValue");
    _trnValue = @"";
    _iBleFound = 0;
    
    NSLog(@"Call dispatch");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"CBUUID : %@", NORServiceIdentifiers.uartServiceUUIDString);
        self.filterUUID = [CBUUID UUIDWithString:NORServiceIdentifiers.uartServiceUUIDString];
        NSLog(@"_filterUUID : %@", self.filterUUID);
        
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        NSLog(@"_bluetoothManager : %@", self.bluetoothManager);
        
        self.data = [[NSMutableData alloc] init];
        NSLog(@"_data : %@", self.data);
        
    });
    
    NSLog(@"Call Timer");
    _timerAction = [NSTimer scheduledTimerWithTimeInterval:20.0f
      target:self
    selector:@selector(timerActionFire)
    userInfo:nil
     repeats:NO];
     
}

- (void)stopForPeripherals
{
    [_bluetoothManager stopScan];
    
    NSLog(@"stopForPeripherals");
    
    /*
    self.timerEnding?.invalidate()
    self.timerEnding = nil
     */
    if ( _timerAction != NULL ) {
        //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
        [ _timerAction invalidate ];
        _timerAction = NULL ;
        NSLog(@"timerAction Destroy");
    }
}

- (void) timerActionFire
{
    NSLog(@"timerActionFire");
    _timerAction = NULL;
    [ self stopForPeripherals];
    [_session invalidateSession];
    self.bNefDetected = false;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    //NSDictionary *serviceData = advertisementData[@"kCBAdvDataServiceData"];

    
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
     

    
    if( self.bNefDetected == false )
        return;
    
    if( self.mobilepass.getNfcUseMode == MOBILEPASS_NFC_USE_MODENFC_EVENT_MODE)
    {
        NSLog(@"NFC EVENT");

        enum BLE_MODEL smode;
        smode = BLE_MODELWT51822S4AT ;
        
        Boolean brtn = [ _mobilepass isMobilePassAvailableWithRssi:((NSNumber *)RSSI) blemodel:smode];
        
        if( brtn )
        {
            _iBleFound += 1;
            NSLog(@"_iBleFound : %d", _iBleFound);
            
            if( _iBleFound > 0 )
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                });
                

                NSString *name = peripheral.name;
                NSString *bledevicename = [_mobilepass sBleTPrefixName];
                
                if ([name rangeOfString:bledevicename].location == NSNotFound) {
                  NSLog(@"name does not contain bledevicename");
                } else {
                  NSLog(@"name contains bledevicename : %@" , name);
                    _trnValue = [name substringFromIndex:3];

                    NSLog(@"_trnValue : %@", _trnValue);
                    //if (_discoveredPeripheral != peripheral) {
                        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
                        _discoveredPeripheral = peripheral;
                         

                        [self stopForPeripherals];
                        
                        _norblueManager = [[NORBluetoothManager alloc] initWithManager:(central) withMobilepass:_mobilepass ];
                        _norblueManager.delegate = self;
                        [ _norblueManager connectPeripheralWithPeripheral:peripheral];
                    //}
                }
            }
        }
        else
        {
            
        }
    }
}


- (void)centralManager:(CBCentralManager *)central didSuccessToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Success to connect");
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect");
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // You should test all scenarios
    if (central.state != CBManagerStatePoweredOn) {
        return;
    }
     
    if (central.state == CBManagerStatePoweredOn) {
        NSLog(@"centralManagerDidUpdateState");
        NSLog(@"0. filterUUID : %@", @[self.filterUUID]);
        
        // 아래 Object-C 로 변환
        
        NSArray *connectedPeripheral = [self getConnectedPeripherals];
        NSLog(@"0. connectedPeripheral : %@", connectedPeripheral);
        NSLog(@"0. trnValue : %@", _trnValue);
        NSLog(@"0. tocken : %@", _TokenValue);
        NSLog(@"0. NORblueManager : %@", _norblueManager);
        
        
        if( [connectedPeripheral count] > 0 ) {
            if( [_trnValue length] > 4 ) {
                [_mobilepass MobilePassAuthenticateProcessWithNorbluetoothmanager:_norblueManager trnvalue:_trnValue tocken:_TokenValue];
                self.isWriteSuccess = YES;
            } else {
                NSLog(@"0. unExpected trnValue = %@", _trnValue);
                self.isWriteSuccess = NO;
            }
        }
        else
        {

            // Scan for devices
            if(self.filterUUID == nil) {
                NSLog(@"_filterUUID == nil ");
                [_bluetoothManager scanForPeripheralsWithServices:nil options:nil];
                
            } else {
                NSLog(@"_filterUUID == set ");
                [_bluetoothManager scanForPeripheralsWithServices:@[self.filterUUID] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
            }
            
            NSLog(@"Scanning started");
        }

    }
}

// Object - C Code 로 변환
- (NSArray *) getConnectedPeripherals
{
    /*
    guard let bluetoothManager = bluetoothManager else {
        return []
    }
    if (bluetoothManager == nil ) {
        return [];
    }
     */

    NSLog(@"getConnectedPeripherals");
    
    if (_bluetoothManager == nil ) {
        NSLog(@"bluetoothManager Null");
        return nil;
    }
    /*
    var retreivedPeripherals : [CBPeripheral]
    retreivedPeripherals     = bluetoothManager.retrieveConnectedPeripherals(withServices:[filterUUID!])
    return retreivedPeripherals
     */
    NSArray* retrievedPeriPherals = [_bluetoothManager retrieveConnectedPeripheralsWithServices:@[self.filterUUID]];
    NSLog(@"retrievedPeriPherals : %@", retrievedPeriPherals);
    NSLog(@" retrievedPeriPherals Count : %lu", [retrievedPeriPherals count]);
    
    return retrievedPeriPherals;
}

- (void)didBleRequestPhoneNo {
    
    NSLog(@"didBleRequestPhoneNo");
    
    // Object - C 로 변환

    /* Setup Command 로
     * 저장된 값을 사용할 때 아래 사용 S
     * 직접 프로그램을 개발하여 회원의 정보를 온라인에서 운영하는 경우는
     * 아래 부분을 사용하지 않습니다.
     */
    [_mobilepass MobilePassSendPhoneNoWithNorbluetoothmanager:_norblueManager];
}


- (void)didBleSetTokenProcessWithTocken:(NSString * _Nullable)Token json:(NSString * _Nullable)jsonString {
    
    NSLog(@"didBleSetTokenProcessWithTocken");
    
}


- (void)didConnectPeripheralWithDeviceName:(NSString * _Nullable)aName {
    
    NSLog(@"didConnectPeripheralWithDeviceName: %@" , aName);
}

- (void)didConnectPeripheral {
    NSLog(@"didConnectPeripheral");
}


- (void)didDisconnectPeripheral {
    NSLog(@"didDisconnectPeripheral");
  
    if (_isWriteSuccess) {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setObject:_passPlaceInfo.name forKey:@"name"];
        [param setObject:_address forKey:@"address"];
        [param setObject:[NSDate date] forKey:@"createDate"];
        [param setObject:[NSNumber numberWithDouble:_lat] forKey:@"geoLat"];
        [param setObject:[NSNumber numberWithDouble:_lng] forKey:@"geoLng"];
        [param setObject:[NSNumber numberWithInt:3] forKey:@"historyType"];
        [[DBManager instance] insertHistory:param success:^{
            [self.navigationController popViewControllerAnimated:NO];
        } fail:^(NSError *error) {

        }];
    }
}

- (void)peripheralNotSupported {
    NSLog(@"peripheralNotSupported");
}

- (void)peripheralReady {
    NSLog(@"peripheralReady");
    
    NSLog(@"1. filterUUID : %@", @[self.filterUUID]);
    NSArray *connectedPeripheral = [self getConnectedPeripherals];
    NSLog(@"1. connectedPeripheral : %@", connectedPeripheral);
    NSLog(@"1. trnValue : %@", _trnValue);

    if( [connectedPeripheral count] > 0 ) {
        if( [_trnValue length] > 4 ) {
            [_mobilepass MobilePassAuthenticateProcessWithNorbluetoothmanager:_norblueManager trnvalue:_trnValue tocken:_TokenValue];
            _isWriteSuccess = YES;
        } else {
            NSLog(@"1. unExpected trnValue = %@", _trnValue);
            _isWriteSuccess = NO;
        }
    }
}

@end
