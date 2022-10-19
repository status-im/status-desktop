#include "DataProvider.h"

using namespace Status::Application;

namespace StatusGo = Status::StatusGo;

DataProvider::DataProvider()
    : QObject(nullptr)
{ }

StatusGo::Settings::SettingsDto DataProvider::getSettings() const
{
    try
    {
        return StatusGo::Settings::getSettings();
    }
    catch(std::exception& e)
    {
        qWarning() << "DataProvider::getSettings, error: " << e.what();
    }
    catch(...)
    {
        qWarning() << "DataProvider::getSettings, unknown error";
    }
    return StatusGo::Settings::SettingsDto{};
}
