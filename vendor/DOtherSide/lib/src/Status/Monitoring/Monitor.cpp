#include "DOtherSide/Status/Monitoring/Monitor.h"

#include <QCoreApplication>
#include <QDebug>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQuickWindow>

void Monitor::initialize(QQmlApplicationEngine* engine) {
    QObject::connect(engine, &QQmlApplicationEngine::objectCreated, this,
                     [engine](QObject *obj, const QUrl &objUrl) {
        if (!obj) {
            qWarning() << "Error while loading QML:" << objUrl << "."
                       << "Monitor initialization failed.";
            return;
        }

        QQuickWindow* window = qobject_cast<QQuickWindow*>(obj);
        QQmlComponent cmp(engine, QCoreApplication::applicationDirPath()
                          + QStringLiteral(MONITORING_QML_ENTRY_POINT), window);

        cmp.create(qmlContext(window));

        if (cmp.isError()) {
            qWarning() << "Failed to instantiate monitoring utilities:";
            qWarning() << cmp.errors();
        }
    }, Qt::QueuedConnection);
}

QStringList Monitor::getContextPropertiesNames() const
{
    return m_contexPropertiesNames;
}

void Monitor::addContextPropertyName(const QString &contextPropertyName)
{
    if (m_contexPropertiesNames.contains(contextPropertyName))
        return;

    m_contexPropertiesNames << contextPropertyName;
    emit contextPropertiesNamesChanged();
}

Monitor& Monitor::instance()
{
    static Monitor monitor;
    return monitor;
}

QObject* Monitor::qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    auto& inst = instance();
    engine->setObjectOwnership(&inst, QQmlEngine::CppOwnership);

    return &inst;
}
