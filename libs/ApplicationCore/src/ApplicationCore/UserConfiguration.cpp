#include "UserConfiguration.h"

#include "Helpers/conversions.h"

#include <QCommandLineParser>

#include <filesystem>

namespace fs = std::filesystem;

namespace Status::ApplicationCore {

namespace {
    constexpr auto statusFolder = "Status";
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
    if(!parseFromCommandLineAndReturnTrueIfSet())
        m_userDataFolder = toPath(QStandardPaths::writableLocation(QStandardPaths::RuntimeLocation))/statusFolder/dataSubfolder;
    emit userDataFolderChanged();
}

bool UserConfiguration::parseFromCommandLineAndReturnTrueIfSet()
{
    QCommandLineParser parser;
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addPositionalArgument("dataDir", "Data folder");
    parser.process(*QCoreApplication::instance());
    auto args = parser.positionalArguments();
    if (args.size() > 0) {
        m_userDataFolder = toPath(args[0]);
        emit userDataFolderChanged();
        return true;
    }
    return false;
}

}
