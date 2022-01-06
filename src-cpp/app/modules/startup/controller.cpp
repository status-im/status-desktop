#include "controller.h"
#include "accounts/service_interface.h"
#include "interfaces/module_controller_delegate_interface.h"
#include "signals.h"
#include <QDebug>

namespace Modules
{
namespace Startup
{
Controller::Controller(ModuleControllerDelegateInterface* d,
					   Accounts::ServiceInterface* accountsService,
					   QObject* parent)
	: QObject(parent)
	, m_accountsService(accountsService)
	, m_delegate(d)
{ }

void Controller::init()
{
	QObject::connect(Signals::Manager::instance(), &Signals::Manager::nodeLogin, this, &Controller::onLogin);
	QObject::connect(Signals::Manager::instance(), &Signals::Manager::nodeStopped, this, &Controller::onNodeStopped);
	QObject::connect(Signals::Manager::instance(), &Signals::Manager::nodeReady, this, &Controller::onNodeReady);
}

void Controller::onLogin(Signals::NodeSignal signal)
{
	if(signal.error.isEmpty())
	{
		m_delegate->userLoggedIn();
	}
	else
	{
		qWarning() << "error: methodName=init, errDescription=login error " << signal.error;
	}
}

void Controller::onNodeStopped(Signals::NodeSignal signal)
{
	// self.events.emit("nodeStopped", Args())
	m_accountsService->clear();
	m_delegate->emitLogOut();
}

void Controller::onNodeReady(Signals::NodeSignal signal)
{
	// self.events.emit("nodeReady", Args())
}

bool Controller::shouldStartWithOnboardingScreen()
{
	return m_accountsService->openedAccounts().size() == 0;
}
} // namespace Startup
} // namespace Modules