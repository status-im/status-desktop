#include "SignalsManager.h"
#include "StatusGoEvent.h"

#include <QtConcurrent>

#include <libstatus.h>

#include <chrono>
#include <thread>

using json = nlohmann::json;

using namespace std::string_literals;

namespace Status::StatusGo
{

std::map<std::string, SignalType> SignalsManager::signalMap;

EventData::EventData(nlohmann::json eventInfo, bool error)
    : m_eventInfo(std::move(eventInfo))
    , m_hasError(error)
{ }

// TODO: make me thread safe or better refactor into broadcasting mechanism
SignalsManager* SignalsManager::instance()
{
    static SignalsManager manager;
    return &manager;
}

SignalsManager::SignalsManager()
    : QObject(nullptr)
{
    // Don't allow async signal processing in attept to debug the the linux running tests issue
    m_threadPool.setMaxThreadCount(1);

    SetSignalEventCallback((void*)&SignalsManager::signalCallback);

    signalMap = {
        {"node.ready"s, SignalType::NodeReady},
        {"node.started"s, SignalType::NodeStarted},
        {"node.stopped"s, SignalType::NodeStopped},
        {"node.login"s, SignalType::NodeLogin},
        {"node.crashed"s, SignalType::NodeCrashed},

        {"discovery.started"s, SignalType::DiscoveryStarted},
        {"discovery.stopped"s, SignalType::DiscoveryStopped},
        {"discovery.summary"s, SignalType::DiscoverySummary},

        {"mediaserver.started"s, SignalType::MailserverStarted},
        {"mailserver.changed"s, SignalType::MailserverChanged},
        {"mailserver.available"s, SignalType::MailserverAvailable},

        {"history.request.started"s, SignalType::HistoryRequestStarted},
        {"history.request.batch.processed"s, SignalType::HistoryRequestBatchProcessed},
        {"history.request.completed"s, SignalType::HistoryRequestCompleted},

        {"wallet"s, SignalType::WalletEvent},
    };
}

SignalsManager::~SignalsManager() { }

void SignalsManager::processSignal(const char* statusSignalData)
{
    // TODO: overkill, use some kind of message broker
    using namespace std::chrono_literals;
    auto dataStrPtr = std::make_shared<std::string>(statusSignalData);
    m_threadPool.start(QRunnable::create([dataStrPtr, this]() {
        try
        {
            StatusGoEvent event = json::parse(*dataStrPtr);
            if(event.error != std::nullopt)
            {
                qWarning() << "Error in signal" << event.type.c_str() << "; error" << event.error.value();
                // TODO report event error
                return;
            }

            QString signalError;
            if(event.event.contains("error")) signalError = event.event["error"].get<QString>();

            dispatch(event.type, std::move(event.event), signalError);
        }
        catch(const std::exception& e)
        {
            qWarning() << "Error decoding signal, err: " << e.what() << "; signal data: " << dataStrPtr->c_str();
        }
    }));
}

void SignalsManager::dispatch(const std::string& type, json signalEvent, const QString& signalError)
{
    SignalType signalType(Unknown);
    if(!signalMap.contains(type))
    {
        qWarning() << "Unknown signal received: " << type.c_str();
        return;
    }

    signalType = signalMap[type];
    switch(signalType)
    {
    // TODO: create extractor functions like in nim
    case NodeLogin: emit nodeLogin(signalError); break;
    case NodeReady: emit nodeReady(signalError); break;
    case NodeStarted: emit nodeStarted(signalError); break;
    case NodeStopped: emit nodeStopped(signalError); break;
    case NodeCrashed:
        qWarning() << "node.crashed, error: " << signalError;
        emit nodeCrashed(signalError);
        break;
    case DiscoveryStarted: emit discoveryStarted(signalError); break;
    case DiscoveryStopped: emit discoveryStopped(signalError); break;
    case DiscoverySummary: emit discoverySummary(signalEvent.array().size(), signalError); break;
    case MailserverStarted: emit mailserverStarted(signalError); break;
    case MailserverChanged: emit mailserverChanged(signalError); break;
    case MailserverAvailable: emit mailserverAvailable(signalError); break;
    case HistoryRequestStarted: emit historyRequestStarted(signalError); break;
    case HistoryRequestBatchProcessed: emit historyRequestBatchProcessed(signalError); break;
    case HistoryRequestCompleted: emit historyRequestCompleted(signalError); break;
    case WalletEvent: emit wallet(EventDataQPtr(new EventData(std::move(signalEvent), false))); break;
    case Unknown: assert(false); break;
    }
}

void SignalsManager::signalCallback(const char* data)
{
    SignalsManager::instance()->processSignal(data);
}

} // namespace Status::StatusGo
