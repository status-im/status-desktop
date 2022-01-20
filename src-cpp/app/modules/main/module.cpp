#include "module.h"
#include "controller.h"
#include "singleton.h"
#include "view.h"
#include <QDebug>
#include <QObject>
#include <QQmlContext>
#include <QVariant>

namespace Modules
{
namespace Main
{
Module::Module(AppControllerDelegate* d)

{
	m_delegate = d;
	m_controller = new Controller(this);
	m_view = new View(this);
}

Module::~Module()
{
	delete m_controller;
	delete m_view;
}

void Module::load()
{
	Global::Singleton::instance()->engine()->rootContext()->setContextProperty("mainModule", m_view);
	m_controller->init();
	m_view->load();
}

void Module::checkIfModuleDidLoad()
{
	m_delegate->mainDidLoad();
}

void Module::viewDidLoad()
{
	Module::checkIfModuleDidLoad();
}

} // namespace Main
} // namespace Modules