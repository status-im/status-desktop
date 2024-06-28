#include "StatusDesktop/Monitoring/Monitor.h"

#include <QCoreApplication>
#include <QDebug>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSet>

void Monitor::initialize(QQmlApplicationEngine* engine)
{
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

ContextPropertiesModel* Monitor::contexPropertiesModel()
{
    return &m_contexPropertiesModel;
}

void Monitor::addContextPropertyName(const QString &contextPropertyName)
{
    m_contexPropertiesModel.addContextProperty(contextPropertyName);
}

bool Monitor::isModel(const QVariant &obj) const
{
    if (!obj.canConvert<QObject*>())
        return false;

    return qobject_cast<QAbstractItemModel*>(obj.value<QObject*>()) != nullptr;
}

QObject* Monitor::findChild(QObject* parent, const QString& name) const
{
    if (!parent)
        return nullptr;

    QSet<QObject*> children(parent->children().cbegin(),
                            parent->children().cend());

    if (auto quickItem = qobject_cast<QQuickItem*>(parent)) {
        QList<QQuickItem*> visualChildren = quickItem->childItems();

        for (auto c : visualChildren)
            children << c;
    }

    for (auto c : qAsConst(children)) {
        if (c->objectName() == name)
            return c;
    }

    for (auto c : qAsConst(children)) {
        auto obj = findChild(c, name);

        if (obj)
            return obj;
    }

    return nullptr;
}

QString Monitor::typeName(const QVariant &obj) const
{
    if (obj.canConvert<QObject*>())
        return obj.value<QObject*>()->metaObject()->className();

    return QString::fromUtf8(obj.typeName());
}

QJSValue Monitor::modelRoles(QAbstractItemModel *model) const
{
    if (model == nullptr)
        return {};

    QJSEngine *engine = qjsEngine(this);

    if (engine == nullptr)
        return {};

    const auto& roleNames = model->roleNames();

    QJSValue array = engine->newArray(roleNames.size());
    QList<int> keys = roleNames.keys();

    for (auto i = 0; i < keys.size(); i++) {
        QJSValue item = engine->newObject();

        auto key = keys.at(i);
        item.setProperty(QStringLiteral("key"), key);
        item.setProperty(QStringLiteral("name"),
                         QString::fromUtf8(roleNames[key]));

        array.setProperty(i, item);
    }

    return array;
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
