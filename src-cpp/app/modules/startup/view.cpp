#include "view.h"
#include "interfaces/module_view_delegate_interface.h"
#include <QObject>

namespace Modules
{
namespace Startup
{

View::View(ModuleViewDelegateInterface* delegate, QObject* parent)
    : QObject(parent)
    , m_appState(AppState::OnboardingState)
    , m_delegate(delegate)
{ }

void View::load()
{
    //  In some point, here, we will setup some exposed main module related things.
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
    appStateChanged(static_cast<int>(m_appState));
}

void View::emitLogOut()
{
    logOut();
}

} // namespace Startup
} // namespace Modules
