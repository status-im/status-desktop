#pragma once

#include "interfaces/module_view_delegate_interface.h"
#include <QObject>

namespace Modules
{
namespace Startup
{
enum AppState
{
	OnboardingState = 0,
	LoginState = 1,
	MainAppState = 2
	// TODO: is Pending
};

class View : public QObject
{
	Q_OBJECT
	Q_PROPERTY(int appState READ getAppState NOTIFY appStateChanged)

public:
	explicit View(ModuleViewDelegateInterface* d, QObject* parent = nullptr);
	void emitLogOut();
	void setAppState(AppState state);
	void load();
	
signals:
	void appStateChanged(int state);
	void logOut();

private:
	ModuleViewDelegateInterface* m_delegate;
	AppState m_appState;

public slots:
	int getAppState();
};
} // namespace Startup
} // namespace Modules