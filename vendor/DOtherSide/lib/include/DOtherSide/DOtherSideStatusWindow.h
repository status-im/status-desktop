#ifndef STATUSWINDOW_H
#define STATUSWINDOW_H

#include <QQuickWindow>
#include <QScreen>

class StatusWindow: public QQuickWindow
{
    Q_OBJECT

    Q_PROPERTY(bool isFullScreen READ isFullScreen NOTIFY isFullScreenChanged)

public:

    explicit StatusWindow(QWindow *parent = nullptr);

    Q_INVOKABLE void toggleFullScreen();

    bool isFullScreen() const;

    Q_INVOKABLE void updatePosition() {
        auto point = QPoint(screen()->geometry().center().x() - geometry().width() / 2, screen()->geometry().center().y() - geometry().height() / 2);
        if (point != this->position()) {
            this->setPosition(point);
        }
    }

signals:
    void isFullScreenChanged();
    void secondInstanceDetected();

private:
    void removeTitleBar();
    void showTitleBar();
    void initCallbacks();

private:
    bool m_isFullScreen;
};

#endif // STATUSWINDOW_H
