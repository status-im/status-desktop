#include "UserConfiguration.h"

#include "Helpers/conversions.h"

#include <filesystem>

namespace fs = std::filesystem;

namespace Status::ApplicationCore {

namespace {
    /// `status-go` data location
    constexpr auto dataSubfolder = "data";
}

UserConfiguration::UserConfiguration(QObject *parent)
    : QObject{parent}
{
    generateReleaseConfiguration();
}

const QString UserConfiguration::qmlUserDataFolder() const
{
    return toQString(m_userDataFolder.string());
}

const fs::path &UserConfiguration::userDataFolder() const
{
    return m_userDataFolder;
}

void UserConfiguration::setUserDataFolder(const QString &newUserDataFolder)
{
    auto newVal = Status::toPath(newUserDataFolder);
    if (m_userDataFolder.compare(newVal) == 0)
        return;
    m_userDataFolder = newVal;
    emit userDataFolderChanged();
}

void UserConfiguration::generateReleaseConfiguration()
{
    m_userDataFolder = toPath(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation))/dataSubfolder;
    emit userDataFolderChanged();
}

}
