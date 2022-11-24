#pragma once

#include <QObject>
#include <QString>
#include <QQmlEngine>
#include <QJSEngine>

class QClipboardProxy : public QObject
{
    Q_OBJECT

    Q_DISABLE_COPY(QClipboardProxy)
    Q_PROPERTY(QString text READ text NOTIFY textChanged)

    QClipboardProxy();

public:
    QString text() const;

    static QObject *qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
    {
        Q_UNUSED(engine);
        Q_UNUSED(scriptEngine);

        return new QClipboardProxy;
    }

signals:
    void textChanged();
};
