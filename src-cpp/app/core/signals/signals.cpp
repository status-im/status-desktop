#include "signals.h"
#include "libstatus.h"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QObject>
#include <QtConcurrent>

namespace Signals
{

Manager* Manager::theInstance;

Manager* Manager::instance()
{
	if(theInstance == 0) theInstance = new Manager();
	return theInstance;
}

std::map<QString, SignalType> Manager::signalMap;

Manager::Manager(QObject* parent)
	: QObject(parent)
{
	SetSignalEventCallback((void*)&Manager::signalCallback);

	signalMap = {{"node.ready", SignalType::NodeReady},
				 {"node.started", SignalType::NodeStarted},
				 {"node.stopped", SignalType::NodeStopped},
				 {"node.login", SignalType::NodeLogin},
				 {"node.crashed", SignalType::NodeCrashed}};
}

void Manager::processSignal(QString statusSignal)
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

void Manager::decode(const QJsonObject& signalEvent)
{
	SignalType signalType(Unknown);
	if(!signalMap.count(signalEvent["type"].toString()))
	{
		qWarning() << "Unknown signal received: " << signalEvent["type"].toString();
		return;
	}

	signalType = signalMap[signalEvent["type"].toString()];

	switch(signalType)
	{
		// TODO: create extractor functions like in nim
	case NodeLogin: emit instance()->nodeLogin(NodeSignal{signalType, signalEvent["event"]["error"].toString()}); break;
	case NodeReady: emit instance()->nodeReady(NodeSignal{signalType, signalEvent["event"]["error"].toString()}); break;
	case NodeStarted:
		emit instance()->nodeStarted(NodeSignal{signalType, signalEvent["event"]["error"].toString()});
		break;
	case NodeStopped:
		emit instance()->nodeStopped(NodeSignal{signalType, signalEvent["event"]["error"].toString()});
		break;
	case NodeCrashed: {
		auto signal = NodeSignal{signalType, signalEvent["event"]["error"].toString()};
		qWarning() << "node.crashed, error: " << signal.error;
		emit instance()->nodeCrashed(signal);
		break;
	}
	default: qWarning() << "Signal decoding not implemented: " << signalEvent; break;
	}
}

void Manager::signalCallback(const char* data)
{
	QtConcurrent::run(instance(), &Manager::processSignal, QString(data));
}

} // namespace Signals