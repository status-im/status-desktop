#pragma once

#include <QObject>
#include <QtQmlIntegration>

#include <filesystem>

namespace Status::ApplicationCore
{

namespace fs = std::filesystem;

/// Contains necessary data for each created account hence this will be the same path for all accounts
class UserConfiguration : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    /// @note userFolder is writable in order to allow changing it in tests until a proper abstraction is in place
    Q_PROPERTY(QString userDataFolder READ qmlUserDataFolder WRITE setUserDataFolder NOTIFY userDataFolderChanged)

public:
    explicit UserConfiguration(QObject* parent = nullptr);

    const QString qmlUserDataFolder() const;
    const fs::path& userDataFolder() const;
    void setUserDataFolder(const QString& newUserDataFolder);

signals:
    void userDataFolderChanged();

private:
    void generateReleaseConfiguration();
    bool parseFromCommandLineAndReturnTrueIfSet();

    fs::path m_userDataFolder;
};

} // namespace Status::ApplicationCore
