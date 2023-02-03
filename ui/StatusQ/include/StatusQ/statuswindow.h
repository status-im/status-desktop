#pragma once

#include <QQuickWindow>
#include <QScreen>

class StatusWindow: public QQuickWindow
{
    Q_OBJECT

    Q_PROPERTY(bool isFullScreen READ isFullScreen NOTIFY isFullScreenChanged)

public:
    explicit StatusWindow(QWindow *parent = nullptr);

    Q_INVOKABLE void toggleFullScreen();
    Q_INVOKABLE void updatePosition();

    bool isFullScreen() const;

signals:
    void isFullScreenChanged();

private:
    void removeTitleBar();
    void showTitleBar();

    bool m_isFullScreen;
};
