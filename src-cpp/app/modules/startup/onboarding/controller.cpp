#include "controller.h"
#include "accounts/generated_account.h"
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
namespace Onboarding
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
}

void Controller::onLogin(Signals::NodeSignal signal)
{
	if(!signal.error.isEmpty())
	{
		m_delegate->setupAccountError();
	}
}

QVector<Accounts::GeneratedAccountDto> Controller::getGeneratedAccounts()
{
	return m_accountsService->generatedAccounts();
}

Accounts::GeneratedAccountDto Controller::getImportedAccount()
{
	return m_accountsService->getImportedAccount();
}

void Controller::setSelectedAccountByIndex(int index)
{
	auto accounts = Controller::getGeneratedAccounts();
	m_selectedAccountId = accounts[index].id;
}

void Controller::storeSelectedAccountAndLogin(QString password)
{
	if(!m_accountsService->setupAccount(m_selectedAccountId, password))
	{
		m_delegate->setupAccountError();
	}
}

QString Controller::validateMnemonic(QString mnemonic)
{
	return m_accountsService->validateMnemonic(mnemonic);
}

void Controller::importMnemonic(QString mnemonic)
{
	if(m_accountsService->importMnemonic(mnemonic))
	{
		m_selectedAccountId = Controller::getImportedAccount().id;
		m_delegate->importAccountSuccess();
	}
	else
	{
		m_delegate->importAccountError();
	}
}
} // namespace Onboarding
} // namespace Startup
} // namespace Modules