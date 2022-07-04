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
