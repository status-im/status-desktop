#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>

#include "interfaces/controller_interface.h"
#include "signals.h"

namespace Modules::Main
{

class Controller : public QObject, public IController
{
public:
    explicit Controller(QObject* parent = nullptr);
    ~Controller() = default;

    void init() override;
};

} // namespace Modules::Main

#endif // CONTROLLER_H
