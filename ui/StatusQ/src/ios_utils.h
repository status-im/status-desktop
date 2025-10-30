#pragma once


#ifdef Q_OS_IOS

void saveImageToPhotosAlbum(const QByteArray& imageData);
QString resolveIOSPhotoAsset(const QUrl &assetUrl);

#endif // Q_OS_IOS
