#include "LocalAppSettings.h"

#include "../Common/Utils.h"
#include "../Common/Constants.h"

using namespace Status;

LocalAppSettings& LocalAppSettings::instance()
{
    static LocalAppSettings laSettings;

    return laSettings;
}

LocalAppSettings::LocalAppSettings()
{
    if(!settings)
    {
        auto filePath = Utils::qtDataDir() + QDir::separator() + Constants::GlobalSettingsFileName;
        settings.reset(new QSettings(filePath, QSettings::IniFormat));
    }
}

LocalAppSettings::~LocalAppSettings()
{
}

bool LocalAppSettings::containsKey(const QString& key)
{
    return LocalAppSettings::instance().settings->contains(key);
}

void LocalAppSettings::removeKey(const QString& key)
{
    LocalAppSettings::instance().settings->remove(key);
}

QVariant LocalAppSettingsKeys::getDefaultValue(const QString& key) {
    static QMap<QString, QVariant> defaults;
    if (defaults.isEmpty())
    {
        defaults.insert(locale, "en");
        defaults.insert(theme, 2);
        defaults.insert(appWidth, 1232);
        defaults.insert(appHeight, 770);
        defaults.insert(appSizeInitialized, false);
    }

    return defaults.value(key);
}
