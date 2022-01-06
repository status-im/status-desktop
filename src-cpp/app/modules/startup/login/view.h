#pragma once

#include "interfaces/module_view_delegate_interface.h"
#include "model.h"
#include "selected_account.h"
#include <QObject>
#include <QString>
#include <memory>

namespace Modules
{
namespace Startup
{
namespace Login
{

class View : public QObject
{
	Q_OBJECT
	Q_PROPERTY(SelectedAccount* selectedAccount READ getSelectedAccount NOTIFY selectedAccountChanged)
	Q_PROPERTY(Model* accountsModel READ getModel NOTIFY modelChanged)

public:
	explicit View(ModuleViewDelegateInterface* d, QObject* parent = nullptr);
	~View();
	void load();

signals:
	void selectedAccountChanged();
	void modelChanged();
	void accountLoginError(QString error);
	void obtainingPasswordError(QString errorDescription);
	void obtainingPasswordSuccess(QString password);

private:
	ModuleViewDelegateInterface* m_delegate;
	Model* m_model;
	SelectedAccount* m_selectedAccount;

public slots:
	Model* getModel();
	SelectedAccount* getSelectedAccount();
	void setSelectedAccount(Item item);
	void setSelectedAccountByIndex(int index);
	void setModelItems(QVector<Item> accounts);
	void login(QString password);
	void emitAccountLoginError(QString error);
	void emitObtainingPasswordError(QString errorDescription);
	void emitObtainingPasswordSuccess(QString password);
};
} // namespace Login
} // namespace Startup
} // namespace Modules