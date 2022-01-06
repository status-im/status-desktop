#include "backend/accounts.h"
#include "backend/types.h"
#include "backend/utils.h"
#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QString>
#include <QVector>
#include "libstatus.h"

const int NUMBER_OF_ADDRESSES_TO_GENERATE = 5;
const int MNEMONIC_PHRASE_LENGTH = 12;

Backend::RpcResponse<QJsonArray> Backend::Accounts::generateAddresses(QVector<QString> paths)
{
	QJsonObject payload{{"n", NUMBER_OF_ADDRESSES_TO_GENERATE},
						{"mnemonicPhraseLength", MNEMONIC_PHRASE_LENGTH},
						{"bip32Passphrase", ""},
						{"paths", Utils::toJsonArray(paths)}

	};
	const char* result = MultiAccountGenerateAndDeriveAddresses(Utils::jsonToStr(payload).toUtf8().data());
	return Backend::RpcResponse<QJsonArray>(result, QJsonDocument::fromJson(result).array());
}

Backend::RpcResponse<QString> Backend::Accounts::generateIdenticon(QString publicKey)
{
	if(!publicKey.isEmpty())
	{
		auto identicon = QString(Identicon(publicKey.toUtf8().data()));
		return Backend::RpcResponse<QString>(identicon, identicon);
	}
	else
	{
		throw Backend::RpcException("publicKey can't be empty1");
	}
}

Backend::RpcResponse<QString> Backend::Accounts::generateAlias(QString publicKey)
{
	if(!publicKey.isEmpty())
	{
		auto alias = QString(GenerateAlias(publicKey.toUtf8().data()));
		return Backend::RpcResponse<QString>(alias, alias);
	}
	else
	{
		throw Backend::RpcException("publicKey can't be empty2");
	}
}

Backend::RpcResponse<QJsonObject>
Backend::Accounts::storeDerivedAccounts(QString id, QString hashedPassword, QVector<QString> paths)
{
	QJsonObject payload{{"accountID", id}, {"paths", Utils::toJsonArray(paths)}, {"password", hashedPassword}};
	auto result = MultiAccountStoreDerivedAccounts(Utils::jsonToStr(payload).toUtf8().data());
	auto obj = QJsonDocument::fromJson(result).object();
	Backend::Utils::throwOnError(obj);
	return Backend::RpcResponse<QJsonObject>(result, obj);
}

Backend::RpcResponse<QJsonObject> Backend::Accounts::saveAccountAndLogin(
	QString hashedPassword, QJsonObject account, QJsonArray subaccounts, QJsonObject settings, QJsonObject nodeConfig)
{
	auto result = SaveAccountAndLogin(Utils::jsonToStr(account).toUtf8().data(),
									  hashedPassword.toUtf8().data(),
									  Utils::jsonToStr(settings).toUtf8().data(),
									  Utils::jsonToStr(nodeConfig).toUtf8().data(),
									  Utils::jsonToStr(subaccounts).toUtf8().data());
	auto obj = QJsonDocument::fromJson(result).object();
	Backend::Utils::throwOnError(obj);
	return Backend::RpcResponse<QJsonObject>(result, obj);
}

Backend::RpcResponse<QJsonArray> Backend::Accounts::openAccounts(QString path)
{
	const char* result = OpenAccounts(path.toUtf8().data());
	auto resp = Backend::RpcResponse<QJsonArray>(result, QJsonDocument::fromJson(result).array());
	return resp;
}

Backend::RpcResponse<QJsonObject> Backend::Accounts::login(
	QString name, QString keyUid, QString hashedPassword, QString identicon, QString thumbnail, QString large)
{
	QJsonObject payload{{"name", name}, {"key-uid", keyUid}, {"identityImage", QJsonValue()}, {"identicon", identicon}};

	if(!thumbnail.isEmpty() && !large.isEmpty())
	{
		payload["identityImage"] = QJsonObject{{"thumbnail", thumbnail}, {"large", large}};
	}

	auto result = Login(Utils::jsonToStr(payload).toUtf8().data(), hashedPassword.toUtf8().data());
	auto obj = QJsonDocument::fromJson(result).object();
	Backend::Utils::throwOnError(obj);
	return Backend::RpcResponse<QJsonObject>(result, obj);
}