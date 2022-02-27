#pragma once

#include "SettingsProperties.h"

#include <QtCore>

namespace Status
{
    namespace LocalAppSettingsKeys {
        const QString locale = "global/locale";
        const QString theme = "global/theme";
        const QString appWidth = "global/app_width";
        const QString appHeight = "global/app_height";
        const QString appSizeInitialized = "global/app_size_initialized";

        QVariant getDefaultValue(const QString& key);
    }

    class LocalAppSettings final : public QObject
    {
        Q_OBJECT

    public:

        static LocalAppSettings& instance();

        bool containsKey(const QString& key);
        void removeKey(const QString& key);

        REGISTER_RW_PROPERTY(LocalAppSettings, LocalAppSettingsKeys, locale, QString)
        REGISTER_RW_PROPERTY(LocalAppSettings, LocalAppSettingsKeys, theme, int)
        REGISTER_RW_PROPERTY(LocalAppSettings, LocalAppSettingsKeys, appWidth, int)
        REGISTER_RW_PROPERTY(LocalAppSettings, LocalAppSettingsKeys, appHeight, int)
        REGISTER_RW_PROPERTY(LocalAppSettings, LocalAppSettingsKeys, appSizeInitialized, bool)

    private:
        explicit LocalAppSettings();
        ~LocalAppSettings();

        std::unique_ptr<QSettings> settings;
    };
}
