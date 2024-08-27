#pragma once

#include <QObject>

class QQmlEngine;
class QJSEngine;

class UrlUtils : public QObject
{
    Q_OBJECT

public:
    static QObject* qmlInstance(QQmlEngine* engine, QJSEngine* scriptEngine);

    Q_INVOKABLE static bool isValidImageUrl(const QUrl &url,
                                     const QStringList &acceptedExtensions);
    Q_INVOKABLE static qint64 getFileSize(const QUrl &url);
};
