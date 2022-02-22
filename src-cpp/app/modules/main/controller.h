#pragma once

#include <QObject>

#include "interfaces/controller_interface.h"
#include "signals.h"

namespace Modules::Main
{

class Controller : public QObject, public IController
{
public:
    using QObject::QObject;

    void init() override;
};

} // namespace Modules::Main
