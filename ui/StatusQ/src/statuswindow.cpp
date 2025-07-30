#include "StatusQ/statuswindow.h"

StatusWindow::StatusWindow(QWindow *parent)
    : QQuickWindow(parent)
{
}

void StatusWindow::restoreWindowState()
{
    setWindowStates(windowStates() & ~Qt::WindowMinimized);
}

void StatusWindow::toggleFullScreen()
{
    setWindowStates(windowStates() ^ Qt::WindowFullScreen);
}

void StatusWindow::toggleMinimize()
{
    setWindowStates(windowStates() ^ Qt::WindowMinimized);
}
