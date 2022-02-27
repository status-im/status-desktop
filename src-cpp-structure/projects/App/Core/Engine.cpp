#include "Engine.h"

using namespace Status;

Engine* Engine::instance()
{
    static auto* engine = new Engine();
    return engine;
}

Engine::Engine()
    : QQmlApplicationEngine(nullptr)
{
}

Engine::~Engine()
{
}

std::shared_ptr<QQmlComponent> Engine::load(const QString& qmlFile)
{
    return std::shared_ptr<QQmlComponent>(new QQmlComponent(instance(), qmlFile, QQmlComponent::Asynchronous));
}

void Engine::create(const QString& qmlFile, QQmlContext* context)
{
    QObject* createdObj = nullptr;
    auto component = Engine::load(qmlFile);
    const auto status = component->status();

    if (status == QQmlComponent::Ready)
    {
        createdObj = component->create();
        emit instance()->objectCreated(createdObj, qmlFile);
    }
    else if (status == QQmlComponent::Loading)
    {
        const auto create = [c = component, f = qmlFile](const QQmlComponent::Status status) mutable
        {
            if (status == QQmlComponent::Loading)
            {
                return;
            }

            if (status == QQmlComponent::Ready)
            {
                emit instance()->objectCreated(c->create(), f);
            }
            else if (status == QQmlComponent::Null || status == QQmlComponent::Error)
            {
                emit instance()->objectCreated(nullptr, f);
            }
        };
        QObject::connect(component.get(), &QQmlComponent::statusChanged, create);
    }
    else
    {
        emit instance()->objectCreated(createdObj, qmlFile);
    }
}
