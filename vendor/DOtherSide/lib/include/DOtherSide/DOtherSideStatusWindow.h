#ifndef STATUSWINDOW_H
#define STATUSWINDOW_H

#include <QQuickWindow>

class StatusWindow: public QQuickWindow
{
    Q_OBJECT

    Q_PROPERTY(bool isFullScreen READ isFullScreen NOTIFY isFullScreenChanged)

public:

    explicit StatusWindow(QWindow *parent = nullptr);

    Q_INVOKABLE void toggleFullScreen();

    bool isFullScreen() const;

signals:
    void isFullScreenChanged();

private:
    void removeTitleBar();
    void showTitleBar();
    void initCallbacks();

private:
    bool m_isFullScreen;
};

#endif // STATUSWINDOW_H
