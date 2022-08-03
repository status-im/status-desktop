#pragma once

#include <StatusGo/SettingsAPI>

#include <QtCore/QtCore>

namespace Status::Application {

    class DbSettingsObj: public QObject
    {
        Q_OBJECT

        Q_PROPERTY(QString address READ address NOTIFY addressChanged)
        Q_PROPERTY(QString displayName READ displayName NOTIFY displayNameChanged)
        Q_PROPERTY(QString preferredName READ preferredName NOTIFY preferredNameChanged)
        Q_PROPERTY(QString keyUid READ keyUid NOTIFY keyUidChanged)
        Q_PROPERTY(QString publicKey READ publicKey NOTIFY publicKeyChanged)


    public:
        explicit DbSettingsObj(StatusGo::Settings::SettingsDto rawData);

        [[nodiscard]] QString address() const;
        void setAddress(const QString& address);

        [[nodiscard]] QString displayName() const;
        void setDisplayName(const QString& value);

        [[nodiscard]] QString preferredName() const;
        void setPreferredName(const QString& value);

        [[nodiscard]] QString keyUid() const;
        void setKeyUid(const QString& value);

        [[nodiscard]] QString publicKey() const;
        void setPublicKey(const QString& value);


    signals:
        void addressChanged();
        void displayNameChanged();
        void preferredNameChanged();
        void keyUidChanged();
        void publicKeyChanged();

    private:
        StatusGo::Settings::SettingsDto m_data;
    };
}
