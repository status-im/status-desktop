#include "StatusBackend/Accounts.h"

#include "StatusBackend/Utils.h"
#include "libstatus.h"

const int NUMBER_OF_ADDRESSES_TO_GENERATE = 5;
const int MNEMONIC_PHRASE_LENGTH = 12;

using namespace Backend;

RpcResponse<QJsonArray> Accounts::generateAddresses(const QVector<QString>& paths)
{
    QJsonObject payload{
        {"n", NUMBER_OF_ADDRESSES_TO_GENERATE},
        {"mnemonicPhraseLength", MNEMONIC_PHRASE_LENGTH},
        {"bip32Passphrase", ""},
        {"paths", Utils::toJsonArray(paths)}
    };

    try
    {
        auto result = MultiAccountGenerateAndDeriveAddresses(Utils::jsonToByteArray(std::move(payload)).data());
        QJsonArray jsonResult;
        if(!Utils::checkReceivedResponse(result, jsonResult))
        {
            auto msg = QObject::tr("parsing response failed");
            throw std::domain_error(msg.toStdString());
        }

        return Utils::buildJsonRpcResponse(jsonResult);
    }
    catch (std::exception& e)
    {
        auto response = RpcResponse<QJsonArray>(QJsonArray());
        response.error.message = QObject::tr("an error generating address occurred, msg: %1").arg(e.what());
        return response;
    }
    catch (...)
    {
        auto response = RpcResponse<QJsonArray>(QJsonArray());
        response.error.message = QObject::tr("an error generating address occurred");
        return response;
    }
}

RpcResponse<QString> Accounts::generateIdenticon(const QString& publicKey)
{
    try
    {
        QString identicon;
        if(!publicKey.isEmpty())
        {
            identicon = Identicon(publicKey.toUtf8().data());
        }
        return Utils::buildJsonRpcResponse(identicon);
    }
    catch (...)
    {
        auto response = RpcResponse<QString>(QString());
        response.error.message = QObject::tr("an error generating identicon occurred");
        return response;
    }
}

RpcResponse<QString> Accounts::generateAlias(const QString& publicKey)
{
    try
    {
        QString alias;
        if(!publicKey.isEmpty())
        {
            alias = GenerateAlias(publicKey.toUtf8().data());
        }

        return Utils::buildJsonRpcResponse(alias);
    }
    catch (...)
    {
        auto response = RpcResponse<QString>(QString());
        response.error.message = QObject::tr("an error generating alias occurred");
        return response;
    }
}

RpcResponse<QJsonObject> Accounts::storeDerivedAccounts(const QString& id, const QString& hashedPassword,
                                                        const QVector<QString>& paths)
{
    QJsonObject payload{
        {"accountID", id},
        {"paths", Utils::toJsonArray(paths)},
        {"password", hashedPassword}
    };

    try
    {
        auto result = MultiAccountStoreDerivedAccounts(Utils::jsonToByteArray(std::move(payload)).data());
        QJsonObject jsonResult;
        if(!Utils::checkReceivedResponse(result, jsonResult))
        {
            auto msg = QObject::tr("parsing response failed");
            throw std::domain_error(msg.toStdString());
        }

        return Utils::buildJsonRpcResponse(jsonResult);
    }
    catch (std::exception& e)
    {
        auto response = RpcResponse<QJsonObject>(QJsonObject());
        response.error.message = QObject::tr("an error storing derived accounts occurred, msg: %1").arg(e.what());
        return response;
    }
    catch (...)
    {
        auto response = RpcResponse<QJsonObject>(QJsonObject());
        response.error.message = QObject::tr("an error storing derived accounts occurred");
        return response;
    }
}

RpcResponse<QJsonObject> Accounts::saveAccountAndLogin(const QString& hashedPassword, const QJsonObject& account,
                                                       const QJsonArray& subaccounts, const QJsonObject& settings,
                                                       const QJsonObject& nodeConfig)
{
    try
    {
        auto result = SaveAccountAndLogin(Utils::jsonToByteArray(std::move(account)).data(),
                                          hashedPassword.toUtf8().data(),
                                          Utils::jsonToByteArray(std::move(settings)).data(),
                                          Utils::jsonToByteArray(std::move(nodeConfig)).data(),
                                          Utils::jsonToByteArray(std::move(subaccounts)).data());
        QJsonObject jsonResult;
        if(!Utils::checkReceivedResponse(result, jsonResult))
        {
            auto msg = QObject::tr("parsing response failed");
            throw std::domain_error(msg.toStdString());
        }

        return Utils::buildJsonRpcResponse(jsonResult);
    }
    catch (std::exception& e)
    {
        auto response = RpcResponse<QJsonObject>(QJsonObject());
        response.error.message = QObject::tr("an error saving account and login occurred, msg: %1").arg(e.what());
        return response;
    }
    catch (...)
    {
        auto response = RpcResponse<QJsonObject>(QJsonObject());
        response.error.message = QObject::tr("an error saving account and login occurred");
        return response;
    }
}

Backend::RpcResponse<QJsonArray> Backend::Accounts::openAccounts(const QString& path)
{
    try
    {
        auto result = OpenAccounts(path.toUtf8().data());
        QJsonArray jsonResult;
        if(!Utils::checkReceivedResponse(result, jsonResult))
        {
            auto msg = QObject::tr("parsing response failed");
            throw std::domain_error(msg.toStdString());
        }

        return Utils::buildJsonRpcResponse(jsonResult);
    }
    catch (std::exception& e)
    {
        auto response = RpcResponse<QJsonArray>(QJsonArray());
        response.error.message = QObject::tr("an error opening accounts occurred, msg: %1").arg(e.what());
        return response;
    }
    catch (...)
    {
        auto response = RpcResponse<QJsonArray>(QJsonArray());
        response.error.message = QObject::tr("an error opening accounts occurred");
        return response;
    }
}

RpcResponse<QJsonObject> Accounts::login(const QString& name, const QString& keyUid, const QString& hashedPassword,
                                         const QString& identicon, const QString& thumbnail, const QString& large)
{
    QJsonObject payload{
        {"name", name},
        {"key-uid", keyUid},
        {"identityImage", QJsonValue()},
        {"identicon", identicon}
    };

    if(!thumbnail.isEmpty() && !large.isEmpty())
    {
        payload["identityImage"] = QJsonObject{{"thumbnail", thumbnail}, {"large", large}};
    }

    try
    {
        auto result = Login(Utils::jsonToByteArray(std::move(payload)).data(), hashedPassword.toUtf8().data());
        QJsonObject jsonResult;
        if(!Utils::checkReceivedResponse(result, jsonResult))
        {
            auto msg = QObject::tr("parsing response failed");
            throw std::domain_error(msg.toStdString());
        }

        return Utils::buildJsonRpcResponse(jsonResult);
    }
    catch (std::exception& e)
    {
        auto response = RpcResponse<QJsonObject>(QJsonObject());
        response.error.message = QObject::tr("an error logining in account occurred, msg: %1").arg(e.what());
        return response;
    }
    catch (...)
    {
        auto response = RpcResponse<QJsonObject>(QJsonObject());
        response.error.message = QObject::tr("an error logining in account occurred");
        return response;
    }
}
