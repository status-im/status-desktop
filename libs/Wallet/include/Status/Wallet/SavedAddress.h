#pragma once

#include <QtQmlIntegration>

namespace Status::Wallet
{
class SavedAddress : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("C++ only")

    Q_PROPERTY(QString address READ address CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)

public:
    SavedAddress(const QString& address = QString(), const QString& name = QString(), QObject *parent = nullptr);

    const QString& address() const;
    const QString& name() const;

private:
    const QString m_address;
    const QString m_name;
};
}
