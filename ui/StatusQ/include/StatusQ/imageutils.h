#pragma once

#include <QDir>
#include <QObject>

class ImageUtils : public QObject
{
    Q_OBJECT

public:
    explicit ImageUtils(QObject* parent = nullptr);

    Q_INVOKABLE QString resizeImage(const QString &imagePathOrData, // file path, URL or base64 blob data
                                    int maxSize = 2000, // max img size in px
                                    const QString& tmpDirPath = QDir::tempPath() // tmp dir where to put the converted images
                                    ) const;

    Q_INVOKABLE QStringList resizeImages(const QStringList &imagePathsOrData, // file paths, URLs or base64 blob data
                                         int maxSize = 2000, // max img size in px
                                         const QString& tmpDirPath = QDir::tempPath() // tmp dir where to put the converted images
                                         ) const;
};
