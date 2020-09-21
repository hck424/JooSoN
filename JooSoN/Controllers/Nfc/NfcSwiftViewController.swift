//
//  ViewController.swift
//  testingNFC
//
//  Created by Kevin Yang on 6/6/19.
//  Copyright © 2019 TTCNC All rights reserved.
//
//  iPhone XR  aspect 1:1
// iphone 8 이하 부터 aspect 406:367
import UIKit
import CoreNFC
import CoreBluetooth
import AudioToolbox
import TMobilePass


class NfcSwiftViewController: UIViewController, NFCNDEFReaderSessionDelegate ,CBCentralManagerDelegate , UITextFieldDelegate ,NORBluetoothManagerDelegate{
    

    @IBOutlet weak var keyInput: UITextField!
    @IBOutlet weak var switchUseKey:UISwitch!
    @IBOutlet weak var userName:UILabel!
    @IBOutlet weak var userId:UILabel!
    @IBOutlet weak var companyName:UILabel!
    @IBOutlet weak var photoImage:UIImageView!
    
    // NFC Service
    var session: NFCNDEFReaderSession?
    // BLE Service
    var bluetoothManager : CBCentralManager?
    // MobilePass Service
    var mobilepass:TMobilePass?
    // Process Timer
    
    var timerAction            : Timer?
    
    // Tocken Value
    var TokenValue=""
    // TRN Value
    var trnValue = ""
    var bNdefDetected = false
    var iBleFound = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. MOBILE PASS OPERATION MODE 선택
        // default MODE 는 NFC_BLE_CRYPTO_MODE( 암호화 통신 - 3Phase-Authentication ) 이다.
        mobilepass = TMobilePass( operationmode: TMobilePass.MOBILEPASS_OPERATION_MODE.NFC_BLE_PLAIN_TEXT_MODE)
        
        // 사용자 화면 연동
        keyInput.delegate = self //set delegate to textfile
        // For Test Key Value Initialize

        // 아이폰에 저장된 Token을 사용할 경우
        TokenValue = (mobilepass?.getTokenPreference())!
        
       // TokenValue = "BDKANG0825003001"
        
        TokenValue = "1234567890123456"
        print("TokenValue:\(TokenValue)")
        
        /* Setup Command 로
         * 저장된 값을 사용할 때 아래 사용 S
         * 직접 프로그램을 개발하여 회원의 정보를 온라인에서 운영하는 경우는
         * 아래 부분을 사용하지 않습니다.
         */
        print("CompanyName:\(String(describing: mobilepass?.getKeyValuePreference(keyname : "cn")))")
        print("UserName:\(String(describing: mobilepass?.getKeyValuePreference(keyname : "yn")))")
        print("UserId:\(String(describing: mobilepass?.getKeyValuePreference(keyname : "ci")))")
        
        userName.text = (mobilepass?.getKeyValuePreference(keyname : "yn"))!
        userId.text = (mobilepass?.getKeyValuePreference(keyname : "ci"))!
        companyName.text = ( mobilepass?.getKeyValuePreference(keyname : "cn"))!
        
        /* Setup Command 로
         * 저장된 값을 사용할 때 아래 사용 E
         */

    }
    @IBAction func ibSwitchClicked(sender: AnyObject) {
            
        
        /* Setup Command 로
         * 저장된 값을 사용할 때 아래 사용 S
         * 직접 프로그램을 개발하여 회원의 정보를 온라인에서 운영하는 경우는
         * 아래 부분을 사용하지 않습니다.
         */
        print("cn:\(String(describing: mobilepass?.getKeyValuePreference(keyname : "cn")))")
        print("yn:\(String(describing: mobilepass?.getKeyValuePreference(keyname : "yn")))")
        print("yn:\(String(describing: mobilepass?.getKeyValuePreference(keyname : "ci")))")
        
        
        /* Setup Command 로
         * 저장된 값을 사용할 때 아래 사용 E
         */
        TokenValue = (mobilepass?.getTokenPreference())!
        
        
        //TokenValue = "BDKANG0825003001"
        TokenValue = "1234567890123456"
        print("TokenValue:\(TokenValue)")
    }
    @IBAction func keyChangedEvent(_ sender: Any) {
        TokenValue = keyInput.text!
        return
    }
    // Called when the line feed button is pressed
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    @IBAction func scanStart(_ sender: Any) {
        didDisconnectPeripheral()
        runMobilePass()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    //FIXME:: start
    func runMobilePass() {
        
        // 2. MOBILE PASS가 NDEF DETECTION MODE  , NFC EVENT MODE 인 경우 , Clear Flag
        mobilepass?.NdefCompleted(ndefcompleteflag : false)
        
        // 3. NFC Reader 동작을 시작한다.
        //session = mobilepass?.NfcNdefSessionCreate(delegate: self)
        
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "iPhone상단을\n NFC 안테나 위에 터치하십시오." // 화면에 표시되는 메시지를 수정할 수 있습니다.
        session?.begin()
        trnValue = ""
        iBleFound = 0
        
        DispatchQueue.main.async {
            
            self.bNdefDetected = false
            self.iBleFound = 0
            
            self.filterUUID = CBUUID.init(string: NORServiceIdentifiers.uartServiceUUIDString)
            let centralQueue = DispatchQueue(label: "kr.co.ttcnc.smartnfc", attributes: [])
            self.bluetoothManager = CBCentralManager(delegate: self, queue: centralQueue)
            
            print(NSString(format:"bluetoothManager Start"))
             
            self.mobilepass?.setNfcUseMode(operationmode: TMobilePass.MOBILEPASS_NFC_USE_MODE.NFC_EVENT_MODE)

            //self.session = self.mobilepass?.NfcNdefRevoke(delegate: self)
            
            if let timer = self.timerAction {
                //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
                if !timer.isValid {
                    /** 1초마다 timerCallback함수를 호출하는 타이머 */
                    self.timerAction = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.timerActionFire), userInfo: nil, repeats: false)
                }
            }else{
                //timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다
                /** 1초마다 timerCallback함수를 호출하는 타이머 */
                self.timerAction = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.timerActionFire), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func timerActionFire() {
        
        print("timerActionFire")
        self.timerAction = nil
        stopForPeripherals()
        self.session?.invalidate()
        self.bNdefDetected = false
    }
    func readerSessionDidBecomeActive (_ session: NFCNDEFReaderSession) {
        print("readerSessionDidBecomeActive")
    }
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        
        print("didInvalidateWithError")
        
        if let readerError = error as? NFCReaderError
        {
            if( readerError.code == .readerSessionInvalidationErrorUserCanceled )
            {
                return
            }
        }
        
        print("NfcNdefRevoke")
        self.bNdefDetected = true
        DispatchQueue.main.async {
            self.timerEnding = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerFire), userInfo: nil, repeats: false)
        }
    }
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
        session.invalidate()
        self.session = nil
        
        // 6. NDEF Complete Flag 초기화
        self.mobilepass?.NdefCompleted(ndefcompleteflag : true)
        
        
        // 7. NDEF MESSAGE를 파싱하여
        //    BLE 연결 시도
        let ndefmsg = self.mobilepass?.ndefmessageparse(didDetectNDEFs: messages)
        
        let index = ndefmsg!.index(ndefmsg!.startIndex, offsetBy: 3)
        trnValue = String(ndefmsg!.suffix(from: index))

        /*
                DispatchQueue.main.async {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
         */
        
        // 딜레이를 주지 않으면 , NFC 에러 코드를 수신하여 NFC EVENT 모드로 작동해 버림
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            print("NDEF :\(self.trnValue)")
            self.bNdefDetected = true
        }
        
        
        DispatchQueue.main.async {
            self.timerEnding = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerFire), userInfo: nil, repeats: false)
        }
    }

    // MARK: - CBCentralManagerDelegate Methods
    // BLE가 연결되면 호출 되먼 API
    // 연결된 BLE DEVICE 정보를 이용하여 프로세스를 진행함.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi lrssi: NSNumber) {
        
        if( self.bNdefDetected == false )
        {
            return
        }
        if( self.mobilepass?.getNfcUseMode() ==  TMobilePass.MOBILEPASS_NFC_USE_MODE.NDEF_DECTION_MODE)
        {
            if let name = peripheral.name {

                if(  name == "TSAM" + self.trnValue ){
                    print("trnValue = \(String(describing: trnValue))")
                    
                    stopForPeripherals()
                    norbluetoothManager = NORBluetoothManager(withManager: central , withMobilepass: mobilepass!)
                    norbluetoothManager!.delegate = self
                    norbluetoothManager!.connectPeripheral(peripheral: peripheral)
                }
            } else {
                print("aPeripheral.name:No name")
            }
        }
        else
        {
            print("NFC EVENT")
            let success = mobilepass?.isMobilePassAvailable(rssi: lrssi, blemodel: .WT51822S4AT)
            if(  success! )
            {
                iBleFound += 1
                print("iBleFound=\(iBleFound)")
                
                if( iBleFound > 0 )
                {
                    DispatchQueue.main.async {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    }
 
                    if let name = peripheral.name {

                        let bleDeviceName = mobilepass!.sBleTPrefixName
                        if(  name.contains(bleDeviceName) ){
                        //if( mobilepass?.getBleDeviceName() == name ){

                            let index = name.index(name.startIndex, offsetBy: 4)
                            trnValue = String(name.suffix(from: index))
                            print("trnValue = \(String(describing: trnValue))")
                            
                            stopForPeripherals()
                            norbluetoothManager = NORBluetoothManager(withManager: central , withMobilepass: mobilepass!)
                            norbluetoothManager!.delegate = self
                            norbluetoothManager!.connectPeripheral(peripheral: peripheral)
                        }
                    } else {
                        print("aPeripheral.name:No name")
                    }
                }
            }
            else
            {
                iBleFound  = 0
            }
        }
    }
    //MARK: - CBCentralManagerDelegate write
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        guard central.state == .poweredOn else {
            print("centralManagerDidUpdateState Bluetooth is porewed off")
            return
        }
        peripherals = []
        
        let connectedPeripheral = getConnectedPeripherals()
        if( connectedPeripheral != [] ){
            if( norbluetoothManager != nil)
            {
                // Assign to Token
                
                // 1. Plain Text Message 송신 일 떄 사용 ( NFC_BLE_PLAIN_TEXT_MODE )
                // TOCKEN 값을 BLE Channel 로 전송
                // YOU MUST USE NC400LSTLE SMARTNFC READER ( www.ttcnc.co.kr )
                
                // 2. Crypto Text Message 송신 일 때 사용 ( NFC_BLE_CRYPTO_MODE )
                // TOCKEN 값을 DCC ( Digital Communication Channel ) BLE Channel 로 전송
                // YOU MUST USE NC400LSTLE-CRYPTO SMARTNFC READER ( www.ttcnc.co.kr )

                if( self.trnValue.count > 4 )
                {
                    TokenValue = TokenValue + "\r"
                    print("MobilePassAuthenticateProcess TokenValue=\(TokenValue)")
                    mobilepass?.MobilePassAuthenticateProcess( norbluetoothmanager: norbluetoothManager!, trnvalue:trnValue , tocken: TokenValue)
                }
                else
                {
                    print("unExpected trnValue=\(trnValue)")
                }
                
            }
            else
            {
                print("Bluetooth is powered off! retry")
            }
        }
        else
        {
            let success = self.scanForPeripherals(true)
            if success {
                print("Bluetooth scan success")
            }
            else{
                print("Bluetooth is powered off!")
            }
        }
    }
    
    var norbluetoothManager    : NORBluetoothManager?
    var delegate         : NORScannerDelegate?
    
    var filterUUID       : CBUUID?
    var peripherals:[CBPeripheral] = []
    var timerEnding            : Timer?
    
    
    @objc func timerFire() {
        stopForPeripherals()
    }
    
    func getConnectedPeripherals() -> [CBPeripheral] {
        guard let bluetoothManager = bluetoothManager else {
            return []
        }
        var retreivedPeripherals : [CBPeripheral]
        retreivedPeripherals     = bluetoothManager.retrieveConnectedPeripherals(withServices:[filterUUID!])
        return retreivedPeripherals
    }
    
    func stopForPeripherals() {
        bluetoothManager?.stopScan()
        
        print("stopForPeripherals")
        self.timerEnding?.invalidate()
        self.timerEnding = nil
        if let timer = self.timerAction {
            //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
            if timer.isValid {
                /** timerCallback함수 destroy */
                self.timerAction!.invalidate()
                self.timerAction = nil
                print("timerAction Destroy")
            }
        }
    }
    
    /**
     * Starts scanning for peripherals with rscServiceUUID.
     * - parameter enable: If YES, this method will enable scanning for bridge devices, if NO it will stop scanning
     * - returns: true if success, false if Bluetooth Manager is not in CBCentralManagerStatePoweredOn state.
     */
    func scanForPeripherals(_ enable:Bool) -> Bool {
        guard bluetoothManager?.state == .poweredOn else {
            return false
        }

        DispatchQueue.main.async {
            if enable == true {
                let options: NSDictionary = NSDictionary(objects: [NSNumber(value: true as Bool)], forKeys: [CBCentralManagerScanOptionAllowDuplicatesKey as NSCopying])
                
                // UART Service Filter SCAN
                self.bluetoothManager?.scanForPeripherals(withServices: [(self.filterUUID)!], options: options as? [String : AnyObject])
            } else {
                self.bluetoothManager?.stopScan()
            }
        }
        
        return true
    }
    
    
    //MARK: - BluetoothManagerDelegate write
    func peripheralReady() {
        print("Peripheral is ready")
        let connectedPeripheral = getConnectedPeripherals()
        if( connectedPeripheral != [] ){
            
            // 출입통제 인증용 명령어
            // 1. Crypto Text Message 송신 일 때 사용 ( NFC_BLE_CRYPTO_MODE )
            // TOCKEN 값을 DCC ( Digital Communication Channel ) BLE Channel 로 전송
            // YOU MUST USE NC400LSTLE-CRYPTO SMARTNFC READER ( www.ttcnc.co.kr )

            if( self.trnValue.count > 4 )
            {
                // TokenValue must add "\r" value for termination
                TokenValue = TokenValue + "\r"
                print("MobilePassAuthenticateProcess TokenValue=\(TokenValue)")
                mobilepass?.MobilePassAuthenticateProcess( norbluetoothmanager: norbluetoothManager!, trnvalue:trnValue , tocken: TokenValue)
            }
            else
            {
                print("unExpected trnValue=\(trnValue)")
            }
            
        }
    }
    // 설정용 명령어
    // 2. 핸드폰에 토큰 설정하는 절차 중에 본인의 핸드폰 번호 제풀 처리
    // 핸드폰 번호가 저장되어 있지 않으면 "empty" 메시지가 전송됩니다.
    // 핸드폰 번호는 사용자 어플에서 온라인 본인확인을 통해서 저장하시기 바랍니다.
    // FOR NFC_BLE_CRYPTO_MODE
    func didBleRequestPhoneNo() {
        // NOT USED
    }
    // 설정용 명령어
    // 3. 설정 단말기(HOST)로 부터 전송되어 온 토큰 정보 수신하여 저장
    // 토큰 정보는 단말기의 지원 여부에 따라서 평문 또는 암호화 처리과정을 거처서 전달 됨.
    // TokenMsg = HRN[8] || E_TOKEN[24] + "9000"
    // Token 을 핸드폰에 수신 받아 저장이 완료되면
    
    // YOU MUST RESTART APPLICATION
    
    // FOR NFC_BLE_CRYPTO_MODE
    
    func didBleSetTokenProcess(tocken Token: String?, json jsonString: String?) {
        
        // NOT USED
    }
    
    // 본인인증서비스 또는 문자 통지를 통한 사용자 핸드폰 번호 확인 프로그램으로 확인 전화번호를
    // 프로그램 메모리에 저장하여 , 토큰 설정 서비스에서 본인 확인을 위한 서비스로 활용한다.
    
    // FOR NFC_BLE_CRYPTO_MODE
    func setPhoneNo( phone sPhone:String )
    {
        // NOT USED
    }
    func peripheralNotSupported() {
        print("Peripheral is not supported")
    }
    
    func didConnectPeripheral(deviceName aName: String?) {
        // Scanner uses other queue to send events. We must edit UI in the main queue
        DispatchQueue.main.async(execute: {
            print( "didConnectPeripheral")
        })
        
    }
    
    func didDisconnectPeripheral() {
        // Scanner uses other queue to send events. We must edit UI in the main queue
        DispatchQueue.main.async(execute: {
            print( "didDisconnectPeripheral")
        })
        norbluetoothManager = nil
    }
}
