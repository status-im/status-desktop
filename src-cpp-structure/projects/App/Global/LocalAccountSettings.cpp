#include "LocalAccountSettings.h"

#include "../Common/Utils.h"

using namespace Status;

LocalAccountSettings& LocalAccountSettings::instance()
{
    static LocalAccountSettings laSettings;

    return laSettings;
}

LocalAccountSettings::LocalAccountSettings()
{
}

LocalAccountSettings::~LocalAccountSettings()
{
}

void LocalAccountSettings::setFileName(const QString& fileName)
{
    auto filePath = Utils::qtDataDir() + QDir::separator() + fileName;
    LocalAccountSettings::instance().settings.reset(new QSettings(filePath, QSettings::IniFormat));
}

bool LocalAccountSettings::containsKey(const QString& key)
{
    return LocalAccountSettings::instance().settings->contains(key);
}

void LocalAccountSettings::removeKey(const QString& key)
{
    LocalAccountSettings::instance().settings->remove(key);
}

QVariant LocalAccountSettingsKeys::getDefaultValue(const QString& key) {
    static QMap<QString, QVariant> defaults;
    if (defaults.isEmpty())
    {
        defaults.insert(storeToKeychain, LocalAccountSettingsPossibleValues::StoreToKeychain::NotNow);
        defaults.insert(isKeycardEnabled, false);
    }

    return defaults.value(key);
}
