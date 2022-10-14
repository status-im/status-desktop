#pragma once

#include <QObject>
#include <QThreadPool>

#include <nlohmann/json.hpp>

namespace Status::StatusGo
{

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

    MailserverStarted,
    MailserverChanged,
    MailserverAvailable,

    HistoryRequestStarted,
    HistoryRequestBatchProcessed,
    HistoryRequestCompleted,

    WalletEvent
};

class EventData final : public QObject
{
    Q_OBJECT

public:
    explicit EventData(nlohmann::json eventInfo, bool error);

    const nlohmann::json& eventInfo() const
    {
        return m_eventInfo;
    };

private:
    nlohmann::json m_eventInfo;
    bool m_hasError;
};

using EventDataQPtr = QSharedPointer<Status::StatusGo::EventData>;

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

    void processSignal(const char* statusSignalData);

signals:
    // TODO: move all signals to deliver EventData, distributing this way data processing to the consumer
    void nodeReady(const QString& error);
    void nodeStarted(const QString& error);
    void nodeStopped(const QString& error);
    void nodeLogin(const QString& error);
    void nodeCrashed(const QString& error);

    void discoveryStarted(const QString& error);
    void discoveryStopped(const QString& error);
    void discoverySummary(size_t nodeCount, const QString& error);

    void mailserverStarted(const QString& error);
    void mailserverChanged(const QString& error);
    void mailserverAvailable(const QString& error);

    void historyRequestStarted(const QString& error);
    void historyRequestBatchProcessed(const QString& error);
    void historyRequestCompleted(const QString& error);

    void wallet(QSharedPointer<Status::StatusGo::EventData> eventData);

private:
    explicit SignalsManager();
    ~SignalsManager();

private:
    static std::map<std::string, SignalType> signalMap;
    static void signalCallback(const char* data);

    void dispatch(const std::string& type, nlohmann::json signalEvent, const QString& signalError);

    QThreadPool m_threadPool;
};

} // namespace Status::StatusGo
