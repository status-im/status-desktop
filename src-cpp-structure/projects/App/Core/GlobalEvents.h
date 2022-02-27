#pragma once

#include <QtCore>

namespace Status
{
    class GlobalEvents final : public QObject
    {
        Q_OBJECT

    public:

        static GlobalEvents& instance();

    private:
        explicit GlobalEvents();
        ~GlobalEvents();

    signals:
        void nodeReady(const QString& error);
        void nodeStarted(const QString& error);
        void nodeStopped(const QString& error);
        void nodeLogin(const QString& error);
        void nodeCrashed(const QString& error);
    };
}
