#pragma once

#include <QObject>
#include <QString>

class QJSEngine;
class QQmlEngine;

class StringUtilsInternal : public QObject
{
    Q_OBJECT

public:
    explicit StringUtilsInternal(QQmlEngine* engine, QObject* parent = nullptr);

    Q_INVOKABLE QString escapeHtml(const QString& unsafe) const;

    Q_INVOKABLE QString readTextFile(const QString& filePath) const;

    Q_INVOKABLE QString extractDomainFromLink(const QString& link) const;

private:
    QQmlEngine* m_engine{nullptr};
};
