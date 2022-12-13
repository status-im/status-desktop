#pragma once
#include <QObject>

class QQmlEngine;
class QJSEngine;

class TextUtils : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY_MOVE(TextUtils)
public:
    static QObject *qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine);

    Q_INVOKABLE QString htmlToPlainText(const QString& html);

private:
    TextUtils(QObject *parent = nullptr);
};
