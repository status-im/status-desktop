#ifndef STATUSWINDOW_H
#define STATUSWINDOW_H

#include <QQuickWindow>
#include <QScreen>

class StatusWindow: public QQuickWindow
{
    Q_OBJECT

    Q_PROPERTY(bool isFullScreen READ isFullScreen NOTIFY isFullScreenChanged)

public:
    explicit StatusWindow(QQuickWindow *parent = nullptr);

    Q_INVOKABLE void toggleFullScreen();

    Q_INVOKABLE void updatePosition();

    bool isFullScreen() const;

signals:
    void isFullScreenChanged();

private:
    void removeTitleBar();
    void showTitleBar();
#ifdef Q_OS_WIN
    void removeTitleBarWin();
    void showTitleBarWin();
#elif defined Q_OS_MACOS
    void removeTitleBarMac();
    void showTitleBarMac();
#endif

private:
    bool m_isFullScreen;
};

#endif // STATUSWINDOW_H
