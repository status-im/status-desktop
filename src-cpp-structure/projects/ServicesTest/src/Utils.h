#pragma once

#include "Constants.h"

#include <QtCore>

class Utils final {
public:

    static QString defaultDataDir()
    {
        auto d = QDir();
        if(STATUS_DEVELOPMENT){
            d = QDir(STATUS_SOURCE_DIR);
            d.cdUp();
        }
        else {
            // We should handle paths for different platforms here in case of non development
        }

        return d.absolutePath() + QDir::separator() + UserDataDirName;
    }

    static QString statusGoDataDir()
    {
        return defaultDataDir() + QDir::separator() + StatusGoDataDirName;
    }

    static QString keystoreDataDir()
    {
        return statusGoDataDir() + QDir::separator() + KeystoreDataDirName;
    }

    static QString tmpDataDir()
    {
        return defaultDataDir() + QDir::separator() + TmpDataDirName;
    }

    static QString logsDataDir()
    {
        return defaultDataDir() + QDir::separator() + LogsDataDirName;
    }

    static QString qtDataDir()
    {
        return defaultDataDir() + QDir::separator() + QtDataDirName;
    }

    static void ensureDirectories()
    {
        QDir d;
        d.mkpath(defaultDataDir());
        d.mkpath(statusGoDataDir());
        d.mkpath(keystoreDataDir());
        d.mkpath(tmpDataDir());
        d.mkpath(logsDataDir());
        d.mkpath(qtDataDir());
    }
};
