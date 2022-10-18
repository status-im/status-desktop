#pragma once

#include <QObject>

class QQmlEngine;

class CacheCleaner : public QObject
{
    Q_OBJECT
public:
    explicit CacheCleaner(QQmlEngine* engine);
    Q_INVOKABLE void clearComponentCache() const;

private:
    QQmlEngine* engine;
};
