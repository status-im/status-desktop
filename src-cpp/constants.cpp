#include "constants.h"
#include <QDir>
#include <QFileInfo>
#include <QMessageBox>
#include <QStandardPaths>
#include <QString>

// TODO: merge with constants from backend/

QString Constants::applicationPath(const QString& path)
{
    return QFileInfo(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + path).absoluteFilePath();
}

QString Constants::tmpPath(const QString& path)
{
    return QFileInfo(QStandardPaths::writableLocation(QStandardPaths::TempLocation) + path).absoluteFilePath();
}

QString Constants::cachePath(const QString& path)
{
    return QFileInfo(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + path).absoluteFilePath();
}

bool Constants::ensureDirectories()
{
    if(Constants::applicationPath().isEmpty())
    {
        QDir d{Constants::applicationPath()};
        if(!d.mkpath(d.absolutePath()))
        {
            QMessageBox msgBox;
            msgBox.setIcon(QMessageBox::Warning);
            msgBox.setText("Cannot determine storage location");
            msgBox.exec();
            return false;
        }
    }
    return true;
}
