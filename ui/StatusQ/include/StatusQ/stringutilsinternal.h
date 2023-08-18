#pragma once

#include <QObject>
#include <QString>

class QJSEngine;
class QQmlEngine;

class StringUtilsInternal : public QObject
{
    Q_OBJECT

public:
    explicit StringUtilsInternal(QObject* parent = nullptr);

    Q_INVOKABLE QString escapeHtml(const QString &unsafe) const;

    static QObject* qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine);
};
