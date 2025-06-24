#ifndef IOSUTILS_H
#define IOSUTILS_H


#ifdef Q_OS_IOS

void saveImageToPhotosAlbum(const QByteArray& imageData);
QString resolveIOSPhotoAsset(const QUrl &assetUrl);
#endif // Q_OS_IOS

#endif // IOSUTILS_H