#pragma once

#include <QObject>
#include <QQuickItem>
#include <QMouseEvent>

class SystemUtilsInternal : public QObject
{
    Q_OBJECT
public:
    explicit SystemUtilsInternal(QObject *parent = nullptr);

    Q_INVOKABLE QString qtRuntimeVersion() const;
    Q_INVOKABLE void restartApplication() const;
    Q_INVOKABLE void downloadImageByUrl(const QUrl& url, const QString& path) const;
    Q_INVOKABLE void synthetizeRightClick(QQuickItem* item, qreal x, qreal y, Qt::KeyboardModifiers modifiers) const;
};
