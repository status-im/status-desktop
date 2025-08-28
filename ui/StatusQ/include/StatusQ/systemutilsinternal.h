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
    Q_INVOKABLE void androidMinimizeToBackground();
    Q_INVOKABLE Qt::KeyboardModifiers queryKeyboardModifiers();
    Q_INVOKABLE Qt::MouseButtons mouseButtons();

signals:
    // Emitted when event of type QEvent::Quit is detected by event filter on
    // QGuiApplication. It's helpful to handle close requests on mac coming from
    // various sources (shortcut, menu bar close icon, tray icon menu).
    void quit(bool spontaneous);
};
