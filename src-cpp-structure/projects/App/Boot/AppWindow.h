#pragma once

#include <QtQuick>

namespace Status
{
    class AppWindow: public QQuickWindow
    {
        Q_OBJECT

        /***********************************************
         *  Not Refactored, Just Taken From DOtherSide
         ***********************************************/

        Q_PROPERTY(bool isFullScreen READ isFullScreen NOTIFY isFullScreenChanged)

    public:

        explicit AppWindow(QWindow *parent = nullptr);

        Q_INVOKABLE void toggleFullScreen();

        bool isFullScreen() const;

        Q_INVOKABLE void updatePosition() {
            auto point = QPoint(screen()->geometry().center().x() - geometry().width() / 2,
                                screen()->geometry().center().y() - geometry().height() / 2);
            if (point != this->position()) {
                this->setPosition(point);
            }
        }

    signals:
        void isFullScreenChanged();
        void secondInstanceDetected();

    private:
        void initCallbacks();
        void removeTitleBar();
        void showTitleBar();
#ifdef Q_OS_MACOS
        void removeTitleBarMacOs();
        void showTitleBarMacOs();
#endif

    private:
        bool m_isFullScreen;
    };
}
