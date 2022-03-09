#include <QDebug>

#include "controller_main.h"

namespace Modules::Main
{
Controller::Controller(QObject* parent)
    : QObject(parent)
{ }

void Controller::init() { }

} // namespace Modules::Main
