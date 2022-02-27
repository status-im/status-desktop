#include "View.h"

#include "../../../Core/Engine.h"

using namespace Status::Modules::Startup::Onboarding;

View::View() : QObject(nullptr)
  , m_model(new Model(this))
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

void View::setAccountList(QVector<Item> accounts)
{
    m_model->setItems(std::move(accounts));
    emit modelChanged();
}

QString View::getImportedAccountIdenticon() const
{
    return m_delegate->getImportedAccount().identicon;
}

QString View::getImportedAccountAlias() const
{
    return m_delegate->getImportedAccount().alias;
}

QString View::getImportedAccountAddress() const
{
    return m_delegate->getImportedAccount().address;
}

void View::setSelectedAccountByIndex(const int index)
{
    m_delegate->setSelectedAccountByIndex(index);
}

void View::storeSelectedAccountAndLogin(const QString& password)
{
    m_delegate->storeSelectedAccountAndLogin(password);
}

void View::setupAccountError()
{
    emit accountSetupError();
}

QString View::validateMnemonic(const QString& mnemonic)
{
    return m_delegate->validateMnemonic(mnemonic);
}

void View::importMnemonic(const QString& mnemonic)
{
    m_delegate->importMnemonic(mnemonic);
}

void View::importAccountError()
{
    // In QML we can connect to this signal and notify a user
    // before refactoring we didn't have this signal
    emit accountImportError();
}

void View::importAccountSuccess()
{
    emit importedAccountChanged();
}
