#include "view_login.h"
#include "interfaces/module_view_delegate_interface.h"
#include "model_login.h"
#include "selected_account.h"
#include <QDebug>
#include <QObject>

namespace Modules
{
namespace Startup
{
namespace Login
{
View::View(ModuleViewDelegateInterface* delegate, QObject* parent)
    : QObject(parent)
    , m_delegate(delegate)
{
    m_model = new Model();
    m_selectedAccount = new SelectedAccount();
}

View::~View()
{
    delete m_model;
    delete m_selectedAccount;
}

void View::load()
{
    m_delegate->viewDidLoad();
}

Model* View::getModel()
{
    return m_model;
}

SelectedAccount* View::getSelectedAccount()
{
    return m_selectedAccount;
}

void View::setSelectedAccount(Item item)
{
    m_selectedAccount->setSelectedAccountData(item);
    View::selectedAccountChanged();
}

void View::setSelectedAccountByIndex(int index)
{
    Item item = m_model->getItemAtIndex(index);
    m_delegate->setSelectedAccount(item);
}

void View::setModelItems(QVector<Item> accounts)
{
    m_model->setItems(accounts);
    View::modelChanged();
}

void View::login(QString password)
{
    m_delegate->login(password);
}

void View::emitAccountLoginError(QString error)
{
    emit View::accountLoginError(error);
}

void View::emitObtainingPasswordError(QString errorDescription)
{
    emit View::obtainingPasswordError(errorDescription);
}

void View::emitObtainingPasswordSuccess(QString password)
{
    emit View::obtainingPasswordSuccess(password);
}

} // namespace Login
} // namespace Startup
} // namespace Modules
