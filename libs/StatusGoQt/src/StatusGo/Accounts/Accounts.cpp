#include "Accounts.h"

#include "Utils.h"

#include <libstatus.h>

const int NUMBER_OF_ADDRESSES_TO_GENERATE = 5;
const int MNEMONIC_PHRASE_LENGTH = 12;

namespace Status::StatusGo::Accounts {

RpcResponse<QJsonArray> generateAddresses(const std::vector<Accounts::DerivationPath>& paths)
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

        return Utils::buildPrivateRPCResponse(jsonResult);
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

RpcResponse<QString> generateAlias(const QString& publicKey)
{
    try
    {
        QString alias;
        if(!publicKey.isEmpty())
        {
            alias = GenerateAlias(publicKey.toUtf8().data());
        }

        return Utils::buildPrivateRPCResponse(alias);
    }
    catch (...)
    {
        auto response = RpcResponse<QString>(QString());
        response.error.message = QObject::tr("an error generating alias occurred");
        return response;
    }
}

RpcResponse<QJsonObject> storeDerivedAccounts(const QString& id, const HashedPassword& password, const std::vector<Accounts::DerivationPath>& paths)
{
    QJsonObject payload{
        {"accountID", id},
        {"paths", Utils::toJsonArray(paths)},
        {"password", password.get()}
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

        RpcResponse<QJsonObject> rpcResponse(jsonResult);
        rpcResponse.error = Utils::getRPCErrorInJson(jsonResult).value_or(RpcError());
        return rpcResponse;
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

RpcResponse<QJsonObject> storeAccount(const QString& id, const HashedPassword& password)
{
    QJsonObject payload{
        {"accountID", id},
        {"password", password.get()}
    };

    try
    {
        auto result = MultiAccountStoreAccount(Utils::jsonToByteArray(std::move(payload)).data());
        QJsonObject jsonResult;
        if(!Utils::checkReceivedResponse(result, jsonResult))
        {
            auto msg = QObject::tr("parsing response failed");
            throw std::domain_error(msg.toStdString());
        }

        RpcResponse<QJsonObject> rpcResponse(jsonResult);
        rpcResponse.error = Utils::getRPCErrorInJson(jsonResult).value_or(RpcError());
        return rpcResponse;
    }
    catch (std::exception& e)
    {
        auto response = RpcResponse<QJsonObject>(QJsonObject());
        response.error.message = QObject::tr("an error storing account occurred, msg: %1").arg(e.what());
        return response;
    }
    catch (...)
    {
        auto response = RpcResponse<QJsonObject>(QJsonObject());
        response.error.message = QObject::tr("an error storing account occurred");
        return response;
    }
}

bool saveAccountAndLogin(const HashedPassword& password, const QJsonObject& account,
                         const QJsonArray& subaccounts, const QJsonObject& settings,
                         const QJsonObject& nodeConfig)
{
    try
    {
        auto result = SaveAccountAndLogin(Utils::jsonToByteArray(account).data(),
                                          password.get().toUtf8().data(),
                                          Utils::jsonToByteArray(settings).data(),
                                          Utils::jsonToByteArray(nodeConfig).data(),
                                          Utils::jsonToByteArray(subaccounts).data());
        QJsonObject jsonResult;
        if(!Utils::checkReceivedResponse(result, jsonResult))
        {
            auto msg = QObject::tr("parsing response failed");
            throw std::domain_error(msg.toStdString());
        }

        return !Utils::getRPCErrorInJson(jsonResult).has_value();
    } catch (std::exception& e) {
        qWarning() << QString("an error saving account and login occurred, msg: %1").arg(e.what());
    } catch (...) {
        qWarning() << "an error saving account and login occurred";
    }
    return false;
}

RpcResponse<QJsonArray> openAccounts(const char* dataDirPath)
{
    try
    {
        auto result = QString(OpenAccounts(const_cast<char*>(dataDirPath)));
        if(result == "null")
            return RpcResponse<QJsonArray>(QJsonArray());

        QJsonArray jsonResult;
        if(!Utils::checkReceivedResponse(result, jsonResult)) {
            throw std::domain_error("parsing response failed");
        }

        return Utils::buildPrivateRPCResponse(jsonResult);
    }
    catch (std::exception& e)
    {
        auto response = RpcResponse<QJsonArray>(QJsonArray());
        // TODO: don't translate exception messages. Exceptions are for developers and should never reach users
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

RpcResponse<QJsonObject> login(const QString& name, const QString& keyUid, const HashedPassword& password,
                               const QString& thumbnail, const QString& large)
{
    QJsonObject payload{
        {"name", name},
        {"key-uid", keyUid},
        {"identityImage", QJsonValue()}
    };

    if(!thumbnail.isEmpty() && !large.isEmpty())
    {
        payload["identityImage"] = QJsonObject{{"thumbnail", thumbnail}, {"large", large}};
    }

    try
    {
        auto payloadData = Utils::jsonToByteArray(std::move(payload));
        auto result = Login(payloadData.data(), password.get().toUtf8().data());
        QJsonObject jsonResult;
        if(!Utils::checkReceivedResponse(result, jsonResult))
        {
            auto msg = QObject::tr("parsing response failed");
            throw std::domain_error(msg.toStdString());
        }

        return Utils::buildPrivateRPCResponse(jsonResult);
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

RpcResponse<QJsonObject> loginWithConfig(const QString& name, const QString& keyUid, const HashedPassword& password,
                                         const QString& thumbnail, const QString& large, const QJsonObject& nodeConfig)
{
    QJsonObject payload{
        {"name", name},
        {"key-uid", keyUid},
        {"identityImage", QJsonValue()},
    };

    if(!thumbnail.isEmpty() && !large.isEmpty())
    {
        payload["identityImage"] = QJsonObject{{"thumbnail", thumbnail}, {"large", large}};
    }

    try
    {
        auto payloadData = Utils::jsonToByteArray(std::move(payload));
        auto nodeConfigData = Utils::jsonToByteArray(nodeConfig);
        auto result = LoginWithConfig(payloadData.data(), password.get().toUtf8().data(), nodeConfigData.data());
        QJsonObject jsonResult;
        if(!Utils::checkReceivedResponse(result, jsonResult))
        {
            auto msg = QObject::tr("parsing response failed");
            throw std::domain_error(msg.toStdString());
        }

        return Utils::buildPrivateRPCResponse(jsonResult);
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

RpcResponse<QJsonObject> logout()
{
    try
    {
        auto result = Logout();
        QJsonObject jsonResult;
        if(!Utils::checkReceivedResponse(result, jsonResult))
        {
            auto msg = QObject::tr("parsing response failed");
            throw std::domain_error(msg.toStdString());
        }

        RpcResponse<QJsonObject> rpcResponse(jsonResult);
        rpcResponse.error = Utils::getRPCErrorInJson(jsonResult).value_or(RpcError());
        return rpcResponse;
    }
    catch (std::exception& e)
    {
        auto response = RpcResponse<QJsonObject>(QJsonObject());
        response.error.message = QObject::tr("an error logging out account occurred, msg: %1").arg(e.what());
        return response;
    }
    catch (...)
    {
        auto response = RpcResponse<QJsonObject>(QJsonObject());
        response.error.message = QObject::tr("an error logging out account occurred");
        return response;
    }
}

}
