#pragma once

#include <QObject>
#include <QString>
#include <QVariant>
#include <QVariantList>

namespace Signals
{
Q_NAMESPACE

enum SignalType
{
    Unknown,
    NodeLogin,
    NodeReady,
    NodeStarted,
    NodeStopped,
    NodeCrashed
};

Q_ENUM_NS(SignalType)

struct Signal
{
    SignalType signalType;
};

struct NodeSignal : Signal
{
    QString error;
};

class Manager : public QObject
{
    Q_OBJECT

public:
    static Manager* instance();

signals:
    void signal(SignalType signal);

    void nodeReady(NodeSignal signal);
    void nodeStarted(NodeSignal signal);
    void nodeStopped(NodeSignal signal);
    void nodeLogin(NodeSignal signal);
    void nodeCrashed(NodeSignal signal);

private:
    explicit Manager(QObject* parent = nullptr);
    static std::map<QString, SignalType> signalMap;
    static void signalCallback(const char* data);
    void processSignal(QString ev);
    void decode(const QJsonObject& signalEvent);
};

} // namespace Signals

Q_DECLARE_METATYPE(Signals::Signal)
Q_DECLARE_METATYPE(Signals::NodeSignal)
