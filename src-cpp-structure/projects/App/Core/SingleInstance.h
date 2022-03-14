#pragma once

#include <QtCore>

class QLocalServer;

namespace Status {

    class SingleInstance : public QObject
    {
        Q_OBJECT

    public:
        // uniqueName - the name of named pipe
        // eventStr - optional event to send if another instance is detected
        explicit SingleInstance(const QString& uniqueName, const QString& eventStr, QObject* parent = nullptr);
        ~SingleInstance() override;

        bool isFirstInstance() const;

    signals:
        void secondInstanceDetected();
        void eventReceived(const QString& eventStr);

    private slots:
        void handleNewConnection();

    private:
        QLocalServer* m_localServer;
    };
}
