#include "StatusQ/statuswindow.h"

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
