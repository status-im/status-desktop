#pragma once

#include <QtCore/QtCore>
#include <StatusGo/SettingsAPI>

namespace Status::Application
{

class DataProvider : public QObject
{
    Q_OBJECT

public:
    DataProvider();

    StatusGo::Settings::SettingsDto getSettings() const;
};
} // namespace Status::Application
