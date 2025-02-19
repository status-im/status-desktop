#pragma once

#include <QObject>

class SystemUtilsInternal : public QObject
{
    Q_OBJECT
public:
    explicit SystemUtilsInternal(QObject *parent = nullptr);

    Q_INVOKABLE QString qtRuntimeVersion() const;
    Q_INVOKABLE void restartApplication() const;
    Q_INVOKABLE void downloadImageByUrl(const QUrl& url, const QString& path) const;
};
