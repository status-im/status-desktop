#include "controller.h"
#include "accounts/service_interface.h"
#include "interfaces/module_controller_delegate_interface.h"
#include <QDebug>

namespace Modules
{
namespace Main
{
Controller::Controller(ModuleControllerDelegateInterface* d, QObject* parent)
	: QObject(parent)
	, m_delegate(d)
{ }

void Controller::init() { }

} // namespace Main
} // namespace Modules