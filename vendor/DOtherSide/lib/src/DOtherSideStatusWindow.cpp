#include "DOtherSide/DOtherSideStatusWindow.h"

#include <QLocalServer>
#include <QLocalSocket>
#include <QDir>
#include <QCryptographicHash>

StatusWindow::StatusWindow(QWindow *parent)
: QQuickWindow(parent),
  m_isFullScreen(false),
  m_localServer(new QLocalServer(this))
{
    checkSingleInstance();
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

StatusWindow::~StatusWindow()
{
    if (m_localServer->isListening()) {
        m_localServer->close();
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

void StatusWindow::checkSingleInstance()
{
    const auto currentDir = QDir::currentPath();
    auto socketName = QString(QCryptographicHash::hash(currentDir.toUtf8(), QCryptographicHash::Md5).toHex());

#ifndef Q_OS_WIN
    socketName = QString("/tmp/%1").arg(socketName);
#endif

    QLocalSocket localSocket;
    localSocket.connectToServer(socketName);

    // the first instance start will be delayed by this timeout (ms) to ensure there are no other instances.
    // note: this is an ad-hoc timeout value selected based on prior experience.
    const bool connected = localSocket.waitForConnected(100);
    if (!connected) {
        connect(m_localServer, &QLocalServer::newConnection, this, &StatusWindow::secondInstanceDetected);
        if (!m_localServer->listen(socketName)) {
            qWarning() << "QLocalServer::listen(" << socketName << ") failed";
        }
    } else {
        qFatal("Terminating app as the second running instance...");
    }
}
