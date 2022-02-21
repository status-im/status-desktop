#include "accounts/service.h"
#include "accounts/account.h"
#include "accounts/generated_account.h"
#include "accounts/service_interface.h"
#include "app_service.h"
#include "backend/accounts.h"
#include "backend/utils.h"
#include "constants.h"
#include "signing-phrases.h"
#include <QDebug>
#include <QFile>
#include <QJsonArray>
#include <QJsonObject>
#include <QRandomGenerator>
#include <QUuid>

namespace Accounts
{

Service::Service()
    : m_isFirstTimeAccountLogin(false)
{ }

const QVector<QString> PATHS{Backend::Accounts::PATH_WALLET_ROOT,
                             Backend::Accounts::PATH_EIP_1581,
                             Backend::Accounts::PATH_WHISPER,
                             Backend::Accounts::PATH_DEFAULT_WALLET};

void Service::init()
{
    auto response = Backend::Accounts::generateAddresses(Accounts::PATHS);
    foreach(QJsonValue generatedAddressJson, response.m_result)
    {
        auto gAcc = toGeneratedAccountDto(generatedAddressJson);
        gAcc.alias = generateAlias(gAcc.derivedAccounts.whisper.publicKey);
        gAcc.identicon = generateIdenticon(gAcc.derivedAccounts.whisper.publicKey);
        m_generatedAccounts << gAcc;
    }
}

QVector<AccountDto> Service::openedAccounts()
{
    // TODO: if there's an exception, should we return an empty result? or should we look into using
    // std::expected or std::optional or boost outcome https://www.boost.org/doc/libs/1_75_0/libs/outcome/doc/html/index.html
    try
    {
        auto response = Backend::Accounts::openAccounts(Constants::applicationPath(Constants::DataDir));
        QJsonArray multiAccounts = response.m_result;
        QVector<AccountDto> result;
        foreach(const QJsonValue& value, multiAccounts)
        {
            result << toAccountDto(value);
        }
        return result;
    }
    catch(Backend::RpcException& e)
    {
        qWarning() << "error: methodName=openedAccounts, errDescription=" << e.what();
        return QVector<AccountDto>();
    }
}

QVector<GeneratedAccountDto> Service::generatedAccounts()
{
    if(m_generatedAccounts.length() == 0)
    {
        qWarning("There was some issue initiating account service");
        return QVector<GeneratedAccountDto>();
    }

    return m_generatedAccounts;
}

bool Service::setupAccount(QString accountId, QString password)
{
    // TODO: would it make sense to use std::expected or std::optional or boost outcome https://www.boost.org/doc/libs/1_75_0/libs/outcome/doc/html/index.html
    try
    {
        QString installationId(QUuid::createUuid().toString(QUuid::WithoutBraces));
        QJsonObject accountData(Service::getAccountDataForAccountId(accountId));
        QJsonArray subAccountData(Service::getSubaccountDataForAccountId(accountId));
        QJsonObject settings(Service::getAccountSettings(accountId, installationId));
        QJsonObject nodeConfig(Service::getDefaultNodeConfig(installationId));

        QString hashedPassword(Backend::Utils::hashString(password));

        Service::storeDerivedAccounts(accountId, hashedPassword, PATHS);

        m_loggedInAccount =
            Service::saveAccountAndLogin(hashedPassword, accountData, subAccountData, settings, nodeConfig);

        return Service::getLoggedInAccount().isValid();
    }
    catch(exception& e)
    {
        qWarning() << "error: methodName=setupAccount, errDescription=" << e.what();
        return false;
    }
}

AccountDto Service::getLoggedInAccount()
{
    return m_loggedInAccount;
}

GeneratedAccountDto Service::getImportedAccount()
{
    return m_importedAccount;
}

bool Service::isFirstTimeAccountLogin()
{
    return m_isFirstTimeAccountLogin;
}

QString Service::validateMnemonic(QString mnemonic)
{
    // TODO:
    return "";
}

bool Service::importMnemonic(QString mnemonic)
{
    // TODO:
    return false;
}

QString Service::login(AccountDto account, QString password)
{
    // TODO: would it make sense to use std::expected or std::optional or boost outcome https://www.boost.org/doc/libs/1_75_0/libs/outcome/doc/html/index.html
    try
    {
        QString hashedPassword(Backend::Utils::hashString(password));

        QString thumbnailImage;
        QString largeImage;

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

        auto response = Backend::Accounts::login(
            account.name, account.keyUid, hashedPassword, account.identicon, thumbnailImage, largeImage);
        // TODO: check response for errors

        qDebug() << "Account logged in";

        m_loggedInAccount = account;

        return "";
    }
    catch(exception& e)
    {
        qWarning() << "error: methodName=login, errDescription=" << e.what();
        return e.what();
    }
}

void Service::clear()
{
    m_generatedAccounts.clear();
    m_loggedInAccount = Accounts::AccountDto();
    m_importedAccount = Accounts::GeneratedAccountDto();
    m_isFirstTimeAccountLogin = false;
}

QString Service::generateAlias(QString publicKey)
{
    return Backend::Accounts::generateAlias(publicKey).m_result;
}

QString Service::generateIdenticon(QString publicKey)
{
    return Backend::Accounts::generateIdenticon(publicKey).m_result;
}

bool Service::verifyAccountPassword(QString account, QString password)
{
    // TODO:
    return false;
}

DerivedAccounts Service::storeDerivedAccounts(QString accountId, QString hashedPassword, QVector<QString> paths)
{
    try
    {
        auto response = Backend::Accounts::storeDerivedAccounts(accountId, hashedPassword, paths);
        return toDerivedAccounts(response.m_result);
    }
    catch(Backend::RpcException& e)
    {
        qWarning() << e.what();
        return DerivedAccounts(); // TODO: should it return empty?
    }
}

Accounts::AccountDto Service::saveAccountAndLogin(
    QString hashedPassword, QJsonObject account, QJsonArray subaccounts, QJsonObject settings, QJsonObject config)
{
    // TODO: would it make sense to use std::expected or std::optional or boost outcome https://www.boost.org/doc/libs/1_75_0/libs/outcome/doc/html/index.html
    try
    {
        auto response = Backend::Accounts::saveAccountAndLogin(hashedPassword, account, subaccounts, settings, config);

        m_isFirstTimeAccountLogin = true;
        return toAccountDto(account);
    }
    catch(exception& e)
    {
        qWarning() << "error: methodName=saveAccountAndLogin, errDescription=" << e.what();
        return Accounts::AccountDto();
    }
}

QJsonObject Service::prepareAccountJsonObject(const GeneratedAccountDto account)
{
    return QJsonObject{{"name", account.alias},
                       {"address", account.address},
                       {"photo-path", account.identicon},
                       {"identicon", account.identicon},
                       {"key-uid", account.keyUid},
                       {"keycard-pairing", QJsonValue()}};
}

QJsonObject Service::getAccountDataForAccountId(QString accountId)
{

    foreach(const GeneratedAccountDto& acc, m_generatedAccounts)
    {
        if(acc.id == accountId)
        {
            return Service::prepareAccountJsonObject(acc);
        }
    }

    if(m_importedAccount.isValid())
    {
        if(m_importedAccount.id == accountId)
        {
            return Service::prepareAccountJsonObject(m_importedAccount);
        }
    }

    // TODO: Should we use instead a std::optional?
    throw std::runtime_error("account not found");
}

QJsonArray Service::prepareSubaccountJsonObject(GeneratedAccountDto account)
{
    return QJsonArray{QJsonObject{{"public-key", account.derivedAccounts.defaultWallet.publicKey},
                                  {"address", account.derivedAccounts.defaultWallet.address},
                                  {"color", "#4360df"},
                                  {"wallet", true},
                                  {"path", Backend::Accounts::PATH_DEFAULT_WALLET},
                                  {"name", "Status account"}},
                      QJsonObject{{"public-key", account.derivedAccounts.whisper.publicKey},
                                  {"address", account.derivedAccounts.whisper.address},
                                  {"path", Backend::Accounts::PATH_WHISPER},
                                  {"name", account.alias},
                                  {"identicon", account.identicon},
                                  {"chat", true}}};
}

QJsonArray Service::getSubaccountDataForAccountId(QString accountId)
{
    foreach(const GeneratedAccountDto& acc, m_generatedAccounts)
    {
        if(acc.id == accountId)
        {
            return prepareSubaccountJsonObject(acc);
        }
    }
    if(m_importedAccount.isValid())
    {
        if(m_importedAccount.id == accountId)
        {
            return prepareSubaccountJsonObject(m_importedAccount);
        }
    }

    // TODO: Should we use instead a std::optional?
    throw std::runtime_error("account not found");
}

QString generateSigningPhrase(int count)
{
    QStringList words;
    for(int i = 0; i < count; i++)
    {
        words.append(phrases[QRandomGenerator::global()->bounded(static_cast<int>(phrases.size()))]);
    }
    return words.join(" ");
}

QJsonObject Service::prepareAccountSettingsJsonObject(const GeneratedAccountDto account, QString installationId)
{
    QFile defaultNetworks(":/resources/default-networks.json");
    defaultNetworks.open(QIODevice::ReadOnly);

    QString defaultNetworksContent = defaultNetworks.readAll().replace("%INFURA_KEY%", INFURA_KEY);
    QJsonArray defaultNetworksJson = QJsonDocument::fromJson(defaultNetworksContent.toUtf8()).array();

    return QJsonObject{{"key-uid", account.keyUid},
                       {"mnemonic", account.mnemonic},
                       {"public-key", account.derivedAccounts.whisper.publicKey},
                       {"name", account.alias},
                       {"address", account.address},
                       {"eip1581-address", account.derivedAccounts.eip1581.address},
                       {"dapps-address", account.derivedAccounts.defaultWallet.address},
                       {"wallet-root-address", account.derivedAccounts.walletRoot.address},
                       {"preview-privacy?", true},
                       {"signing-phrase", generateSigningPhrase(3)},
                       {"log-level", "INFO"},
                       {"latest-derived-path", 0},
                       {"networks/networks", defaultNetworksJson},
                       {"currency", "usd"},
                       {"identicon", account.identicon},
                       {"waku-enabled", true},
                       {"wallet/visible-tokens", {{Constants::DefaultNetworkName, QJsonArray{"SNT"}}}},
                       {"appearance", 0},
                       {"networks/current-network", Constants::DefaultNetworkName},
                       {"installation-id", installationId}};
}

QJsonObject Service::getAccountSettings(QString accountId, QString installationId)
{
    foreach(const GeneratedAccountDto& acc, m_generatedAccounts)

        if(acc.id == accountId)
        {
            return Service::prepareAccountSettingsJsonObject(acc, installationId);
        }

    if(m_importedAccount.isValid())
    {
        if(m_importedAccount.id == accountId)
        {
            return Service::prepareAccountSettingsJsonObject(m_importedAccount, installationId);
        }
    }

    // TODO: Should we use instead a std::optional?
    throw std::runtime_error("account not found");
}

QJsonArray getNodes(const QJsonObject fleet, QString nodeType)
{
    auto nodes = fleet[nodeType].toObject();
    QJsonArray result;
    for(auto it = nodes.begin(); it != nodes.end(); ++it)
        result << *it;
    return result;
}

QJsonObject Service::getDefaultNodeConfig(QString installationId)
{
    QFile nodeConfig(":/resources/node-config.json");
    nodeConfig.open(QIODevice::ReadOnly);

    QString nodeConfigContent = nodeConfig.readAll();

    nodeConfigContent = nodeConfigContent.replace("%INSTALLATIONID%", installationId);
    nodeConfigContent = nodeConfigContent.replace("%INFURA_KEY%", INFURA_KEY);

    QJsonObject nodeConfigJson = QJsonDocument::fromJson(nodeConfigContent.toUtf8()).object();

    QFile fleets(":/resources/fleets.json");
    fleets.open(QIODevice::ReadOnly);
    QJsonObject fleetsJson = QJsonDocument::fromJson(fleets.readAll()).object()["fleets"].toObject();

    auto fleet = fleetsJson[Constants::Fleet::Prod].toObject();

    QJsonObject clusterConfig = nodeConfigJson["ClusterConfig"].toObject();

    clusterConfig["Fleet"] = Constants::Fleet::Prod;
    clusterConfig["BootNodes"] = getNodes(fleet, Constants::FleetNodes::Bootnodes);
    clusterConfig["TrustedMailServers"] = getNodes(fleet, Constants::FleetNodes::Mailservers);
    clusterConfig["StaticNodes"] = getNodes(fleet, Constants::FleetNodes::Whisper);
    clusterConfig["RendezvousNodes"] = getNodes(fleet, Constants::FleetNodes::Rendezvous);
    clusterConfig["RelayNodes"] = getNodes(fleet, Constants::FleetNodes::Waku);
    clusterConfig["StoreNodes"] = getNodes(fleet, Constants::FleetNodes::Waku);
    clusterConfig["FilterNodes"] = getNodes(fleet, Constants::FleetNodes::Waku);
    clusterConfig["LightpushNodes"] = getNodes(fleet, Constants::FleetNodes::Waku);

    nodeConfigJson["ClusterConfig"] = clusterConfig;

    return nodeConfigJson;
}
} // namespace Accounts
