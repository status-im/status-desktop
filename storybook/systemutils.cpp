#include "systemutils.h"

#include <QtGlobal>
#include <QDir>

SystemUtils::SystemUtils(QObject* parent)
    : QObject(parent)
{ }

QString SystemUtils::getEnvVar(const QString& varName)
{
    return qEnvironmentVariable(varName.toUtf8().constData(), "");
}

bool SystemUtils::removeDir(const QString& path)
{
    QDir dir(path);

    if(!dir.exists())
    {
        return false;
    }

    dir.setFilter(QDir::NoDotAndDotDot | QDir::Files | QDir::Dirs);
    QFileInfoList fileList = dir.entryInfoList();

    foreach(const QFileInfo& fileInfo, fileList)
    {
        if(fileInfo.isDir())
        {
            if(!removeDir(fileInfo.absoluteFilePath()))
            {
                return false;
            }
        }
        else
        {
            if(!QFile::remove(fileInfo.absoluteFilePath()))
            {
                return false;
            }
        }
    }

    return dir.rmdir(path);
}