#include "AppWindow.h"

using namespace Status;

AppWindow::AppWindow(QWindow *parent)
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

void AppWindow::toggleFullScreen()
{
    if (m_isFullScreen) {
        showNormal();
    } else {
        showFullScreen();
    }
}

bool AppWindow::isFullScreen() const
{
    return m_isFullScreen;
}

void AppWindow::removeTitleBar()
{
#ifdef Q_OS_MACOS
    removeTitleBarMacOs();
#endif
}

void AppWindow::showTitleBar()
{
#ifdef Q_OS_MACOS
    showTitleBarMacOs();
#endif
}
