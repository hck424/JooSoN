//
//  CameraViewController.h
//  Hanpass
//
//  Created by INTAEK HAN on 2018. 5. 3..
//  Copyright © 2018년 hanpass. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol  CameraViewControllerDelegate <NSObject>
- (void)didFinishImagePickerWithOrigin:(UIImage *)origin cropImage:(UIImage *)cropImage;
@end

@interface CameraViewController : UIViewController
@property (nonatomic, weak) id<CameraViewControllerDelegate> delegate;
@property (nonatomic, assign) UIImagePickerControllerSourceType sourceType;
@end
