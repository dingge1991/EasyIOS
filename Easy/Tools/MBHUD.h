//
//  MBHUD.h
//
//  Created by WenYH on 2015-03-03.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface MBHUD : NSObject

/**0
*  HUD addTo window
*
*  @param text
*
*  @return hud
*/
+ (MBProgressHUD *)show:(NSString *)text;

/**1
 *  HUD addTo view
 *
 *  @param text
 *  @param view
 *
 *  @return hud
 */
+ (MBProgressHUD *)show:(NSString *)text addedTo:(UIView *)view;

/**2
 *  HUD addTo view
 *
 *  @param text
 *  @param view
 *  @param x    xOffset
 *  @param y    yOffset
 *
 *  @return hud
 */
+ (MBProgressHUD *)show:(NSString *)text addedTo:(UIView *)view x:(float)x y:(float)y;

/**3
 *  image addTo window
 *
 *  @param imageName
 */
+ (void)showWithImage:(NSString *)imageName;

/**4
 *  image addTo view
 *
 *  @param imageName
 *  @param view
 */
+ (void)showWithImage:(NSString *)imageName addedTo:(UIView *)view;

/**5
 *  image addTo view
 *
 *  @param imageName
 *  @param view
 *  @param x         xOffset
 *  @param y         yOffset
 */
+ (void)showWithImage:(NSString *)imageName addedTo:(UIView *)view x:(float)x y:(float)y;

/**6
 *  text addTo window
 *
 *  @param text
 */
+ (void)showWithText:(NSString *)text;

/**7
 *  text addTo view
 *
 *  @param text
 *  @param view
 */
+ (void)showWithText:(NSString *)text addedTo:(UIView *)view;

/**8
 *  text addTo view
 *
 *  @param text
 *  @param view
 *  @param x    xOffset
 *  @param y    yOffset
 */
+ (void)showWithText:(NSString *)text addedTo:(UIView *)view x:(float)x y:(float)y;

/**9
 *  text&detailText addTo window
 *
 *  @param text
 *  @param detailText
 */
+ (void)showWithText:(NSString *)text detailText:(NSString *)detailText;

/**10
 *  text&detailText addTo view
 *
 *  @param text
 *  @param detailText
 *  @param view
 */
+ (void)showWithText:(NSString *)text detailText:(NSString *)detailText addedTo:(UIView *)view;

/**11
 *  text&detailText addTo view
 *
 *  @param text
 *  @param detailText
 *  @param view
 *  @param x          xOffset
 *  @param y          yOffset
 */
+ (void)showWithText:(NSString *)text detailText:(NSString *)detailText addedTo:(UIView *)view x:(float)x y:(float)y;

/**12
 *  hide all hud
 */
+ (void)hide;

/**13
 *  hide all hud & show net error
 */
+ (void)hideWithNetError;

/**14
 *
 */
+ (void)showWithTextInResetPassword:(NSString *)text detailText:(NSString *)detailText;
@end
