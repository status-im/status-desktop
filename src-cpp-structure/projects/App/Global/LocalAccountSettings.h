#pragma once

#include "SettingsProperties.h"

#include <QtCore>

namespace Status
{
    namespace LocalAccountSettingsKeys {
        const QString storeToKeychain = "storeToKeychain";
        const QString isKeycardEnabled = "isKeycardEnabled";

        QVariant getDefaultValue(const QString& key);
    }

    namespace LocalAccountSettingsPossibleValues {
        namespace StoreToKeychain {
            const QString Store = "store";
            const QString NotNow = "notNow";
            const QString Never = "never";
        }
    }

    class LocalAccountSettings final : public QObject
    {
        Q_OBJECT

    public:

        static LocalAccountSettings& instance();

        void setFileName(const QString& fileName);
        bool containsKey(const QString& key);
        void removeKey(const QString& key);

        REGISTER_RW_PROPERTY(LocalAccountSettings, LocalAccountSettingsKeys, isKeycardEnabled, bool)
        REGISTER_RW_PROPERTY(LocalAccountSettings, LocalAccountSettingsKeys, storeToKeychain, QString)

    private:
        explicit LocalAccountSettings();
        ~LocalAccountSettings();

        std::unique_ptr<QSettings> settings;
    };
}
