#include "SignalsManager.h"

#include "GlobalEvents.h"
#include <QtConcurrent>

#include "libstatus.h"

using namespace Status;

std::map<QString, SignalType> SignalsManager::signalMap;

SignalsManager* SignalsManager::instance()
{
    static auto* manager = new SignalsManager();
    return manager;
}

SignalsManager::SignalsManager()
    : QObject(nullptr)
{
    SetSignalEventCallback((void*)&SignalsManager::signalCallback);

    signalMap = {
        {"node.ready", SignalType::NodeReady},
        {"node.started", SignalType::NodeStarted},
        {"node.stopped", SignalType::NodeStopped},
        {"node.login", SignalType::NodeLogin},
        {"node.crashed", SignalType::NodeCrashed}
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
    if(!signalMap.count(signalEvent["type"].toString()))
    {
        qWarning() << "Unknown signal received: " << signalEvent["type"].toString();
        return;
    }

    signalType = signalMap[signalEvent["type"].toString()];
    auto signalError = signalEvent["event"]["error"].toString();

    switch(signalType)
    {
    // TODO: create extractor functions like in nim
    case NodeLogin:
        emit GlobalEvents::instance().nodeLogin(signalError);
        break;
    case NodeReady:
        emit GlobalEvents::instance().nodeReady(signalError);
        break;
    case NodeStarted:
        emit GlobalEvents::instance().nodeStarted(signalError);
        break;
    case NodeStopped:
        emit GlobalEvents::instance().nodeStopped(signalError);
        break;
    case NodeCrashed: {
        qWarning() << "node.crashed, error: " << signalError;
        emit GlobalEvents::instance().nodeCrashed(signalError);
        break;
    }
    default:
        qWarning() << "Signal decoding not implemented: " << signalEvent;
}
}

void SignalsManager::signalCallback(const char* data)
{
    QtConcurrent::run(instance(), &SignalsManager::processSignal, QString(data));
}
