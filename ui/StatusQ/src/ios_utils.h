#pragma once


#ifdef Q_OS_IOS

void saveImageToPhotosAlbum(const QByteArray& imageData);
QString resolveIOSPhotoAsset(const QUrl &assetUrl);

// Keyboard utilities
void setupIOSKeyboardTracking();
int getIOSKeyboardHeight();
bool isIOSKeyboardVisible();

#endif // Q_OS_IOS
