#include "view.h"
#include "interfaces/module_view_delegate_interface.h"
#include <QObject>

namespace Modules
{
namespace Main
{

View::View(ModuleViewDelegateInterface* delegate, QObject* parent)
	: QObject(parent)
	, m_delegate(delegate)
{ }

void View::load()
{
	//  In some point, here, we will setup some exposed main module related things.
	m_delegate->viewDidLoad();
}

} // namespace Main
} // namespace Modules