#include <QDebug>

#include "controller.h"

namespace Modules
{
namespace Main
{
Controller::Controller(QObject* parent)
    : QObject(parent)
{ }

void Controller::init() { }

} // namespace Main
} // namespace Modules
