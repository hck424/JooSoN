//
//  AddJooSoViewController.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/26.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "AddJooSoViewController.h"
#import "AddPhoneNumberField.h"
#import "CameraViewController.h"
#import "UIView+Utility.h"
#import "PopupListViewController.h"
#import "NBAsYouTypeFormatter.h"
#import "ContactsManager.h"
#import "DBManager.h"
#import "UIView+Toast.h"
#import "NSString+Utility.h"
#import "Utility.h"
#import "NSObject+Utility.h"
#import "MapSearchViewController.h"
#import "GoogleMapView.h"

@interface AddJooSoViewController () <AddPhoneNumberFieldDelegate, CameraViewControllerDelegate, UIScrollViewDelegate, PopupListViewControllerDelegate, MapSearchViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *lbEmptyLoc;
@property (weak, nonatomic) IBOutlet UIButton *btnEmptyLoc;
@property (weak, nonatomic) IBOutlet UIButton *btnMapSearch;

@property (strong, nonatomic) IBOutlet UIView *floatView;
@property (weak, nonatomic) IBOutlet UIButton *btnMainPhoneApoint;
@property (weak, nonatomic) IBOutlet UIButton *btnMainPhoneCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnMainPhoneDelete;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnAddPhonField;
@property (weak, nonatomic) IBOutlet UIStackView *svPhoneFields;
@property (weak, nonatomic) IBOutlet UIButton *btnGroup;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *lbMainPhone;
@property (strong, nonatomic) IBOutlet UIToolbar *accessoryView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnKeyboardDown;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfAddress;
@property (weak, nonatomic) IBOutlet UITextField *tfGroup;

@property (nonatomic, strong) NBAsYouTypeFormatter *nbaFomater;
@property (nonatomic, strong) UIImage *imgProfile;
@property (nonatomic, strong) NSMutableArray *arrPhoneType;
@property (nonatomic, strong) NSLayoutConstraint *topfloatView;
@property (nonatomic, strong) AddPhoneNumberField *selPhoneNumField;
@property (nonatomic, strong) NSString *edtingPhoneNumber;
@property (nonatomic, strong) NSMutableArray <GroupName *> *arrGroup;
@property (nonatomic, strong) ContactsManager *contactsManager;

@property (nonatomic, strong) GoogleMapView *googleMapView;
@property (nonatomic, strong) UIView *selMapView;

@end

@implementation AddJooSoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrGroup = [NSMutableArray array];
    self.arrPhoneType = [NSMutableArray arrayWithObjects:
                         JooSoPhoneLabelMobile,
                         JooSoPhoneLabelHome,
                         JooSoPhoneLabelWork,
                         JooSoPhoneLabelSchool,
                         JooSoPhoneLabelHomeFAX,
                         JooSoPhoneLabelWorkFAX,
                         JooSoPhoneLabelPager,
                         JooSoPhoneLabelOther, nil];
    
    
    if (_viewType == ViewTypeModi) {
        [_btnBack setTitle:@"연락처 수정" forState:UIControlStateNormal];
    }
    else {
        [_btnBack setTitle:@"연락처 추가" forState:UIControlStateNormal];
    }
    _btnAddPhonField.layer.borderColor = RGB(216, 216, 216).CGColor;
    _btnAddPhonField.layer.borderWidth = 1.0f;
    _btnAddPhonField.layer.cornerRadius = _btnAddPhonField.frame.size.height/2;
    
    _btnProfile.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _btnProfile.layer.borderColor = RGB(216, 216, 216).CGColor;
    _btnProfile.layer.borderWidth = 1.0f;
    _btnProfile.layer.cornerRadius = _btnProfile.frame.size.height/2;
    
    _tfName.inputAccessoryView = _accessoryView;
    _tfAddress.inputAccessoryView = _accessoryView;
    _floatView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_floatView];
    self.topfloatView  = [_floatView.topAnchor constraintEqualToAnchor:_svPhoneFields.topAnchor constant:50];
    _topfloatView.active = YES;
    [_floatView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-10].active = YES;
    [_floatView.widthAnchor constraintEqualToConstant:130].active = YES;
    [_floatView.heightAnchor constraintEqualToConstant:127].active = YES;
    self.nbaFomater = [[NBAsYouTypeFormatter alloc] initWithRegionCode:@"KR"];
    
    _floatView.layer.cornerRadius = 16;
    _floatView.layer.borderColor = RGB(36, 183, 179).CGColor;
    _floatView.layer.borderWidth = 1.0f;
    
    [_floatView addShadow:CGSizeMake(5, 5) color:RGBA(0, 0, 0, 0.5) radius:3 opacity:0.5];
    _floatView.hidden = YES;
    
    if (_viewType == ViewTypeAdd) {
        if (_passPhoneNumber.length > 0) {
            _lbMainPhone.text = [_nbaFomater inputString:_passPhoneNumber];
        }
        if (_placeInfo != nil) {
            _tfAddress.text = _placeInfo.jibun_address;
            _tfName.text = _placeInfo.name;
        }
    }
    else if (_viewType == ViewTypeModi && _passJooso != nil) {
        if (_passJooso.toThumnail.image) {
            [_btnProfile setImage:_passJooso.toThumnail.image forState:UIControlStateNormal];
        }
        else {
            [_btnProfile setImage:[UIImage imageNamed:@"icon_profile_people_s"] forState:UIControlStateNormal];
        }
        
        NSString *name = _passJooso.name;
        if (name.length > 0) {
            _tfName.text = name;
        }
        
        _lbMainPhone.text = [_passJooso getMainPhone];
        
        for (PhoneNumber *ph in [_passJooso.toPhoneNumber array]) {
            [self addPhoneFiledWithTitle:ph.label phoneNumber:ph.number isMainPhone:ph.isMainPhone];
        }
        
        if (_passPhoneNumber.length > 0) {
            [self addPhoneFiledWithTitle:@"" phoneNumber:_passPhoneNumber isMainPhone:NO];
        }
        if (_passJooso.geoLat > 0 && _passJooso.geoLng > 0) {
            self.placeInfo = [[PlaceInfo alloc] init];
            _placeInfo.x = _passJooso.geoLng;
            _placeInfo.y = _passJooso.geoLat;
            _placeInfo.name = _passJooso.placeName;
            _placeInfo.road_address = _passJooso.roadAddress;
            _placeInfo.jibun_address = _passJooso.address;
        }
        
        _tfAddress.text = _passJooso.address;
        _tfGroup.text = _passJooso.groupName;
    }
    
    
    if (_placeInfo.x > 0 && _placeInfo.y > 0) {
        _lbEmptyLoc.hidden = YES;
        _btnEmptyLoc.hidden = YES;
        [self addSubViewGoogleMap];
    }
    
    [self requestGroupNameList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:NotiNameHitTestView object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotiNameHitTestView object:nil];
}
- (void)addPhoneFiledWithTitle:(NSString *)title phoneNumber:(NSString *)phoneNumber isMainPhone:(BOOL)isMainPhone {
    
    AddPhoneNumberField *fieldView = [[NSBundle mainBundle] loadNibNamed:@"AddPhoneNumberField" owner:self options:nil].firstObject;
    
    fieldView.translatesAutoresizingMaskIntoConstraints = NO;
    fieldView.delegate = self;
    [_svPhoneFields addArrangedSubview:fieldView];
    fieldView.phoneTitle = title;
    fieldView.isMainPhone = isMainPhone;
    fieldView.tfPhoneNumber.text = phoneNumber;
    fieldView.tfPhoneNumber.inputAccessoryView = _accessoryView;
}

#pragma mark - textFieldEdtingChanged
- (IBAction)textFieldEdtingChanged:(UITextField *)sender {
    
}


#pragma mark - Tap Gestures
- (IBAction)singleTapGesture:(UITapGestureRecognizer *)sender {

    if ([sender.view isEqual:self.view]) {
        [self.view endEditing:YES];
    }
}

#pragma mark - Onclicked Actions
- (IBAction)onClickedButtonAction:(id)sender {
    
    if (sender == _btnBack) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (sender == _btnAddPhonField) {
        NSInteger idx = [_svPhoneFields.subviews count] % _arrPhoneType.count;
        NSString *title = [_arrPhoneType objectAtIndex:idx];
        [self addPhoneFiledWithTitle:title phoneNumber:nil isMainPhone:NO];
    }
    else if (sender == _btnEmptyLoc
             || sender == _btnMapSearch) {
        
        MapSearchViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapSearchViewController"];
        PlaceInfo *info = nil;
        vc.delegate = self;
        if (_placeInfo != nil) {
            info = _placeInfo;
        }
        else if (_passJooso != nil) {
            info = [[PlaceInfo alloc] init];
            info.x = _passJooso.geoLng;
            info.y = _passJooso.geoLat;
            info.jibun_address = _passJooso.address;
            info.name = _passJooso.placeName;
            info.road_address = _passJooso.roadAddress;
        }
        else {
            vc.searchAddress = _tfAddress.text;
        }
        vc.passPlaceInfo = info;
    
        [self.navigationController pushViewController:vc animated:NO];
    }
    else if (sender == _btnProfile) {
        
        __weak typeof(self) weakSelf = self;
        __block UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"선택해 주세요" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *camera = [UIAlertAction actionWithTitle:@"카메라" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            [weakSelf showImagePickerController:UIImagePickerControllerSourceTypeCamera];
        }];
        UIAlertAction *gallery = [UIAlertAction actionWithTitle:@"가져오기" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            [weakSelf showImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:camera];
        [alert addAction:gallery];
        [alert addAction:cancel];
        
        alert.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if (sender == _btnMainPhoneApoint) {
        
        for (AddPhoneNumberField *field in [_svPhoneFields subviews]) {
            field.isMainPhone = NO;
        }
        
        if (_selPhoneNumField) {
            _selPhoneNumField.isMainPhone = YES;
            _lbMainPhone.text = [_nbaFomater inputString:_selPhoneNumField.tfPhoneNumber.text];
        }
    }
    else if (sender == _btnMainPhoneCancel) {
        _lbMainPhone.text = nil;
        for (AddPhoneNumberField *field in [_svPhoneFields subviews]) {
            field.isMainPhone = NO;
        }
    }
    else if (sender == _btnMainPhoneDelete) {
        if (self.selPhoneNumField) {
            [_selPhoneNumField removeFromSuperview];
            self.selPhoneNumField = nil;
        }
    }
    else if (sender == _btnKeyboardDown) {
        [self.view endEditing:YES];
    }
    else if (sender == _btnGroup) {
        [self showPopUpGropList];
    }
    else if (sender == _btnSave) {
        
        if ([self canSaved] == NO) {
            if (_viewType == ViewTypeAdd) {
                [self.view makeToast:@"필수 정보가 없습니다." duration:1.0 position:CSToastPositionCenter];
            }
            else if (_viewType == ViewTypeModi) {
                [self.view makeToast:@"변경할 정보가 없습니다." duration:1.0 position:CSToastPositionCenter];
            }
            return;
        }
        
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        
        if (_tfName.text.length > 0) {
            [param setObject:_tfName.text forKey:@"name"];
        }
        
        NSMutableArray *arrPhone = [NSMutableArray array];
        
        BOOL findMainPhone = NO;
        for (AddPhoneNumberField *field in [_svPhoneFields subviews]) {
            if (field.isMainPhone) {
                findMainPhone = YES;
            }
        }
        
        int cnt = 0;
        for (AddPhoneNumberField *field in [_svPhoneFields subviews]) {
            NSString *number = [field.tfPhoneNumber.text delPhoneFormater];
            NSMutableDictionary *itemDic = [NSMutableDictionary dictionary];
            [itemDic setObject:field.btnPhoneTitle.titleLabel.text forKey:@"label"];
            [itemDic setObject:number forKey:@"number"];
            if (findMainPhone == NO && cnt == 0) {
                [itemDic setObject:[NSNumber numberWithBool:YES] forKey:@"isMainPhone"];
            }
            else {
                [itemDic setObject:[NSNumber numberWithBool:field.isMainPhone] forKey:@"isMainPhone"];
            }
            cnt++;
            [arrPhone addObject:itemDic];
        }
        
        [param setObject:arrPhone forKey:@"phoneNumbers"];
        
        if (_tfAddress.text.length > 0) {
            [param setObject:_tfAddress.text forKey:@"address"];
        }
        
        if (_tfGroup.text.length > 0) {
            [param setObject:_tfGroup.text forKey:@"groupName"];
        }
        
        if (_imgProfile != nil) {
            [param setObject:_imgProfile forKey:@"thumnail"];
        }
        [param setObject:[Utility createLocalIdentifier] forKey:@"localIdentifier"];
        
        if (_placeInfo != nil) {
            if ([_placeInfo.jibun_address length] > 0) {
                [param setObject:_placeInfo.jibun_address forKey:@"roadAddress"];
            }
            if ([_placeInfo.name length] > 0) {
                [param setObject:_placeInfo.name forKey:@"placeName"];
            }
            [param setObject:[NSNumber numberWithFloat:_placeInfo.y] forKey:@"geoLat"];
            [param setObject:[NSNumber numberWithFloat:_placeInfo.x] forKey:@"geoLng"];
        }
        
        if (_viewType == ViewTypeAdd) {
            
            //전화번호부에 저장
            if (arrPhone.count > 0 && _tfName.text.length > 0) {
                //핸드폰 전화번호부에 저장;
                
                if (_contactsManager == nil) {
                    self.contactsManager = [[ContactsManager alloc] init];
                }
                
                [_contactsManager insertAddressBook:param completion:^(BOOL success, NSError *error) {
                    if (success) {
                        //                    [self.view makeToast:@"전화부에 저장 되었습니다." duration:.0 position:CSToastPositionTop];
                    }
                }];
            }
            
            // insert new group 그룹
            if (_tfGroup.text.length > 0) {
                GroupName *findGroup = nil;
                for (GroupName *group in _arrGroup) {
                    if ([group.name isEqualToString:_tfGroup.text]) {
                        findGroup = group;
                        break;
                    }
                }
                
                if (findGroup != nil) {
                    findGroup.count = findGroup.count + 1;
                    [[DBManager instance] updateGroupName:findGroup success:nil fail:nil];
                }
            }
            
            
            //로컬 디비 저장
            [[DBManager instance] insertJooSo:param success:^{
                NSLog(@"success add jooso");
                
                [self.view makeToast:@"전화부에 저장 되었습니다." duration:0.5 position:CSToastPositionTop];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:NO];
                });
                
            } fail:^(NSError *error) {
                NSLog(@"error: add jooso fail > %@", error);
            }];
        }
        else if (_viewType == ViewTypeModi) {
            
            if (arrPhone.count > 0 && _tfName.text.length > 0) {
                [param setObject:_passJooso.name forKey:@"oldName"];
                [param setObject:[_passJooso getPhoneNumbers] forKey:@"oldPhoneNumbers"];
                
                if (_contactsManager == nil) {
                    self.contactsManager = [[ContactsManager alloc] init];
                }
                
                [_contactsManager updateAddressBook:param completion:^(BOOL success, NSError *error) {
                    if (success) {
                        NSLog(@"success update address book");
                    }
                    else {
                        NSLog(@"fail update address book");
                    }
                }];
            }
            
            //update groupname
            if ([_passJooso.groupName isEqualToString:_tfGroup.text] == NO) {
                GroupName *findGroup = nil;
                for (GroupName *group in _arrGroup) {
                    if ([group.name isEqualToString:_tfGroup.text]) {
                        findGroup = group;
                        break;
                    }
                }
                
                GroupName *oldFindGroup = nil;
                for (GroupName *group in _arrGroup) {
                    if ([group.name isEqualToString:_passJooso.groupName]) {
                        oldFindGroup = group;
                        break;
                    }
                }
                
                if (findGroup) {
                    findGroup.count = findGroup.count + 1;
                    [[DBManager instance] updateGroupName:findGroup success:nil fail:nil];
                }
                if (oldFindGroup) {
                    oldFindGroup.count = oldFindGroup.count - 1;
                    [[DBManager instance] updateGroupName:oldFindGroup success:nil fail:nil];
                }
            }
            
            [param setObject:_passJooso forKey:@"oldJooSo"];
            [[DBManager instance] updateJooSo:param success:^{
                NSLog(@"success update jooso");
                [self.view makeToast:@"전화부에 저장 되었습니다." duration:0.5 position:CSToastPositionTop];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popToRootViewControllerAnimated:NO];
                });
                
            } fail:^(NSError *error) {
                NSLog(@"error: update jooso fail > %@", error);
            }];

        }
    }
    else {
        
    }
   
}

- (BOOL)canSaved {
    BOOL isOk = NO;
    
    if (_viewType == ViewTypeAdd) {
        if (_tfName.text.length > 0) {
            isOk = YES;
        }
        
        if (_lbMainPhone.text.length > 0) {
            isOk = YES;
        }
        
        for (AddPhoneNumberField *field in [_svPhoneFields subviews]) {
            if (field.tfPhoneNumber.text.length > 0) {
                isOk = YES;
                break;
            }
        }
        
        if (_tfAddress.text > 0) {
            isOk = YES;
        }
    }
    else {
        if (_passJooso != nil) {
            if ([_tfName.text isEqualToString:_passJooso.name] == NO) {
                isOk = YES;
            }
            if (_imgProfile != nil) {
                isOk = YES;
            }
            
            if ([_passJooso.address isEqualToString:_tfAddress.text] == NO) {
                isOk = YES;
            }
            
            if (_passJooso.groupName.length > 0 && _tfGroup.text.length > 0
                && [_passJooso.groupName isEqualToString:_tfGroup.text] == NO) {
                isOk = YES;
            }
            
            isOk = YES;
        }
    }
    return isOk;
}
- (void)showPopUpGropList {
    NSMutableArray *arr = [NSMutableArray array];
    
    for (GroupName *group in _arrGroup) {
        [arr addObject:group.name];
    }

    PopupListViewController *vc = [[PopupListViewController alloc] init];
    vc.arrData = arr;
    vc.popupType = PopupListTypeEding;
    vc.delegate = self;
    vc.popupTitle = @"그룹 지정해 주세요";
    vc.arrBtnTitle = @[@"확인", @"그룹해제"];
    vc.arrBtnTitleColor = @[RGB(33, 170, 164), RGB(125, 125, 125)];
    vc.endingFieldTitle = @"새 그룹";
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:vc animated:NO completion:nil];
}
-(void)showImagePickerController:(UIImagePickerControllerSourceType)sourceType {
    CameraViewController *vc = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];
    vc.delegate = self;
    vc.sourceType = sourceType;
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark - AddPhoneNumberFieldDelegate
- (void)addPhoneNumberField:(AddPhoneNumberField *)field action:(FieldActionType)actionType withObject:(NSString *)object {
    
    [self.view endEditing:YES];
    
    
    self.selPhoneNumField = nil;
    if (actionType == FieldActionTypePlus) {
        self.selPhoneNumField = field;
        
        PopupListViewController *vc = [[PopupListViewController alloc] init];
        vc.arrData = _arrPhoneType;
        vc.popupType = PopupListTypeDefault;
        vc.popupTitle = @"선택해 주세요";
        vc.delegate = self;
        vc.arrBtnTitle = @[@"취소"];
        vc.arrBtnTitleColor = @[[UIColor redColor]];
        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:vc animated:NO completion:nil];
    }
    else if (actionType == FieldActionTypeMore) {
        self.selPhoneNumField = field;
        NSInteger idx = 0;
        CGFloat height = 50;
        for (NSInteger i = 0; i < [_svPhoneFields.subviews count]; i++) {
            AddPhoneNumberField *tmpView = [_svPhoneFields.subviews objectAtIndex:i];
            if ([tmpView isEqual:field]) {
                idx = i;
                height = tmpView.frame.size.height;
                break;
            }
        }
        
        height = (idx +1) * height + 3;
        _topfloatView.constant = height;
        _floatView.hidden = NO;
        
    }
    else if (actionType == FieldActionTypeDelete) {
        [field removeFromSuperview];
        if ([[_svPhoneFields subviews] count] == 0) {
            _lbMainPhone.text = @"";
        }
        self.selPhoneNumField =  nil;
    }
}

- (void)addPhoneNumberFieldTextFieldDidBeginEditing {
    
    self.edtingPhoneNumber = nil;
}
- (void)addPhoneNumberFieldTextFieldEdtingChangedString:(NSString *)str {
    self.edtingPhoneNumber = str;
}

#pragma mark - CameraViewControllerDelegate
- (void)didFinishImagePickerWithOrigin:(UIImage *)origin cropImage:(UIImage *)cropImage {
    _imgProfile = cropImage;
    [_btnProfile setImage:cropImage forState:UIControlStateNormal];
}

- (void)requestGroupNameList {
    [[DBManager instance] getAllGroupName:^(NSArray *arrData) {
        if (arrData.count > 0) {
            [self.arrGroup setArray:arrData];
        }
    } fail:^(NSError *error) {
        NSLog(@"error: get all groplist > %@", error.localizedDescription);
    }];
}
#pragma mark - PupUpListViewControllerDelegate
- (void)popupListViewController:(UIViewController *)vc type:(PopupListType)type dataIndex:(NSInteger)dataIndex selecteData:(id)data btnIndex:(NSInteger)btnIndex {
    
    [vc dismissViewControllerAnimated:NO completion:nil];
    
    if (type == PopupListTypeDefault) {
        if (btnIndex == - 1 && dataIndex >= 0) {
            _selPhoneNumField.phoneTitle = data;
            [_selPhoneNumField setNeedsDisplay];
        }
    }
    else if (type == PopupListTypeEding) {
        if (dataIndex >= 0 && data != nil) {
            _tfGroup.text = data;
        }
        else if (btnIndex == 0) {
            NSString *newGroup = data;
            _tfGroup.text = newGroup;
            
            if ([self isNewGropName:newGroup]) {
                [self.view makeToast:@"이미 그룹에 있습니다." duration:1.0 position:CSToastPositionCenter];
            }
            else {
                __weak typeof(self) weakSelf = self;
                [[DBManager instance] insertGroupName:newGroup count:0 success:^{
                    NSLog(@"success: new group insert");
                    [weakSelf requestGroupNameList];
                } fail:^(NSError *error) {
                    NSLog(@"error: insert group > %@", error.localizedDescription);
                }];
                
            }
        }
        else if (btnIndex == 1) {
            _tfGroup.text = @"";
        }
    }
}

- (BOOL)isNewGropName:(NSString *)name {
    BOOL find = YES;
    for (GroupName *group in _arrGroup) {
        if ([group.name isEqualToString:name]) {
            find = NO;
            break;
        }
    }
    return find;
}
#pragma mark - Notification Handler
- (void)notificationHandler:(NSNotification *)notification {
    if ([notification.name isEqualToString:NotiNameHitTestView]) {
        if (_floatView != nil && _floatView.hidden == NO) {
            _floatView.hidden = YES;
        }
    }
}

#pragma mark - mapview add
- (void)addSubViewGoogleMap {
    if (_googleMapView != nil) {
        [_googleMapView removeFromSuperview];
    }
    
    self.googleMapView = [[NSBundle mainBundle] loadNibNamed:@"GoogleMapView" owner:self options:nil].firstObject;
    _googleMapView.frame = _mapView.bounds;
    _googleMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_mapView addSubview:_googleMapView];
    
    [_googleMapView setMarker:_placeInfo draggable:NO];
    [_googleMapView moveMarker:_placeInfo zoom:14];
}

#pragma mark - MapSearchViewControllerDelegate
- (void)mapSearchVCSelectedPlace:(PlaceInfo *)place {
    
    self.placeInfo = place;
    _tfAddress.text = _placeInfo.jibun_address;
    
    _lbEmptyLoc.hidden = YES;
    _btnEmptyLoc.hidden = YES;
    
    [self addSubViewGoogleMap];
    
}
@end
