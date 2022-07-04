#pragma once

#include <QObject>

namespace Status::StatusGo {

enum SignalType
{
    Unknown,
    NodeLogin,
    NodeReady,
    NodeStarted,
    NodeStopped,
    NodeCrashed,

    DiscoveryStarted,
    DiscoveryStopped,
    DiscoverySummary,

    MailserverChanged,
    MailserverAvailable,

    HistoryRequestStarted,
    HistoryRequestBatchProcessed,
    HistoryRequestCompleted
};

/*!
    \todo refactor into a message broker helper to be used by specific service APIs to deliver signals
        as part of the specific StatusGoAPI service
    \todo address thread safety
 */
class SignalsManager final : public QObject
{
    Q_OBJECT

public:

    static SignalsManager* instance();

    void processSignal(const QString& ev);

signals:
    void nodeReady(const QString& error);
    void nodeStarted(const QString& error);
    void nodeStopped(const QString& error);
    void nodeLogin(const QString& error);
    void nodeCrashed(const QString& error);

    void discoveryStarted(const QString& error);
    void discoveryStopped(const QString& error);
    void discoverySummary(size_t nodeCount, const QString& error);

    void mailserverChanged(const QString& error);
    void mailserverAvailable(const QString& error);

    void historyRequestStarted(const QString& error);
    void historyRequestBatchProcessed(const QString& error);
    void historyRequestCompleted(const QString& error);
private:
    explicit SignalsManager();
    ~SignalsManager();

private:
    static std::map<std::string, SignalType> signalMap;
    static void signalCallback(const char* data);
    void decode(const QJsonObject& signalEvent);
};

}
