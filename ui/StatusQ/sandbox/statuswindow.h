#ifndef STATUSWINDOW_H
#define STATUSWINDOW_H

#include <QQuickWindow>
#include <QScreen>

class StatusWindow: public QQuickWindow
{
    Q_OBJECT

    Q_PROPERTY(bool isFullScreen READ isFullScreen NOTIFY isFullScreenChanged)

public:
    struct EventCallbacks {
        std::function<void()> onResize;
        std::function<void()> willExitFullScreen;
        std::function<void()> didExitFullScreen;
    };

    explicit StatusWindow(QWindow *parent = nullptr)
        : QQuickWindow(parent),
          m_isFullScreen(false)
    {
        removeTitleBar();

        connect(this, &QQuickWindow::windowStateChanged, [&](Qt::WindowState windowState) {
            if (windowState == Qt::WindowNoState) {
                removeTitleBar();
                m_isFullScreen = false;
                emit isFullScreenChanged();
            } else if (windowState == Qt::WindowFullScreen) {
                m_isFullScreen = true;
                emit isFullScreenChanged();
                showTitleBar();
            }
        });

    }

    Q_INVOKABLE void toggleFullScreen();

    Q_INVOKABLE void updatePosition() {
        auto point = QPoint(screen()->geometry().center().x() - geometry().width() / 2, screen()->geometry().center().y() - geometry().height() / 2);
        if (point != this->position()) {
            this->setPosition(point);
        }
    }

    bool isFullScreen() const;

signals:
    void isFullScreenChanged();

private:
    void removeTitleBar();
    void showTitleBar();
    void initCallbacks();

private:
    EventCallbacks m_callbacks;
    bool m_isFullScreen;
};

#endif // STATUSWINDOW_H
