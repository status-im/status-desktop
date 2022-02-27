#pragma once

#include <QtCore>

namespace Status
{
    enum SignalType
    {
        Unknown,
        NodeLogin,
        NodeReady,
        NodeStarted,
        NodeStopped,
        NodeCrashed
    };

    class SignalsManager final : public QObject
    {
        Q_OBJECT

    public:

        static SignalsManager* instance();

    private:
        explicit SignalsManager();
        ~SignalsManager();

    private:
        static std::map<QString, SignalType> signalMap;
        static void signalCallback(const char* data);
        void processSignal(const QString& ev);
        void decode(const QJsonObject& signalEvent);
    };

}
