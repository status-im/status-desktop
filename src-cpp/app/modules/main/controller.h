#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>

#include "interfaces/controller_interface.h"
#include "signals.h"

namespace Modules
{
namespace Main
{

class Controller : public QObject, IController
{
public:
    explicit Controller(QObject* parent = nullptr);
    ~Controller() = default;

    void init() override;
};

} // namespace Main
} // namespace Modules

#endif // CONTROLLER_H

