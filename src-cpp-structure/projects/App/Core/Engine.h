#pragma once

#include <QtQml>

namespace Status
{
    class Engine final : public QQmlApplicationEngine
    {
        Q_OBJECT

    public:

        static Engine* instance();

        // Methos here are just a concept how we can have a single engine instance shared accross the app
        // and use it for async instantiation for all qml files over the app. Also we can this way register
        // context only within a certain file, not globally.
        static std::shared_ptr<QQmlComponent> load(const QString& qmlFile);
        static void create(const QString& qmlFile, QQmlContext *context = nullptr);

    private:
        explicit Engine();
        ~Engine();
    };
}
