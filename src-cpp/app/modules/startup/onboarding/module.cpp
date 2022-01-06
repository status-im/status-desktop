#include "module.h"
#include "accounts/generated_account.h"
#include "accounts/service_interface.h"
#include "../interfaces/module_onboarding_delegate_interface.h"
#include "controller.h"
#include "singleton.h"
#include "view.h"
#include <QObject>
#include <QQmlContext>
#include <QVariant>
#include <QDebug>
#include <iostream>

namespace Modules
{
namespace Startup
{
namespace Onboarding
{
Module::Module(Modules::Startup::ModuleOnboardingDelegateInterface* d, Accounts::ServiceInterface* accountsService)
{
	m_delegate = d;
	m_controller = new Controller(this, accountsService);
	m_view = new View(this);
	m_moduleLoaded = false;
}

Module::~Module()
{
	delete m_controller;
	delete m_view;
}

void Module::load()
{
	Global::Singleton::instance()->engine()->rootContext()->setContextProperty("onboardingModule", m_view);
	m_controller->init();
	m_view->load();

	QVector<Accounts::GeneratedAccountDto> gAcc = m_controller->getGeneratedAccounts();
	QVector<Item> accounts;
	foreach(const Accounts::GeneratedAccountDto& acc, gAcc)
	{
		accounts << Item(acc.id, acc.alias, acc.identicon, acc.address, acc.keyUid);
	}

	m_view->setAccountList(accounts);
}

bool Module::isLoaded()
{
	return m_moduleLoaded;
}

void Module::viewDidLoad()
{
	m_moduleLoaded = true;
	m_delegate->onboardingDidLoad();
}

void Module::setSelectedAccountByIndex(int index)
{
	m_controller->setSelectedAccountByIndex(index);
}

void Module::storeSelectedAccountAndLogin(QString password)
{
	m_controller->storeSelectedAccountAndLogin(password);
}
void Module::setupAccountError()
{
	m_view->setupAccountError();
}

Accounts::GeneratedAccountDto Module::getImportedAccount()
{
	return m_controller->getImportedAccount();
}

QString Module::validateMnemonic(QString mnemonic)
{
	return m_controller->validateMnemonic(mnemonic);
}

void Module::importMnemonic(QString mnemonic)
{
	m_controller->importMnemonic(mnemonic);
}

void Module::importAccountError()
{
	m_view->importAccountError();
}

void Module::importAccountSuccess()
{
	m_view->importAccountSuccess();
}
} // namespace Onboarding
} // namespace Startup
} // namespace Modules