#include "DOtherSide/DOtherSideStatusWindow.h"

StatusWindow::StatusWindow(QWindow *parent)
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
