#include "view.h"
#include "interfaces/module_view_delegate_interface.h"
#include <QDebug>
#include <QObject>

namespace Modules
{
namespace Startup
{
namespace Onboarding
{
View::View(ModuleViewDelegateInterface* delegate, QObject* parent)
	: QObject(parent)
	, m_delegate(delegate)
{
	m_model = new Model();
}

View::~View()
{
	delete m_model;
}

void View::load()
{
	m_delegate->viewDidLoad();
}

Model* View::getModel()
{
	return m_model;
}

void View::setAccountList(QVector<Item> accounts)
{
	m_model->setItems(accounts);
	View::modelChanged();
}

QString View::getImportedAccountIdenticon()
{
	return m_delegate->getImportedAccount().identicon;
}

QString View::getImportedAccountAlias()
{
	return m_delegate->getImportedAccount().alias;
}

QString View::getImportedAccountAddress()
{
	return m_delegate->getImportedAccount().address;
}

void View::setSelectedAccountByIndex(int index)
{
	m_delegate->setSelectedAccountByIndex(index);
}

void View::storeSelectedAccountAndLogin(QString password)
{
	m_delegate->storeSelectedAccountAndLogin(password);
}

void View::setupAccountError()
{
	View::accountSetupError();
}

QString View::validateMnemonic(QString mnemonic)
{
	return m_delegate->validateMnemonic(mnemonic);
}

void View::importMnemonic(QString mnemonic)
{
	m_delegate->importMnemonic(mnemonic);
}

void View::importAccountError()
{
	// In QML we can connect to this signal and notify a user
	// before refactoring we didn't have this signal
	View::accountImportError();
}

void View::importAccountSuccess()
{
	View::importedAccountChanged();
}
} // namespace Onboarding
} // namespace Startup
} // namespace Modules