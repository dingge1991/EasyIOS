//
//  MBHUD.m
//
//  Created by WenYH on 2015-03-03.
//  Copyright (c) 2015年 Sanzhile. All rights reserved.
//

#import "MBHUD.h"

@implementation MBHUD

//0
+ (MBProgressHUD *)show:(NSString *)text {
	MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
	[[UIApplication sharedApplication].keyWindow addSubview:hud];
	[hud show:YES];
	hud.labelText = text;
	hud.alpha = 0.7;
	hud.removeFromSuperViewOnHide = YES;
    hud.cornerRadius = 5.0f;
    hud.opacity = 0.4f;
    hud.labelFont = [UIFont systemFontOfSize:13.0f];
	return hud;
}

//1
+ (MBProgressHUD *)show:(NSString *)text addedTo:(UIView *)view {
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.labelText = text;
	hud.removeFromSuperViewOnHide = YES;
    hud.cornerRadius = 5.0f;
    hud.opacity = 0.4f;
    hud.labelFont = [UIFont systemFontOfSize:13.0f];
	return hud;
}

//2
+ (MBProgressHUD *)show:(NSString *)text addTo:(UIView *)view x:(float)x y:(float)y {
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.labelText = text;
	hud.alpha = 0.7;
	hud.xOffset = x;
	hud.yOffset = y;
    hud.cornerRadius = 5.0f;
    hud.opacity = 0.4f;
    hud.labelFont = [UIFont systemFontOfSize:13.0f];
	hud.removeFromSuperViewOnHide = YES;
	return hud;
}

//3
+ (void)showWithImage:(NSString *)imageName {
	MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
	[[UIApplication sharedApplication].keyWindow addSubview:hud];
	[hud show:YES];
	hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
	hud.mode = MBProgressHUDModeCustomView;
	hud.color = [UIColor clearColor];
	hud.removeFromSuperViewOnHide = YES;
    hud.cornerRadius = 5.0f;
    hud.opacity = 0.4f;
    hud.labelFont = [UIFont systemFontOfSize:13.0f];
	dispatch_async(dispatch_get_main_queue(), ^{
		[hud hide:YES afterDelay:1.5];
	});
}

//4
+ (void)showWithImage:(NSString *)imageName addedTo:(UIView *)view {
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
	hud.mode = MBProgressHUDModeCustomView;
	hud.color = [UIColor clearColor];
	hud.removeFromSuperViewOnHide = YES;
    hud.cornerRadius = 5.0f;
    hud.opacity = 0.4f;
    hud.labelFont = [UIFont systemFontOfSize:13.0f];
	dispatch_async(dispatch_get_main_queue(), ^{
		[hud hide:YES afterDelay:1.5];
	});
}

//5
+ (void)showWithImage:(NSString *)imageName addedTo:(UIView *)view x:(float)x y:(float)y {
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
	hud.mode = MBProgressHUDModeCustomView;
	hud.color = [UIColor clearColor];
	hud.xOffset = x;
	hud.yOffset = y;
	hud.removeFromSuperViewOnHide = YES;
    hud.cornerRadius = 5.0f;
    hud.opacity = 0.4f;
    hud.labelFont = [UIFont systemFontOfSize:13.0f];
	dispatch_async(dispatch_get_main_queue(), ^{
		[hud hide:YES afterDelay:1.5];
	});
}

//6
+ (void)showWithText:(NSString *)text {
	MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
	[[UIApplication sharedApplication].keyWindow addSubview:hud];
	[hud show:YES];
	hud.labelText = text;
	hud.mode = MBProgressHUDModeText;
	hud.removeFromSuperViewOnHide = YES;
    hud.cornerRadius = 5.0f;
    hud.opacity = 0.4f;
    hud.labelFont = [UIFont systemFontOfSize:13.0f];
	dispatch_async(dispatch_get_main_queue(), ^{
		[hud hide:YES afterDelay:1.5];
	});
}

//7
+ (void)showWithText:(NSString *)text addedTo:(UIView *)view {
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.labelText = text;
	hud.mode = MBProgressHUDModeText;
	hud.removeFromSuperViewOnHide = YES;
    hud.cornerRadius = 5.0f;
    hud.opacity = 0.4f;
    hud.labelFont = [UIFont systemFontOfSize:13.0f];
	dispatch_async(dispatch_get_main_queue(), ^{
		[hud hide:YES afterDelay:1.5];
	});
}

//8
+ (void)showWithText:(NSString *)text addedTo:(UIView *)view x:(float)x y:(float)y {
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.labelText = text;
	hud.mode = MBProgressHUDModeText;
	hud.removeFromSuperViewOnHide = YES;
	hud.xOffset = x;
	hud.yOffset = y;
    hud.cornerRadius = 5.0f;
    hud.opacity = 0.4f;
    hud.labelFont = [UIFont systemFontOfSize:13.0f];
	dispatch_async(dispatch_get_main_queue(), ^{
		[hud hide:YES afterDelay:1.5];
	});
}

//9
+ (void)showWithText:(NSString *)text detailText:(NSString *)detailText {
	MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
	[[UIApplication sharedApplication].keyWindow addSubview:hud];
	[hud show:YES];
	hud.labelText = text;
	hud.detailsLabelText = detailText;
	hud.mode = MBProgressHUDModeText;
	hud.removeFromSuperViewOnHide = YES;
    hud.cornerRadius = 5.0f;
    hud.opacity = 0.4f;
    hud.labelFont = [UIFont systemFontOfSize:13.0f];
	dispatch_async(dispatch_get_main_queue(), ^{
		[hud hide:YES afterDelay:1.5];
	});
}

//10
+ (void)showWithText:(NSString *)text detailText:(NSString *)detailText addedTo:(UIView *)view {
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.labelText = text;
	hud.detailsLabelText = detailText;
	hud.mode = MBProgressHUDModeText;
	hud.removeFromSuperViewOnHide = YES;
    hud.cornerRadius = 5.0f;
    hud.opacity = 0.4f;
    hud.labelFont = [UIFont systemFontOfSize:13.0f];
	dispatch_async(dispatch_get_main_queue(), ^{
		[hud hide:YES afterDelay:1.5];
	});
}

//11
+ (void)showWithText:(NSString *)text detailText:(NSString *)detailText addedTo:(UIView *)view x:(float)x y:(float)y {
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.labelText = text;
	hud.detailsLabelText = detailText;
	hud.mode = MBProgressHUDModeText;
	hud.removeFromSuperViewOnHide = YES;
	hud.xOffset = x;
	hud.yOffset = y;
    hud.cornerRadius = 5.0f;
    hud.opacity = 0.4f;
    hud.labelFont = [UIFont systemFontOfSize:13.0f];
	dispatch_async(dispatch_get_main_queue(), ^{
		[hud hide:YES afterDelay:1.5];
	});
}

//12
+ (void)hide {
	dispatch_async(dispatch_get_main_queue(), ^{
		for (UIView *view in [UIApplication sharedApplication].keyWindow.subviews) {
			if ([view isKindOfClass:[MBProgressHUD class]]) {
				MBProgressHUD *_hud = (MBProgressHUD *)view;
				[_hud hide:YES];
			}
		}
	});
}

//13
+ (void)hideWithNetError {
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([[UIApplication sharedApplication].keyWindow.subviews.lastObject isKindOfClass:[MBProgressHUD class]]) {
			MBProgressHUD *_hud = (MBProgressHUD *)[UIApplication sharedApplication].keyWindow.subviews.lastObject;
			[_hud hide:YES];
		}
		[self showWithText:@"网络错误,请设置网络"];
	});
}

//14
+ (void)showWithTextInResetPassword:(NSString *)text detailText:(NSString *)detailText {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [hud show:YES];
    hud.labelText = text;
    hud.detailsLabelText = detailText;
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.cornerRadius = 5.0f;
    hud.opacity = 0.4f;
    hud.labelFont = [UIFont systemFontOfSize:13.0f];
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud hide:YES afterDelay:1.8];
    });
}


@end
