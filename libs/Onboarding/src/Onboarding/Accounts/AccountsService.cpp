#include "AccountsService.h"

#include <StatusGo/Accounts/Accounts.h>
#include <StatusGo/General.h>
#include <StatusGo/Utils.h>
#include <StatusGo/Messenger/Service.h>

#include <ApplicationCore/Conversions.h>

#include <optional>


std::optional<QString>
getDataFromFile(const fs::path &path)
{
    QFile jsonFile{Status::toString(path)};
    if(!jsonFile.open(QIODevice::ReadOnly))
    {
        qDebug() << "unable to open" << path.filename().c_str() << " for reading";
        return std::nullopt;
    }

    QString data = jsonFile.readAll();
    jsonFile.close();
    return data;
}

namespace Status::Onboarding
{

namespace StatusGo = Status::StatusGo;
namespace Utils = Status::StatusGo::Utils;

AccountsService::AccountsService()
    : m_isFirstTimeAccountLogin(false)
{
}

bool AccountsService::init(const fs::path& statusgoDataDir)
{
    m_statusgoDataDir = statusgoDataDir;
    auto response = StatusGo::Accounts::generateAddresses(Constants::General::AccountDefaultPaths);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return false;
    }

    for(const auto &genAddressObj : response.result)
    {
        auto gAcc = GeneratedAccountDto::toGeneratedAccountDto(genAddressObj.toObject());
        gAcc.alias = generateAlias(gAcc.derivedAccounts.whisper.publicKey);
        gAcc.identicon = generateIdenticon(gAcc.derivedAccounts.whisper.publicKey);
        m_generatedAccounts.push_back(std::move(gAcc));
    }
    return true;
}

std::vector<AccountDto> AccountsService::openAndListAccounts()
{
    auto response = StatusGo::Accounts::openAccounts(m_statusgoDataDir.c_str());
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return std::vector<AccountDto>();
    }

    const auto multiAccounts = response.result;
    std::vector<AccountDto> result;
    for(const auto &value : multiAccounts)
    {
        result.push_back(AccountDto::toAccountDto(value.toObject()));
    }
    return result;
}

const std::vector<GeneratedAccountDto>& AccountsService::generatedAccounts() const
{
    return m_generatedAccounts;
}

bool AccountsService::setupAccountAndLogin(const QString &accountId, const QString &password, const QString &displayName)
{
    QString installationId(QUuid::createUuid().toString(QUuid::WithoutBraces));
    QJsonObject accountData(getAccountDataForAccountId(accountId, displayName));

    if(!setKeyStoreDir(accountData.value("key-uid").toString()))
        return false;

    QJsonArray subAccountData(getSubaccountDataForAccountId(accountId, displayName));
    QJsonObject settings(getAccountSettings(accountId, installationId, displayName));
    QJsonObject nodeConfig(getDefaultNodeConfig(installationId));

    QString hashedPassword(Utils::hashString(password));

    // This initialize the DB if first time running. Required for storing accounts
    if(StatusGo::Accounts::openAccounts(m_statusgoDataDir.c_str()).containsError())
        return false;

    AccountsService::storeDerivedAccounts(accountId, hashedPassword, Constants::General::AccountDefaultPaths);

    m_loggedInAccount = saveAccountAndLogin(hashedPassword, accountData, subAccountData, settings, nodeConfig);

    return getLoggedInAccount().isValid();
}

const AccountDto& AccountsService::getLoggedInAccount() const
{
    return m_loggedInAccount;
}

const GeneratedAccountDto& AccountsService::getImportedAccount() const
{
    return m_importedAccount;
}

bool AccountsService::isFirstTimeAccountLogin() const
{
    return m_isFirstTimeAccountLogin;
}

bool AccountsService::setKeyStoreDir(const QString &key)
{
    auto keyStoreDir = m_statusgoDataDir / m_keyStoreDirName / key.toStdString();
    auto response = StatusGo::General::initKeystore(keyStoreDir.c_str());
    return !response.containsError();
}

QString AccountsService::login(AccountDto account, const QString& password)
{
    // This is a requirement. Make it more explicit into the status go module
    if(!setKeyStoreDir(account.keyUid))
        return QString("Failed to initialize keystore before logging in");

    // This initialize the DB if first time running. Required before logging in
    if(StatusGo::Accounts::openAccounts(m_statusgoDataDir.c_str()).containsError())
        return QString("Failed to open accounts before logging in");

    QString hashedPassword(Utils::hashString(password));

    QString thumbnailImage;
    QString largeImage;
    auto response = StatusGo::Accounts::login(account.name, account.keyUid, hashedPassword, account.identicon,
                                             thumbnailImage, largeImage);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return QString();
    }

    m_loggedInAccount = std::move(account);

    return QString();
}

void AccountsService::clear()
{
    m_generatedAccounts.clear();
    m_loggedInAccount = AccountDto();
    m_importedAccount = GeneratedAccountDto();
    m_isFirstTimeAccountLogin = false;
}

QString AccountsService::generateAlias(const QString& publicKey)
{
    auto response = StatusGo::Accounts::generateAlias(publicKey);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return QString();
    }

    return response.result;
}

QString AccountsService::generateIdenticon(const QString& publicKey)
{
    auto response = StatusGo::Accounts::generateIdenticon(publicKey);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return QString();
    }

    return response.result;
}

DerivedAccounts AccountsService::storeDerivedAccounts(const QString& accountId, const QString& hashedPassword,
                                              const QVector<QString>& paths)
{
    auto response = StatusGo::Accounts::storeDerivedAccounts(accountId, hashedPassword, paths);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return DerivedAccounts();
    }
    return DerivedAccounts::toDerivedAccounts(response.result);
}

StoredAccountDto AccountsService::storeAccount(const QString& accountId, const QString& hashedPassword)
{
    auto response = StatusGo::Accounts::storeAccount(accountId, hashedPassword);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return StoredAccountDto();
    }
    return toStoredAccountDto(response.result);
}

AccountDto AccountsService::saveAccountAndLogin(const QString& hashedPassword, const QJsonObject& account,
                                        const QJsonArray& subaccounts, const QJsonObject& settings,
                                        const QJsonObject& config)
{
    if(!StatusGo::Accounts::saveAccountAndLogin(hashedPassword, account, subaccounts, settings, config)) {
        qWarning() << "Failed saving acccount" << account.value("name");
        return AccountDto();
    }

    m_isFirstTimeAccountLogin = true;
    return AccountDto::toAccountDto(account);
}

QJsonObject AccountsService::prepareAccountJsonObject(const GeneratedAccountDto& account, const QString &displayName) const
{
    return QJsonObject{{"name", displayName.isEmpty() ? account.alias : displayName},
        {"address", account.address},
        {"photo-path", account.identicon},
        {"identicon", account.identicon},
        {"key-uid", account.keyUid},
        {"keycard-pairing", QJsonValue()}};
}

QJsonObject AccountsService::getAccountDataForAccountId(const QString &accountId, const QString &displayName) const
{

    for(const GeneratedAccountDto &acc : m_generatedAccounts)
    {
        if(acc.id == accountId)
        {
            return AccountsService::prepareAccountJsonObject(acc, displayName);
        }
    }

    if(m_importedAccount.isValid())
    {
        if(m_importedAccount.id == accountId)
        {
            return AccountsService::prepareAccountJsonObject(m_importedAccount, displayName);
        }
    }

    qDebug() << "account not found";
    return QJsonObject();
}

QJsonArray AccountsService::prepareSubaccountJsonObject(const GeneratedAccountDto& account, const QString &displayName) const
{
    return {
        QJsonObject{
            {"public-key", account.derivedAccounts.defaultWallet.publicKey},
            {"address", account.derivedAccounts.defaultWallet.address},
            {"color", "#4360df"},
            {"wallet", true},
            {"path", Constants::General::PathDefaultWallet},
            {"name", "Status account"}
        },
        QJsonObject{
            {"public-key", account.derivedAccounts.whisper.publicKey},
            {"address", account.derivedAccounts.whisper.address},
            {"path", Constants::General::PathWhisper},
            {"name", displayName.isEmpty() ? account.alias : displayName},
            {"identicon", account.identicon},
            {"chat", true}
        }
    };
}

QJsonArray AccountsService::getSubaccountDataForAccountId(const QString& accountId, const QString &displayName) const
{
    // "All these for loops with a nested if cry for a std::find_if :)"
    for(const GeneratedAccountDto &acc : m_generatedAccounts)
    {
        if(acc.id == accountId)
        {
            return prepareSubaccountJsonObject(acc, displayName);
        }
    }
    if(m_importedAccount.isValid())
    {
        if(m_importedAccount.id == accountId)
        {
            return prepareSubaccountJsonObject(m_importedAccount, displayName);
        }
    }

    // TODO: Is this expected? Have proper error propagation, otherwise throw
    qDebug() << "account not found";
    return QJsonArray();
}

QString AccountsService::generateSigningPhrase(int count) const
{
    QStringList words;
    for(int i = 0; i < count; i++)
    {
        words.append(Constants::SigningPhrases[QRandomGenerator::global()->bounded(
                    static_cast<int>(Constants::SigningPhrases.size()))]);
    }
    return words.join(" ");
}

QJsonObject AccountsService::prepareAccountSettingsJsonObject(const GeneratedAccountDto& account,
                                                      const QString& installationId,
                                                      const QString& displayName) const
{
    try {
        auto templateDefaultNetworksJson = getDataFromFile(":/Status/StaticConfig/default-networks.json").value();
        auto infuraKey = getDataFromFile(":/Status/StaticConfig/infura_key").value();

        QString defaultNetworksContent = templateDefaultNetworksJson.replace("%INFURA_KEY%", infuraKey);
        QJsonArray defaultNetworksJson = QJsonDocument::fromJson(defaultNetworksContent.toUtf8()).array();

        return QJsonObject{
            {"key-uid", account.keyUid},
            {"mnemonic", account.mnemonic},
            {"public-key", account.derivedAccounts.whisper.publicKey},
            {"name", account.alias},
            {"display-name", displayName},
            {"address", account.address},
            {"eip1581-address", account.derivedAccounts.eip1581.address},
            {"dapps-address", account.derivedAccounts.defaultWallet.address},
            {"wallet-root-address", account.derivedAccounts.walletRoot.address},
            {"preview-privacy", true},
            {"signing-phrase", generateSigningPhrase(3)},
            {"log-level", "INFO"},
            {"latest-derived-path", 0},
            {"networks/networks", defaultNetworksJson},
            {"currency", "usd"},
            {"identicon", account.identicon},
            {"waku-enabled", true},
            {"wallet/visible-tokens", {
                    {Constants::General::DefaultNetworkName, QJsonArray{"SNT"}}
                }
            },
            {"appearance", 0},
            {"networks/current-network", Constants::General::DefaultNetworkName},
            {"installation-id", installationId}
        };
    } catch (std::bad_optional_access) {
        return QJsonObject();
    }
}

QJsonObject AccountsService::getAccountSettings(const QString& accountId, const QString& installationId, const QString &displayName) const
{
    for(const GeneratedAccountDto &acc : m_generatedAccounts)

        if(acc.id == accountId)
        {
            return AccountsService::prepareAccountSettingsJsonObject(acc, installationId, displayName);
        }

    if(m_importedAccount.isValid())
    {
        if(m_importedAccount.id == accountId)
        {
            return AccountsService::prepareAccountSettingsJsonObject(m_importedAccount, installationId, displayName);
        }
    }

    // TODO: Is this expected? Have proper error propagation, otherwise throw
    qDebug() << "account not found";
    return QJsonObject();
}

QJsonArray getNodes(const QJsonObject& fleet, const QString& nodeType)
{
    auto nodes = fleet[nodeType].toObject();
    QJsonArray result;
    for(auto it = nodes.begin(); it != nodes.end(); ++it)
        result << *it;
    return result;
}

QJsonObject AccountsService::getDefaultNodeConfig(const QString& installationId) const
{
    try {
        auto templateNodeConfigJsonStr = getDataFromFile(":/Status/StaticConfig/node-config.json").value();
        auto fleetJson = getDataFromFile(":/Status/StaticConfig/fleets.json").value();
        auto infuraKey = getDataFromFile(":/Status/StaticConfig/infura_key").value();

        auto nodeConfigJsonStr = templateNodeConfigJsonStr.replace("%INSTALLATIONID%", installationId)
                .replace("%INFURA_KEY%", infuraKey);
        QJsonObject nodeConfigJson = QJsonDocument::fromJson(nodeConfigJsonStr.toUtf8()).object();
        QJsonObject clusterConfig = nodeConfigJson["ClusterConfig"].toObject();

        QJsonObject fleetsJson = QJsonDocument::fromJson(fleetJson.toUtf8()).object()["fleets"].toObject();
        auto fleet = fleetsJson[Constants::Fleet::Prod].toObject();

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
    } catch (std::bad_optional_access) {
        return QJsonObject();
    }
}

}
