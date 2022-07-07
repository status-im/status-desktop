#include "SignalsManager.h"

#include <QtConcurrent>

#include <libstatus.h>

using namespace std::string_literals;

namespace Status::StatusGo {

std::map<std::string, SignalType> SignalsManager::signalMap;

// TODO: make me thread safe or better refactor into broadcasting mechanism
SignalsManager* SignalsManager::instance()
{
    static SignalsManager manager;
    return &manager;
}

SignalsManager::SignalsManager()
    : QObject(nullptr)
{
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

        {"mailserver.changed"s, SignalType::MailserverChanged},
        {"mailserver.available"s, SignalType::MailserverAvailable},

        {"history.request.started"s, SignalType::HistoryRequestStarted},
        {"history.request.batch.processed"s, SignalType::HistoryRequestBatchProcessed},
        {"history.request.completed"s, SignalType::HistoryRequestCompleted}
    };
}

SignalsManager::~SignalsManager()
{
}

void SignalsManager::processSignal(const QString& statusSignal)
{
    try
    {
        QJsonParseError json_error;
        const QJsonDocument signalEventDoc(QJsonDocument::fromJson(statusSignal.toUtf8(), &json_error));
        if(json_error.error != QJsonParseError::NoError)
        {
            qWarning() << "Invalid signal received";
            return;
        }
        decode(signalEventDoc.object());
    }
    catch(const std::exception& e)
    {
        qWarning() << "Error decoding signal, err: ", e.what();
        return;
    }
}

void SignalsManager::decode(const QJsonObject& signalEvent)
{
    SignalType signalType(Unknown);
    auto signalName = signalEvent["type"].toString().toStdString();
    if(!signalMap.contains(signalName))
    {
        qWarning() << "Unknown signal received: " << signalName.c_str();
        return;
    }

    signalType = signalMap[signalName];
    auto signalError = signalEvent["event"]["error"].toString();

    switch(signalType)
    {
    // TODO: create extractor functions like in nim
    case NodeLogin:
        emit nodeLogin(signalError);
        break;
    case NodeReady:
        emit nodeReady(signalError);
        break;
    case NodeStarted:
        emit nodeStarted(signalError);
        break;
    case NodeStopped:
        emit nodeStopped(signalError);
        break;
    case NodeCrashed:
        qWarning() << "node.crashed, error: " << signalError;
        emit nodeCrashed(signalError);
        break;
    case DiscoveryStarted:
        emit discoveryStarted(signalError);
        break;
    case DiscoveryStopped:
        emit discoveryStopped(signalError);
        break;
    case DiscoverySummary:
        emit discoverySummary(signalEvent["event"].toArray().count(), signalError);
        break;
    case MailserverChanged:
        emit mailserverChanged(signalError);
        break;
    case MailserverAvailable:
        emit mailserverAvailable(signalError);
        break;
    case HistoryRequestStarted:
        emit historyRequestStarted(signalError);
        break;
    case HistoryRequestBatchProcessed:
        emit historyRequestBatchProcessed(signalError);
        break;
    case HistoryRequestCompleted:
        emit historyRequestCompleted(signalError);
        break;
    case Unknown: assert(false); break;
    }
}

void SignalsManager::signalCallback(const char* data)
{
    // TODO: overkill, use some kind of message broker
    auto dataStrPtr = std::make_shared<QString>(data);
    QFuture<void> future = QtConcurrent::run([dataStrPtr](){
        SignalsManager::instance()->processSignal(*dataStrPtr);
    });
}

}
