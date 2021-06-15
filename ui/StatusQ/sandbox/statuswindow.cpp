#include "statuswindow.h"

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

}

void StatusWindow::showTitleBar()
{

}
