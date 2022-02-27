#include "Module.h"

#include "Controller.h"
#include "View.h"

#include "../../../Core/Engine.h"

using namespace Status::Modules::Startup::Login;

Module::Module(std::shared_ptr<ModuleDelegateInterface> delegate,
               std::shared_ptr<ControllerInterface> controller,
               std::shared_ptr<ViewInterface> view)
    : m_delegate(std::move(delegate))
    , m_controller(std::move(controller))
    , m_view(std::move(view))
{
}

void Module::load()
{
    Engine::instance()->rootContext()->setContextProperty("loginModule", m_view->getQObject());
    m_controller->init();
    m_view->load();

    const QVector<Accounts::AccountDto> openedAccounts = m_controller->getOpenedAccounts();
    if(openedAccounts.size() > 0)
    {
        QVector<Item> items;
        foreach(const Accounts::AccountDto& acc, openedAccounts)
        {
            QString thumbnailImage;
            QString largeImage;
            extractImages(acc, thumbnailImage, largeImage);
            items << Item(acc.name, acc.identicon, thumbnailImage, largeImage, acc.keyUid);
        }

        m_view->setModelItems(items);

        // set the first account as selected one
        m_controller->setSelectedAccountKeyUid(items[0].getKeyUid());
        setSelectedAccount(items[0]);
    }
}

bool Module::isLoaded()
{
    return m_moduleLoaded;
}

void Module::viewDidLoad()
{
    m_moduleLoaded = true;
    m_delegate->loginDidLoad();
}

void Module::extractImages(const Accounts::AccountDto& account, QString& thumbnailImage, QString& largeImage)
{
    foreach(const Accounts::Image& img, account.images)
    {
        if(img.imgType == "thumbnail")
        {
            thumbnailImage = img.uri;
        }
        else if(img.imgType == "large")
        {
            largeImage = img.uri;
        }
    }
}

void Module::setSelectedAccount(const Item& item)
{
    m_controller->setSelectedAccountKeyUid(item.getKeyUid());
    m_view->setSelectedAccount(item);
}

void Module::login(const QString& password)
{
    m_controller->login(password);
}

void Module::emitAccountLoginError(const QString& error)
{
    m_view->emitAccountLoginError(error);
}

void Module::emitObtainingPasswordError(const QString& errorDescription)
{
    m_view->emitObtainingPasswordError(errorDescription);
}

void Module::emitObtainingPasswordSuccess(const QString& password)
{
    m_view->emitObtainingPasswordSuccess(password);
}

