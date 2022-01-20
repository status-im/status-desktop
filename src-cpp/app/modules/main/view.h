#pragma once

#include "interfaces/module_view_delegate_interface.h"
#include <QObject>

namespace Modules
{
namespace Main
{

class View : public QObject
{
	Q_OBJECT

public:
	explicit View(ModuleViewDelegateInterface* delegate, QObject* parent = nullptr);
	void load();

private:
	ModuleViewDelegateInterface* m_delegate;
};
} // namespace Main
} // namespace Modules