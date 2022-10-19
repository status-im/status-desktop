#include "DbSettingsObj.h"

using namespace Status::Application;

DbSettingsObj::DbSettingsObj(StatusGo::Settings::SettingsDto rawData)
    : QObject(nullptr)
    , m_data(std::move(rawData))
{ }

QString DbSettingsObj::address() const
{
    return m_data.address;
}

void DbSettingsObj::setAddress(const QString& value)
{
    if(m_data.address == value) return;
    m_data.address = value;
    emit addressChanged();
}

QString DbSettingsObj::displayName() const
{
    return m_data.displayName;
}

void DbSettingsObj::setDisplayName(const QString& value)
{
    if(m_data.displayName == value) return;
    m_data.displayName = value;
    emit displayNameChanged();
}

QString DbSettingsObj::preferredName() const
{
    return m_data.preferredName;
}

void DbSettingsObj::setPreferredName(const QString& value)
{
    if(m_data.preferredName == value) return;
    m_data.preferredName = value;
    emit preferredNameChanged();
}

QString DbSettingsObj::keyUid() const
{
    return m_data.keyUid;
}

void DbSettingsObj::setKeyUid(const QString& value)
{
    if(m_data.keyUid == value) return;
    m_data.keyUid = value;
    emit keyUidChanged();
}

QString DbSettingsObj::publicKey() const
{
    return m_data.publicKey;
}

void DbSettingsObj::setPublicKey(const QString& value)
{
    if(m_data.publicKey == value) return;
    m_data.publicKey = value;
    emit publicKeyChanged();
}
