#pragma once

#include <StatusGo/SettingsAPI>
#include <QtCore/QtCore>

namespace Status::Application {

    class DataProvider: public QObject
    {
        Q_OBJECT

    public:
        DataProvider();

        StatusGo::Settings::SettingsDto getSettings() const;
    };
}
