#include "controller.h"
#include "accounts/account.h"
#include "accounts/service_interface.h"
#include "interfaces/module_controller_delegate_interface.h"
#include "signals.h"
#include <QDebug>
#include <QString>
#include <QVector>

namespace Modules
{
namespace Startup
{
namespace Login
{
Controller::Controller(ModuleControllerDelegateInterface* delegate,
					   // keychainService
					   Accounts::ServiceInterface* accountsService,
					   QObject* parent)
	: QObject(parent)
	, m_accountsService(accountsService)
	, m_delegate(delegate)
{ }

void Controller::init()
{
	QObject::connect(Signals::Manager::instance(), &Signals::Manager::nodeLogin, this, &Controller::onLogin);
	// keychainServiceSuccess  see src-cpp/app/modules/startup/login/controller.nim line 43
	// keychainServiceError see src-cpp/app/modules/startup/login/controller.nim line 47
}

void Controller::onLogin(Signals::NodeSignal signal)
{
	if(!signal.error.isEmpty())
	{
		m_delegate->emitAccountLoginError(signal.error);
	}
}

QVector<Accounts::AccountDto> Controller::getOpenedAccounts()
{
	return m_accountsService->openedAccounts();
}

Accounts::AccountDto Controller::getSelectedAccount()
{
	auto openedAccounts = Controller::getOpenedAccounts();
	foreach(const Accounts::AccountDto& acc, openedAccounts)
	{
		if(acc.keyUid == m_selectedAccountKeyUid)
		{
			return acc;
		}
	}

	// TODO: For situations like this, should be better to return a std::optional instead?
	return Accounts::AccountDto();
}

void Controller::setSelectedAccountKeyUid(QString keyUid)
{
	m_selectedAccountKeyUid = keyUid;

	// Dealing with Keychain is the MacOS only feature
	// if(not defined(macosx)):
	//   return

	// let selectedAccount = self.getSelectedAccount()
	// singletonInstance.localAccountSettings.setFileName(selectedAccount.name)

	// let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
	// if (value != LS_VALUE_STORE):
	//   return

	// self.keychainService.tryToObtainPassword(selectedAccount.name)
}

void Controller::login(QString password)
{
	auto selectedAccount = Controller::getSelectedAccount();
	auto error = m_accountsService->login(selectedAccount, password);
	if(!error.isEmpty())
	{
		m_delegate->emitAccountLoginError(error);
	}
}

} // namespace Login
} // namespace Startup
} // namespace Modules