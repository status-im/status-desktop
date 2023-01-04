#pragma once

#include <QObject>

class QQmlApplicationEngine;
class QQmlEngine;
class QJSEngine;

class Monitor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList contexPropertiesNames READ getContextPropertiesNames
               NOTIFY contextPropertiesNamesChanged)

    Monitor() = default;

public:
    void initialize(QQmlApplicationEngine *engine);
    QStringList getContextPropertiesNames() const;
    void addContextPropertyName(const QString &contextPropertyName);

    static Monitor& instance();
    static QObject* qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine);
signals:
    void contextPropertiesNamesChanged();

private:
    QStringList m_contexPropertiesNames;
};
