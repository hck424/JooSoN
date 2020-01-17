//
//  CameraViewController.m
//  Hanpass
//
//  Created by INTAEK HAN on 2018. 5. 3..
//  Copyright © 2018년 hanpass. All rights reserved.
//

#import "CameraViewController.h"
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "TOCropViewController.h"
#import "UIImage+Utility.h"

//server maximun byte 8194304 이다. 1024로 하면 넘어 간다.
// 카메라 찍을때 칼라가 들어가면 바이트 스가 높아짐, 안전하게 800으로 리사이징
#define SERVER_RESIZE 100

@interface CameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIButton *btnShot;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property (assign, nonatomic) CGFloat overayScale;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, assign) BOOL isFirstLoad;
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    if (_isFirstLoad == NO) {
        [self checkPermissionAfterShowImagePicker];
        _isFirstLoad = YES;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated  {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)checkPermissionAfterShowImagePicker {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    //사용자가 강제로 카메라 접근을 껏을 경우 설정 페이지 유도
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"Unable to access the Camera"
                                                                          message:@"To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app."
                                                                   preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertCon dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertCon addAction:okAction];
        
        UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSURL *settingsUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:settingsUrl]) {
                [[UIApplication sharedApplication] openURL:settingsUrl options:@{} completionHandler:nil];
            }
            else {
                [alertCon dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        [alertCon addAction:settingAction];
        [self presentViewController:alertCon animated:YES completion:nil];
    }
    else if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self displayImagePicker];
                });
            }
        }];
    }
    else {
        [self displayImagePicker];
    }
}

#pragma mark - Touch Event Method Management
- (IBAction)onClickedButtonAction:(UIButton *)sender {
    if (sender == _btnShot) {
        [_imagePicker takePicture];
    }
    else if (sender == _btnCancel) {
        [_imagePicker dismissViewControllerAnimated:NO completion:^{
            [self.navigationController popViewControllerAnimated:NO];
        }];
    }
}

- (UIImage *)cropImage:(UIImage*)image toRect:(CGRect)rect {
    CGFloat (^rad)(CGFloat) = ^CGFloat(CGFloat deg) {
        return deg / 180.0f * (CGFloat) M_PI;
    };
    
    // determine the orientation of the image and apply a transformation to the crop rectangle to shift it to the correct position
    CGAffineTransform rectTransform;
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -image.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -image.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -image.size.width, -image.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    // adjust the transformation scale based on the image scale
    rectTransform = CGAffineTransformScale(rectTransform, image.scale, image.scale);
    
    // apply the transformation to the rect to create a new, shifted rect
    CGRect transformedCropSquare = CGRectApplyAffineTransform(rect, rectTransform);
    // use the rect to crop the image
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, transformedCropSquare);
    // create a new UIImage and set the scale and orientation appropriately
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    // memory cleanup
    CGImageRelease(imageRef);
    
    return result;
}
- (void)displayImagePicker {
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.delegate = self;
    _imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    _imagePicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    if (_sourceType == UIImagePickerControllerSourceTypeCamera) {
        _imagePicker.sourceType = _sourceType;
        
        _imagePicker.navigationBarHidden = YES;
        _imagePicker.toolbarHidden = YES;
        _imagePicker.allowsEditing = NO;
        _imagePicker.showsCameraControls = NO;
        
        CGRect screenRect = [UIScreen mainScreen].bounds;
        _imagePicker.view.frame = screenRect;
        
        CGRect safeRect = screenRect;
        
        @try {
            if (@available(iOS 11.0, *)) {
                UIWindow *window = UIApplication.sharedApplication.keyWindow;
                safeRect = window.safeAreaLayoutGuide.layoutFrame;
            }
        } @catch (NSException *exception) {
            safeRect = screenRect;
            NSLog(@"%@", exception.callStackSymbols);
        }
        
        _overlayView.frame =  safeRect;
        _imagePicker.cameraOverlayView = _overlayView;
        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        float cameraAspectRatio = 4.0 / 3.0;
        float imageHeight = floorf(screenSize.width * cameraAspectRatio);
        _overayScale = screenSize.height / imageHeight;
        
        float trans = (screenSize.height - imageHeight)/2;
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, trans);
        CGAffineTransform final = CGAffineTransformScale(translate, _overayScale, _overayScale);
        _imagePicker.cameraViewTransform = final;
    }
    else {
        
        _imagePicker.allowsEditing = NO;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //        [_imagePicker setMediaTypes:[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary]];
    }
    
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    
    UIImage *orgImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (_sourceType == UIImagePickerControllerSourceTypeCamera && orgImage) {
        
        UIImage *serverImg = orgImage;
        if (serverImg.size.width > SERVER_RESIZE || serverImg.size.height > SERVER_RESIZE) {
            serverImg = [serverImg resizedImageWithBounds:CGSizeMake(SERVER_RESIZE, SERVER_RESIZE)];
        }
        
        [picker dismissViewControllerAnimated:NO completion:^{
            //화면 날려주고 딜리게이트로 이미지 전송,
            //혹 pop 하면 delegate 해제될것 같지만 블럭 {} 안에 있기때문에 안전
            self.navigationController.navigationBarHidden = NO;
            [UIApplication sharedApplication].statusBarHidden = NO;
            [self.navigationController popViewControllerAnimated:NO];
            
            NSData *data = UIImageJPEGRepresentation(serverImg, 1.0);
            NSLog(@"server iamge size: %@, byte: %lu", NSStringFromCGSize(serverImg.size), (unsigned long)data.length);
            
            if ([self.delegate respondsToSelector:@selector(didFinishImagePickerWithOrigin:cropImage:)]) {
                [self.delegate didFinishImagePickerWithOrigin:orgImage cropImage:serverImg];
            }
        }];
    }
    else  if (orgImage != nil) {
        [picker dismissViewControllerAnimated:NO completion:^{
            TOCropViewController *vc = [[TOCropViewController alloc] initWithCroppingStyle:TOCropViewCroppingStyleDefault image:orgImage];
            vc.delegate = self;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:vc animated:NO completion:nil];
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:NO completion:^{
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

#pragma mark - TOCropViewControllerDelegate
- (void)cropViewController:(nonnull TOCropViewController *)cropViewController
            didCropToImage:(nonnull UIImage *)image withRect:(CGRect)cropRect
                     angle:(NSInteger)angle {
    
    [cropViewController dismissViewControllerAnimated:NO completion:^{
        [self.navigationController popViewControllerAnimated:NO];
        
        if ([self.delegate respondsToSelector:@selector(didFinishImagePickerWithOrigin:cropImage:)]) {
            
            UIImage *serverImg = image;
            if (serverImg.size.width > SERVER_RESIZE || serverImg.size.height > SERVER_RESIZE) {
                serverImg = [serverImg resizedImageWithBounds:CGSizeMake(SERVER_RESIZE, SERVER_RESIZE)];
            }
            [self.delegate didFinishImagePickerWithOrigin:image cropImage:serverImg];
            NSData *data = UIImageJPEGRepresentation(serverImg, 1.0);
            NSLog(@"server iamge size: %@, byte: %lu", NSStringFromCGSize(serverImg.size), (unsigned long)data.length);
        }
    }];
}

- (void)cropViewController:(nonnull TOCropViewController *)cropViewController
        didFinishCancelled:(BOOL)cancelled {
    [cropViewController dismissViewControllerAnimated:NO completion:^{
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

#pragma mark - Memory Warnning Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
