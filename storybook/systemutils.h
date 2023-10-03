#pragma once

#include <QObject>
#include <QString>

class SystemUtils : public QObject
{
    Q_OBJECT
public:
    explicit SystemUtils(QObject *parent = nullptr);

    Q_INVOKABLE QString getEnvVar(const QString &varName);
};
