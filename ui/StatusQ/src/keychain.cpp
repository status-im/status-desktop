#include "StatusQ/keychain.h"

#include <QDebug>

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
