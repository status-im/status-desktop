#include "View.h"

#include "../../Core/Engine.h"

using namespace Status::Modules::Startup;

View::View() : QObject(nullptr)
  , m_appState(AppState::OnboardingState)
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

int View::getAppState()
{
    return static_cast<int>(m_appState);
}

void View::setAppState(AppState state)
{
    if(m_appState == state)
    {
        return;
    }

    m_appState = state;
    emit appStateChanged(m_appState);
}

void View::emitLogOut()
{
    emit logOut();
}

void View::emitStartUpUIRaised()
{
    emit startUpUIRaised();
}
