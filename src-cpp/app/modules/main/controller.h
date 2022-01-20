#pragma once

#include "controller_interface.h"
#include "interfaces/module_controller_delegate_interface.h"
#include "signals.h"
#include <QObject>

namespace Modules
{
namespace Main
{

class Controller : public QObject, ControllerInterface
{
public:
	Controller(ModuleControllerDelegateInterface* delegate, QObject* parent = nullptr);
	void init() override;

private:
	ModuleControllerDelegateInterface* m_delegate;
};

} // namespace Main
} // namespace Modules