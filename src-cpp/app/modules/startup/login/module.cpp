#include "module.h"
#include "../interfaces/module_login_delegate_interface.h"
#include "accounts/account.h"
#include "accounts/service_interface.h"
#include "controller.h"
#include "singleton.h"
#include "view.h"
#include <QDebug>
#include <QObject>
#include <QQmlContext>
#include <QVariant>
#include <iostream>

namespace Modules
{
namespace Startup
{
namespace Login
{
Module::Module(Modules::Startup::ModuleLoginDelegateInterface* d,
			   // keychainService
			   Accounts::ServiceInterface* accountsService)
{
	m_delegate = d;
	m_controller = new Controller(this, accountsService);
	m_view = new View(this);
	m_moduleLoaded = false;
}

Module::~Module()
{
	delete m_controller;
	delete m_view;
}

void Module::extractImages(Accounts::AccountDto account, QString &thumbnailImage, QString &largeImage)
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

void Module::load()
{
	Global::Singleton::instance()->engine()->rootContext()->setContextProperty("loginModule", m_view);
	m_controller->init();
	m_view->load();

	QVector<Accounts::AccountDto> openedAccounts = m_controller->getOpenedAccounts();
	if(openedAccounts.size() > 0)
	{
		QVector<Item> items;
		foreach(const Accounts::AccountDto& acc, openedAccounts)
		{
			QString thumbnailImage;
			QString largeImage;
			Module::extractImages(acc, thumbnailImage, largeImage);
			items << Item(acc.name, acc.identicon, thumbnailImage, largeImage, acc.keyUid);
		}

		m_view->setModelItems(items);

		// set the first account as selected one
		m_controller->setSelectedAccountKeyUid(items[0].getKeyUid());
		Module::setSelectedAccount(items[0]);
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

void Module::setSelectedAccount(Item item)
{
	m_controller->setSelectedAccountKeyUid(item.getKeyUid());
	m_view->setSelectedAccount(item);
}

void Module::login(QString password)
{
	m_controller->login(password);
}

void Module::emitAccountLoginError(QString error)
{
	m_view->emitAccountLoginError(error);
}

void Module::emitObtainingPasswordError(QString errorDescription)
{
	m_view->emitObtainingPasswordError(errorDescription);
}

void Module::emitObtainingPasswordSuccess(QString password)
{
	m_view->emitObtainingPasswordSuccess(password);
}
} // namespace Login
} // namespace Startup
} // namespace Modules