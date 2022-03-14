#include "SingleInstance.h"

#include <QtNetwork>

using namespace Status;

namespace {
    const int ReadWriteTimeoutMs = 1000;
}

SingleInstance::SingleInstance(const QString &uniqueName, const QString &eventStr, QObject *parent)
    : QObject(parent)
    , m_localServer(new QLocalServer(this))
{
    QString socketName = uniqueName;

#ifndef Q_OS_WIN
    socketName = QString("/tmp/%1").arg(socketName);
#endif

    QLocalSocket localSocket;
    localSocket.connectToServer(socketName);

    // the first instance start will be delayed by this timeout (ms) to ensure there are no other instances.
    // note: this is an ad-hoc timeout value selected based on prior experience.
    if (!localSocket.waitForConnected(100)) {
        connect(m_localServer, &QLocalServer::newConnection, this, &SingleInstance::handleNewConnection);
        // on *nix a crashed process will leave /tmp/xyz file preventing to start a new server.
        // therefore, if we were unable to connect, then we assume the server died and we need to clean up.
        // p.s. on Windows, this function does nothing.
        QLocalServer::removeServer(socketName);
        if (!m_localServer->listen(socketName)) {
            qWarning() << "QLocalServer::listen(" << socketName << ") failed";
        }
    } else if (!eventStr.isEmpty()) {
        localSocket.write(eventStr.toUtf8() + '\n');
        localSocket.waitForBytesWritten(ReadWriteTimeoutMs);
    }
}

SingleInstance::~SingleInstance()
{
    if (m_localServer->isListening()) {
        m_localServer->close();
    }
}

bool SingleInstance::isFirstInstance() const
{
    return m_localServer->isListening();
}

void SingleInstance::handleNewConnection()
{
    emit secondInstanceDetected();

    auto socket = m_localServer->nextPendingConnection();
    if (socket->waitForReadyRead(ReadWriteTimeoutMs) && socket->canReadLine()) {
        auto event = socket->readLine();
        emit eventReceived(QString::fromUtf8(event));
    }

    socket->deleteLater();
}
