#include "ios_utils.h"
#include <QStringList>
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>
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
            PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil];
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
