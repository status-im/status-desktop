#include "statuswindow.h"

StatusWindow::StatusWindow(QQuickWindow *parent)
    : QQuickWindow(parent)
    , m_isFullScreen(false)
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

void StatusWindow::updatePosition()
{
    auto point = QPoint(screen()->geometry().center().x() - geometry().width() / 2,
                        screen()->geometry().center().y() - geometry().height() / 2);
    if (point != this->position()) {
        this->setPosition(point);
    }
}

void StatusWindow::toggleFullScreen()
{
    if (m_isFullScreen) {
        showNormal();
    } else {
        showFullScreen();
    }
}

bool StatusWindow::isFullScreen() const
{
    return m_isFullScreen;
}

void StatusWindow::removeTitleBar()
{
#ifdef Q_OS_WIN
    removeTitleBarWin();
#elif defined Q_OS_MACOS
    removeTitleBarMac();
#endif
}

void StatusWindow::showTitleBar()
{
#ifdef Q_OS_WIN
    showTitleBarWin();
#elif defined Q_OS_MACOS
    showTitleBarMac();
#endif
}

#ifdef Q_OS_WIN
void StatusWindow::removeTitleBarWin()
{}

void StatusWindow::showTitleBarWin()
{}
#endif
