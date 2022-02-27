#include "View.h"

#include "../../../Core/Engine.h"

using namespace Status::Modules::Startup::Login;

View::View() : QObject(nullptr)
  , m_model(new Model(this))
  , m_selectedAccount(new SelectedAccount(this))
{
}

void View::setDelegate(std::shared_ptr<ViewDelegateInterface> delegate)
{
    m_delegate = std::move(delegate);
}

QObject* View::getQObject()
{
    Engine::instance()->setObjectOwnership(this, QQmlEngine::CppOwnership);
    return this;
}

void View::load()
{
    m_delegate->viewDidLoad();
}

Model* View::getModel()
{
    Engine::instance()->setObjectOwnership(m_model, QQmlEngine::CppOwnership);
    return m_model;
}

SelectedAccount* View::getSelectedAccount()
{
    Engine::instance()->setObjectOwnership(m_selectedAccount, QQmlEngine::CppOwnership);
    return m_selectedAccount;
}

void View::setModelItems(QVector<Item> accounts)
{
    m_model->setItems(std::move(accounts));
    emit modelChanged();
}

void View::setSelectedAccount(const Item& item)
{
    m_selectedAccount->setSelectedAccountData(item);
    emit selectedAccountChanged();
}

void View::emitAccountLoginError(const QString& error)
{
    emit accountLoginError(error);
}

void View::emitObtainingPasswordError(const QString& errorDescription)
{
    emit obtainingPasswordError(errorDescription);
}

void View::emitObtainingPasswordSuccess(const QString& password)
{
    emit obtainingPasswordSuccess(password);
}

void View::setSelectedAccountByIndex(const int index)
{
    Item item = m_model->getItemAtIndex(index);
    m_delegate->setSelectedAccount(item);
}

void View::login(const QString& password)
{
    m_delegate->login(password);
}
