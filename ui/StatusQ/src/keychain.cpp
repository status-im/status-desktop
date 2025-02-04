#include "StatusQ/keychain.h"

#include <QDebug>

Keychain::Keychain(QObject *parent) : QObject(parent)
{}

QString Keychain::service() const
{
    return m_service;
}

void Keychain::setService(const QString &service)
{
    if (m_service == service)
        return;

    m_service = service;
    emit serviceChanged();
}

QString Keychain::reason() const
{
    return m_reason;
}

void Keychain::setReason(const QString &reason)
{
    if (m_reason == reason)
        return;

    m_reason = reason;
    emit reasonChanged();
}

bool Keychain::loading() const
{
    return m_loading;
}

void Keychain::setLoading(bool loading)
{
    if (m_loading == loading)
        return;

    m_loading = loading;
    emit loadingChanged();
}
