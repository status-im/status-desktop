#pragma once

#include <QObject>
#include <QtQmlIntegration>

#include <filesystem>

namespace Status::ApplicationCore {

namespace fs = std::filesystem;

class UserConfiguration: public QObject
{
    Q_OBJECT
    QML_ELEMENT

    // Not sure why `qmlUserDataFolder` is writable??? We should not change it from the qml side.
    // Even from the backend side this will be set only on the app start, and it will contain
    // necessary data for each created account, so even we're switching accounts, this will be the same path.
    Q_PROPERTY(QString userDataFolder READ qmlUserDataFolder WRITE setUserDataFolder NOTIFY userDataFolderChanged)

public:
    explicit UserConfiguration(QObject *parent = nullptr);

    const QString qmlUserDataFolder() const;
    const fs::path &userDataFolder() const;
    void setUserDataFolder(const QString &newUserDataFolder);

signals:
    void userDataFolderChanged();

private:
    void generateReleaseConfiguration();

    fs::path m_userDataFolder;
};

}
