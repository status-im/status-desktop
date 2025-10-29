#include "ios_utils.h"
#include <QStringList>
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include <QString>
#include <QUrl>

void saveImageToPhotosAlbum(const QByteArray &data)
{
    NSData *imageData = [NSData dataWithBytes:data.constData() length:data.length()];
    UIImage *image = [UIImage imageWithData:imageData];
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    } else {
        NSLog(@"Failed to save image");
    }
}
QString resolveIOSPhotoAsset(const QUrl &assetUrl) {
    @autoreleasepool {
        if (!assetUrl.isValid()) {
            NSLog(@"resolveIOSPhotoAsset: Invalid URL provided");
            return {};
        }

        QString urlStringQt = assetUrl.toString();
        NSString *urlString = urlStringQt.toNSString();

        __block NSString *tempPath = nil;
        __block BOOL success = NO;

        dispatch_semaphore_t sema = dispatch_semaphore_create(0);

        void (^handleResult)(NSData *) = ^(NSData *imageData) {
            if (imageData) {
                NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"resolved.jpg"];
                if ([imageData writeToFile:path atomically:YES]) {
                    tempPath = path;
                    success = YES;
                } else {
                    NSLog(@"resolveIOSPhotoAsset: Failed to write data to file");
                }
            } else {
                NSLog(@"resolveIOSPhotoAsset: No image data received");
            }
            dispatch_semaphore_signal(sema);
        };

        PHAsset *asset = nil;

        if ([urlString hasPrefix:@"ph://"]) {
            NSString *localId = [urlString substringFromIndex:5];
            PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil];
            if (result.count > 0) {
                asset = result.firstObject;
            } else {
                NSLog(@"resolveIOSPhotoAsset: No asset found for ph:// URL");
            }
        } else if ([urlString hasPrefix:@"assets-library://"]) {
            NSURL *assetURL = [NSURL URLWithString:urlString];
            // Use the modern API instead of deprecated fetchAssetsWithALAssetURLs
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil];
            #pragma clang diagnostic pop
            if (result.count > 0) {
                asset = result.firstObject;
            } else {
                NSLog(@"resolveIOSPhotoAsset: No asset found for assets-library:// URL");
            }
        } else {
            NSLog(@"resolveIOSPhotoAsset: URL does not match known formats (ph:// or assets-library://)");
        }

        if (asset) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = YES;
            options.networkAccessAllowed = YES;

            [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:asset
                                                                           options:options
                                                                     resultHandler:^(NSData *imageData, NSString *dataUTI, CGImagePropertyOrientation orientation, NSDictionary *info) {
                handleResult(imageData);
            }];

            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        } else {
            NSLog(@"resolveIOSPhotoAsset: No valid asset found");
        }

        return success ? QString::fromNSString(tempPath) : assetUrl.toString();
    }
}

// Keyboard tracking variables
static int g_keyboardHeight = 0;
static bool g_keyboardVisible = false;
static UIView *g_rootView = nil;

void setupIOSKeyboardTracking() {
    @autoreleasepool {
        // Qt scrolls the view when the keyboard appears by listening to UIKeyboardWillShowNotification
        // and then calling scrollToCursor() which applies a CATransform3D.
        //
        // Our strategy: Listen to the keyboard notifications AFTER Qt does, and immediately
        // undo any transform that was applied. We add our observer with a delay to ensure
        // it runs after Qt's observer.
        
        // First, find and store the root view reference
        // Use a timer to repeatedly try finding the window until it exists
        NSTimer *findWindowTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer *timer) {
            UIWindow *keyWindow = nil;
            
            // Use modern API for getting windows
            if (@available(iOS 15.0, *)) {
                NSSet<UIScene *> *connectedScenes = [UIApplication sharedApplication].connectedScenes;
                for (UIScene *scene in connectedScenes) {
                    if ([scene isKindOfClass:[UIWindowScene class]]) {
                        UIWindowScene *windowScene = (UIWindowScene *)scene;
                        for (UIWindow *window in windowScene.windows) {
                            if (window.isKeyWindow) {
                                keyWindow = window;
                                break;
                            }
                        }
                        if (keyWindow) break;
                    }
                }
            } else {
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
                #pragma clang diagnostic pop
            }
            
            if (keyWindow && keyWindow.rootViewController && keyWindow.rootViewController.view) {
                g_rootView = keyWindow.rootViewController.view;
                NSLog(@"[iOS Keyboard] Found root view: %@, class: %@", g_rootView, [keyWindow.rootViewController class]);
                [timer invalidate]; // Stop the timer once we found the view
            }
        }];
        
        // Listen to keyboard show notification and reset any transform
        // Use WillShow instead of DidShow to prevent the flash
        [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
            NSDictionary *userInfo = notification.userInfo;
            CGRect keyboardFrameScreen = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
            
            // Get screen and window info for debugging
            UIScreen *mainScreen = [UIScreen mainScreen];
            CGFloat screenScale = mainScreen.scale;
            CGFloat screenHeight = mainScreen.bounds.size.height;
            CGRect screenBounds = mainScreen.bounds;
            
            // Log screen coordinate frame
            NSLog(@"[iOS Keyboard] Keyboard frame (screen coords): origin(%f, %f) size(%f, %f)", 
                  keyboardFrameScreen.origin.x, keyboardFrameScreen.origin.y,
                  keyboardFrameScreen.size.width, keyboardFrameScreen.size.height);
            NSLog(@"[iOS Keyboard] Screen: scale=%f, bounds=(%f, %f, %f, %f)", 
                  screenScale, screenBounds.origin.x, screenBounds.origin.y,
                  screenBounds.size.width, screenBounds.size.height);
            
            // Calculate how much of the screen the keyboard actually covers
            // The keyboard Y position tells us where it starts
            CGFloat keyboardVisibleHeight = screenHeight - keyboardFrameScreen.origin.y;
            NSLog(@"[iOS Keyboard] Keyboard top edge at Y=%f, visible height from bottom=%f", 
                  keyboardFrameScreen.origin.y, keyboardVisibleHeight);
            
            // Calculate keyboard coverage in iOS native coordinates
            CGFloat keyboardCoverageNative = screenHeight - keyboardFrameScreen.origin.y;
            
            // Convert to Qt's logical coordinate system
            // iOS uses native screen scale (e.g., 3.0x), but Qt uses its own devicePixelRatio (e.g., 2.4x)
            // We need to convert: qtPoints = (nativePoints × nativeScale) / qtDevicePixelRatio
            // However, we can't access Qt's DPR from here, so we'll use a different approach:
            // Send the coverage in pixels, and let QML divide by its devicePixelRatio
            CGFloat keyboardCoveragePixels = keyboardCoverageNative * screenScale;
            
            NSLog(@"[iOS Keyboard] Keyboard coverage: %f native points = %f pixels (scale %f)",
                  keyboardCoverageNative, keyboardCoveragePixels, screenScale);
            NSLog(@"[iOS Keyboard] QML will need to divide by its devicePixelRatio to get logical points");
            
            // Store as pixels - QML will convert to its logical points
            g_keyboardHeight = (int)keyboardCoveragePixels;
            
            g_keyboardVisible = true;
            NSLog(@"[iOS Keyboard] Final keyboard height (in pixels): %d", g_keyboardHeight);
            
            // Reset transform immediately in the same run loop to prevent flash
            // This runs before Qt's scrollToCursor animation begins
            if (g_rootView) {
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                [CATransaction setAnimationDuration:0];
                g_rootView.layer.sublayerTransform = CATransform3DIdentity;
                [CATransaction commit];
                
                // Also schedule another reset slightly after to catch Qt's delayed animation
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (g_rootView && !CATransform3DIsIdentity(g_rootView.layer.sublayerTransform)) {
                        NSLog(@"[iOS Keyboard] Resetting transform after Qt animation");
                        [CATransaction begin];
                        [CATransaction setDisableActions:YES];
                        [CATransaction setAnimationDuration:0];
                        g_rootView.layer.sublayerTransform = CATransform3DIdentity;
                        [CATransaction commit];
                    }
                });
            }
        }];
        
        // Also listen to DidShow for a final cleanup
        [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
            // Final cleanup - ensure transform is identity
            if (g_rootView && !CATransform3DIsIdentity(g_rootView.layer.sublayerTransform)) {
                NSLog(@"[iOS Keyboard] Final transform reset in DidShow");
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                [CATransaction setAnimationDuration:0];
                g_rootView.layer.sublayerTransform = CATransform3DIdentity;
                [CATransaction commit];
            }
        }];
        
        // Monitor for transform changes continuously while keyboard is visible
        // Qt can apply transforms at any time (focus changes, cursor moves, etc.)
        NSTimer *transformMonitor = [NSTimer scheduledTimerWithTimeInterval:0.016 repeats:YES block:^(NSTimer *timer) {
            if (g_keyboardVisible && g_rootView && !CATransform3DIsIdentity(g_rootView.layer.sublayerTransform)) {
                NSLog(@"[iOS Keyboard] Detected Qt transform while keyboard visible - resetting");
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                [CATransaction setAnimationDuration:0];
                g_rootView.layer.sublayerTransform = CATransform3DIdentity;
                [CATransaction commit];
            }
        }];
        // Keep the timer alive
        [[NSRunLoop currentRunLoop] addTimer:transformMonitor forMode:NSRunLoopCommonModes];
        
        // Track keyboard hide notifications
        [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification) {
            g_keyboardHeight = 0;
            g_keyboardVisible = false;
            NSLog(@"[iOS Keyboard] Keyboard will hide");
            
            // Reset transform when keyboard hides
            if (g_rootView) {
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                [CATransaction setAnimationDuration:0];
                g_rootView.layer.sublayerTransform = CATransform3DIdentity;
                [CATransaction commit];
            }
        }];
    }
}

int getIOSKeyboardHeight() {
    return g_keyboardHeight;
}

bool isIOSKeyboardVisible() {
    return g_keyboardVisible;
}
