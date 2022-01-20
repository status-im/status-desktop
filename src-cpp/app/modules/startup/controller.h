#pragma once

#include "accounts/service_interface.h"
#include "controller_interface.h"
#include "interfaces/module_controller_delegate_interface.h"
#include "signals.h"
#include <QObject>

namespace Modules
{
namespace Startup
{

class Controller : public QObject, ControllerInterface
{
public:
	Controller(ModuleControllerDelegateInterface* delegate,
			   Accounts::ServiceInterface* accountsService,
			   QObject* parent = nullptr);
	void init() override;
	bool shouldStartWithOnboardingScreen() override;
	void onLogin(Signals::NodeSignal signal);
	void onNodeStopped(Signals::NodeSignal signal);
	void onNodeReady(Signals::NodeSignal signal);

private:
	Accounts::ServiceInterface* m_accountsService;
	ModuleControllerDelegateInterface* m_delegate;
};

} // namespace Startup
} // namespace Modules