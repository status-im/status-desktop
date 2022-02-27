#include "Controller.h"

#include "../../Core/GlobalEvents.h"
#include "../../Common/Utils.h"

#include <StatusServices/CommonService>

using namespace Status::Modules::Startup;

Controller::Controller(std::shared_ptr<Accounts::ServiceInterface> accountsService)
    : QObject(nullptr)
    , m_delegate(nullptr)
    , m_accountsService(std::move(accountsService))
{
}

void Controller::setDelegate(std::shared_ptr<ControllerDelegateInterface> delegate)
{
    m_delegate = std::move(delegate);
}

void Controller::init()
{
    m_accountsService->init(Utils::statusGoDataDir());

    QObject::connect(&GlobalEvents::instance(), &GlobalEvents::nodeLogin, this, &Controller::onLogin);
    QObject::connect(&GlobalEvents::instance(), &GlobalEvents::nodeStopped, this, &Controller::onNodeStopped);
    QObject::connect(&GlobalEvents::instance(), &GlobalEvents::nodeReady, this, &Controller::onNodeReady);
}

bool Controller::shouldStartWithOnboardingScreen()
{
    return m_accountsService->openedAccounts().isEmpty();
}

void Controller::onLogin(const QString& error)
{
    if(!error.isEmpty())
    {
        qWarning() << error;
        return;
    }

    m_delegate->userLoggedIn();
}

void Controller::onNodeStopped(const QString& error)
{
    if(!error.isEmpty())
    {
        qWarning() << error;
    }

    m_accountsService->clear();
    m_delegate->emitLogOutSignal();
}

void Controller::onNodeReady(const QString& error)
{
    if(!error.isEmpty())
    {
        qWarning() << error;
        return;
    }

    // In case of ready node we can do something here if needed.
}
