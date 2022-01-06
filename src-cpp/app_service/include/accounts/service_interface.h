#pragma once

#include "../app_service.h"
#include "account.h"
#include "generated_account.h"
#include <QJsonValue>
#include <QString>
#include <QVector>
#include <stdexcept>

namespace Accounts
{

class ServiceInterface : public AppService
{
public:
	virtual QVector<AccountDto> openedAccounts()
	{
		throw std::domain_error("Not implemented");
	}

	virtual QVector<GeneratedAccountDto> generatedAccounts()
	{
		throw std::domain_error("Not implemented");
	}

	virtual bool setupAccount(QString accountId, QString password)
	{
		throw std::domain_error("Not implemented");
	}

	virtual AccountDto getLoggedInAccount()
	{
		throw std::domain_error("Not implemented");
	}

	virtual GeneratedAccountDto getImportedAccount()
	{
		throw std::domain_error("Not implemented");
	}

	virtual bool isFirstTimeAccountLogin()
	{
		throw std::domain_error("Not implemented");
	}

	virtual QString validateMnemonic(QString mnemonic)
	{
		throw std::domain_error("Not implemented");
	}

	virtual bool importMnemonic(QString mnemonic)
	{
		throw std::domain_error("Not implemented");
	}

	virtual QString login(AccountDto account, QString password)
	{
		throw std::domain_error("Not implemented");
	}

	virtual void clear()
	{
		throw std::domain_error("Not implemented");
	}

	virtual QString generateAlias(QString publicKey)
	{
		throw std::domain_error("Not implemented");
	}

	virtual QString generateIdenticon(QString publicKey)
	{
		throw std::domain_error("Not implemented");
	}

	virtual bool verifyAccountPassword(QString account, QString password)
	{
		throw std::domain_error("Not implemented");
	}
};

} // namespace Accounts