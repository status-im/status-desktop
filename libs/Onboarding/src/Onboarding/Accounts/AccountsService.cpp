#include "AccountsService.h"

#include <StatusGo/Accounts/Accounts.h>
#include <StatusGo/Accounts/AccountsAPI.h>
#include <StatusGo/General.h>
#include <StatusGo/Messenger/Service.h>
#include <StatusGo/Utils.h>

#include <Helpers/conversions.h>

#include <optional>

#include <QtGlobal>

std::optional<QString> getDataFromFile(const fs::path& path)
{
    QFile jsonFile{Status::toQString(path)};
    if(!jsonFile.open(QIODevice::ReadOnly))
    {
        qDebug() << "unable to open" << path.filename().c_str() << " for reading";
        return std::nullopt;
    }

    QString data = jsonFile.readAll();
    jsonFile.close();
    return data;
}

namespace StatusGo = Status::StatusGo;
namespace Utils = Status::StatusGo::Utils;

namespace Status::Onboarding
{

AccountsService::AccountsService()
    : m_isFirstTimeAccountLogin(false)
{ }

bool AccountsService::init(const fs::path& statusgoDataDir)
{
    m_statusgoDataDir = statusgoDataDir;
    auto response = StatusGo::Accounts::generateAddresses(Constants::General::AccountDefaultPaths);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return false;
    }

    for(const auto& genAddressObj : response.result)
    {
        auto gAcc = GeneratedMultiAccount::toGeneratedMultiAccount(genAddressObj.toObject());
        gAcc.alias = generateAlias(gAcc.derivedAccounts.whisper.publicKey);
        m_generatedAccounts.push_back(std::move(gAcc));
    }
    return true;
}

std::vector<MultiAccount> AccountsService::openAndListAccounts()
{
    auto response = StatusGo::Accounts::openAccounts(m_statusgoDataDir.c_str());
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return std::vector<MultiAccount>();
    }

    const auto multiAccounts = response.result;
    std::vector<MultiAccount> result;
    for(const auto& value : multiAccounts)
    {
        result.push_back(MultiAccount::toMultiAccount(value.toObject()));
    }
    return result;
}

const std::vector<GeneratedMultiAccount>& AccountsService::generatedAccounts() const
{
    return m_generatedAccounts;
}

bool AccountsService::setupAccountAndLogin(const QString& accountId,
                                           const QString& password,
                                           const QString& displayName)
{
    const QString installationId(QUuid::createUuid().toString(QUuid::WithoutBraces));
    const QJsonObject accountData(getAccountDataForAccountId(accountId, displayName));

    if(!setKeyStoreDir(accountData.value("key-uid").toString())) return false;

    QJsonArray subAccountData(getSubaccountDataForAccountId(accountId, displayName));
    QJsonObject settings(getAccountSettings(accountId, installationId, displayName));
    QJsonObject nodeConfig(getDefaultNodeConfig(installationId));

    auto hashedPassword(Utils::hashPassword(password));

    // This initialize the DB if first time running. Required for storing accounts
    if(StatusGo::Accounts::openAccounts(m_statusgoDataDir.c_str()).containsError()) return false;

    AccountsService::storeAccount(accountId, hashedPassword);
    AccountsService::storeDerivedAccounts(accountId, hashedPassword, Constants::General::AccountDefaultPaths);

    m_loggedInAccount = saveAccountAndLogin(hashedPassword, accountData, subAccountData, settings, nodeConfig);

    return getLoggedInAccount().isValid();
}

const MultiAccount& AccountsService::getLoggedInAccount() const
{
    return m_loggedInAccount;
}

const GeneratedMultiAccount& AccountsService::getImportedAccount() const
{
    return m_importedAccount;
}

bool AccountsService::isFirstTimeAccountLogin() const
{
    return m_isFirstTimeAccountLogin;
}

bool AccountsService::setKeyStoreDir(const QString& key)
{
    m_keyStoreDir = m_statusgoDataDir / m_keyStoreDirName / key.toStdString();
    const auto response = StatusGo::General::initKeystore(m_keyStoreDir.c_str());
    return !response.containsError();
}

QString AccountsService::login(MultiAccount account, const QString& password)
{
    // This is a requirement. Make it more explicit into the status go module
    if(!setKeyStoreDir(account.keyUid)) return QString("Failed to initialize keystore before logging in");

    // This initialize the DB if first time running. Required before logging in
    if(StatusGo::Accounts::openAccounts(m_statusgoDataDir.c_str()).containsError())
        return QString("Failed to open accounts before logging in");

    const auto hashedPassword(Utils::hashPassword(password));

    const QString thumbnailImage;
    const QString largeImage;
    const auto response =
        StatusGo::Accounts::login(account.name, account.keyUid, hashedPassword, thumbnailImage, largeImage);
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
    m_loggedInAccount = MultiAccount();
    m_importedAccount = GeneratedMultiAccount();
    m_isFirstTimeAccountLogin = false;
}

QString AccountsService::generateAlias(const QString& publicKey)
{
    const auto response = StatusGo::Accounts::generateAlias(publicKey);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return QString();
    }

    return response.result;
}

void AccountsService::deleteMultiAccount(const MultiAccount& account)
{
    StatusGo::Accounts::deleteMultiaccount(account.keyUid, m_keyStoreDir);
}

DerivedAccounts AccountsService::storeDerivedAccounts(const QString& accountId,
                                                      const StatusGo::HashedPassword& password,
                                                      const std::vector<Accounts::DerivationPath>& paths)
{
    const auto response = StatusGo::Accounts::storeDerivedAccounts(accountId, password, paths);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return DerivedAccounts();
    }
    return DerivedAccounts::toDerivedAccounts(response.result);
}

StoredMultiAccount AccountsService::storeAccount(const QString& accountId, const StatusGo::HashedPassword& password)
{
    const auto response = StatusGo::Accounts::storeAccount(accountId, password);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return StoredMultiAccount();
    }
    return toStoredMultiAccount(response.result);
}

MultiAccount AccountsService::saveAccountAndLogin(const StatusGo::HashedPassword& password,
                                                  const QJsonObject& account,
                                                  const QJsonArray& subaccounts,
                                                  const QJsonObject& settings,
                                                  const QJsonObject& config)
{
    if(!StatusGo::Accounts::saveAccountAndLogin(password, account, subaccounts, settings, config))
    {
        qWarning() << "Failed saving acccount" << account.value("name");
        return MultiAccount();
    }

    m_isFirstTimeAccountLogin = true;
    return MultiAccount::toMultiAccount(account);
}

QJsonObject AccountsService::prepareAccountJsonObject(const GeneratedMultiAccount& account,
                                                      const QString& displayName) const
{
    return QJsonObject{{"name", displayName.isEmpty() ? account.alias : displayName},
                       {"address", account.address},
                       {"key-uid", account.keyUid},
                       {"keycard-pairing", QJsonValue()}};
}

QJsonObject AccountsService::getAccountDataForAccountId(const QString& accountId, const QString& displayName) const
{
    for(const GeneratedMultiAccount& acc : m_generatedAccounts)
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

QJsonArray AccountsService::prepareSubaccountJsonObject(const GeneratedMultiAccount& account,
                                                        const QString& displayName) const
{
    return {QJsonObject{{"public-key", account.derivedAccounts.defaultWallet.publicKey},
                        {"address", account.derivedAccounts.defaultWallet.address},
                        {"color", "#4360df"},
                        {"wallet", true},
                        {"path", Constants::General::PathDefaultWallet.get()},
                        {"name", "Status account"},
                        {"derived-from", account.address}},
            QJsonObject{{"public-key", account.derivedAccounts.whisper.publicKey},
                        {"address", account.derivedAccounts.whisper.address},
                        {"name", displayName.isEmpty() ? account.alias : displayName},
                        {"path", Constants::General::PathWhisper.get()},
                        {"chat", true},
                        {"derived-from", ""}}};
}

QJsonArray AccountsService::getSubaccountDataForAccountId(const QString& accountId, const QString& displayName) const
{
    // "All these for loops with a nested if cry for a std::find_if :)"
    for(const GeneratedMultiAccount& acc : m_generatedAccounts)
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

QJsonObject AccountsService::prepareAccountSettingsJsonObject(const GeneratedMultiAccount& account,
                                                              const QString& installationId,
                                                              const QString& displayName) const
{
    return QJsonObject{{"key-uid", account.keyUid},
                       {"mnemonic", account.mnemonic},
                       {"public-key", account.derivedAccounts.whisper.publicKey},
                       {"name", account.alias},
                       {"display-name", displayName},
                       {"address", account.address},
                       {"eip1581-address", account.derivedAccounts.eip1581.address},
                       {"dapps-address", account.derivedAccounts.defaultWallet.address},
                       {"wallet-root-address", account.derivedAccounts.walletRoot.address},
                       {"preview-privacy?", true},
                       {"signing-phrase", generateSigningPhrase(3)},
                       {"log-level", "INFO"},
                       {"latest-derived-path", 0},
                       {"currency", "usd"},
                       {"networks/networks", QJsonArray()},
                       {"networks/current-network", ""},
                       {"wallet/visible-tokens", QJsonObject()},
                       {"waku-enabled", true},
                       {"appearance", 0},
                       {"installation-id", installationId}};
}

QJsonObject AccountsService::getAccountSettings(const QString& accountId,
                                                const QString& installationId,
                                                const QString& displayName) const
{
    for(const GeneratedMultiAccount& acc : m_generatedAccounts)

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
    const auto nodes = fleet[nodeType].toObject();
    QJsonArray result;
    for(auto it = nodes.begin(); it != nodes.end(); ++it)
        result << *it;
    return result;
}

/// Mirrors and in sync with getDefaultNodeConfig@service.nim
QJsonObject AccountsService::getDefaultNodeConfig(const QString& installationId) const
{
    try
    {
        const auto envVarInfuraToken = "INFURA_TOKEN";
        const auto envVarWakuV2Port = "WAKUV2_PORT";

        auto templateNodeConfigJsonStr = getDataFromFile(":/Status/StaticConfig/node-config.json").value();
        auto fleetJson = getDataFromFile(":/Status/StaticConfig/fleets.json").value();
        const auto infuraKey = qEnvironmentVariable(envVarInfuraToken, getDataFromFile(":/Status/StaticConfig/infura_key").value());

        auto templateDefaultNetworksJson = getDataFromFile(":/Status/StaticConfig/default-networks.json").value();
        QString defaultNetworksContent = templateDefaultNetworksJson.replace("%INFURA_TOKEN_RESOLVED%", infuraKey);
        QJsonArray defaultNetworksJson = QJsonDocument::fromJson(defaultNetworksContent.toUtf8()).array();

        const auto DEFAULT_WAKUV2_CONFIG_PORT = "0";
        const auto DEFAULT_TORRENT_CONFIG_PORT = 9025;
        const auto DEFAULT_TORRENT_CONFIG_DATADIR = m_statusgoDataDir / "archivedata";
        const auto DEFAULT_TORRENT_CONFIG_TORRENTDIR = m_statusgoDataDir / "torrents";

        const auto wakuV2Port = qEnvironmentVariable(envVarWakuV2Port, DEFAULT_WAKUV2_CONFIG_PORT);

        auto nodeConfigJsonStr =
            templateNodeConfigJsonStr.replace("%INSTALLATIONID%", installationId)
                .replace("%INFURA_TOKEN_RESOLVED%", infuraKey)
                .replace("%DEFAULT_TORRENT_CONFIG_PORT%", QString::number(DEFAULT_TORRENT_CONFIG_PORT))
                .replace("%DEFAULT_TORRENT_CONFIG_DATADIR%", DEFAULT_TORRENT_CONFIG_DATADIR.c_str())
                .replace("%DEFAULT_TORRENT_CONFIG_TORRENTDIR%", DEFAULT_TORRENT_CONFIG_TORRENTDIR.c_str())
                .replace("%DEFAULT_WAKUV2_CONFIG_PORT%", wakuV2Port);

        QJsonObject nodeConfigJson = QJsonDocument::fromJson(nodeConfigJsonStr.toUtf8()).object();

        auto clusterConfig = nodeConfigJson["ClusterConfig"].toObject();
        auto fleetsJson = QJsonDocument::fromJson(fleetJson.toUtf8()).object()["fleets"].toObject();
        auto fleet = fleetsJson[Constants::Fleet::Prod].toObject();
        clusterConfig["Fleet"] = Constants::Fleet::Prod;
        clusterConfig["BootNodes"] = getNodes(fleet, Constants::FleetNodes::Bootnodes);
        clusterConfig["TrustedMailServers"] = getNodes(fleet, Constants::FleetNodes::Mailservers);
        clusterConfig["StaticNodes"] = getNodes(fleet, Constants::FleetNodes::Whisper);
        clusterConfig["RendezvousNodes"] = getNodes(fleet, Constants::FleetNodes::Rendezvous);
        nodeConfigJson["NetworkId"] = defaultNetworksJson[0].toObject()["chainId"];
        nodeConfigJson["DataDir"] = "ethereum";
        auto upstreamConfig = nodeConfigJson["UpstreamConfig"].toObject();
        upstreamConfig["Enabled"] = true;
        upstreamConfig["URL"] = defaultNetworksJson[0].toObject()["rpcUrl"];
        nodeConfigJson["UpstreamConfig"] = upstreamConfig;
        auto shhextConfig = nodeConfigJson["ShhextConfig"].toObject();
        shhextConfig["InstallationID"] = installationId;
        nodeConfigJson["ShhextConfig"] = shhextConfig;
        nodeConfigJson["Networks"] = defaultNetworksJson;
        nodeConfigJson["NoDiscovery"] = true;
        nodeConfigJson["Rendezvous"] = false;
        QJsonArray dnsDiscoveryURL = {"enrtree://AOGECG2SPND25EEFMAJ5WF3KSGJNSGV356DSTL2YVLLZWIV6SAYBM@prod.nodes.status.im"};
        clusterConfig["WakuNodes"] = dnsDiscoveryURL;
        clusterConfig["DiscV5BootstrapNodes"] = dnsDiscoveryURL;

        auto wakuv2Config = nodeConfigJson["WakuV2Config"].toObject();
        wakuv2Config["EnableDiscV5"] = true;
        wakuv2Config["DiscoveryLimit"] = 20;
        wakuv2Config["Rendezvous"] = true;
        wakuv2Config["Enabled"] = true;

        wakuv2Config["Enabled"] = false;
        nodeConfigJson["WakuV2Config"] = wakuv2Config;

        clusterConfig["RelayNodes"] = getNodes(fleet, Constants::FleetNodes::Waku);
        clusterConfig["StoreNodes"] = getNodes(fleet, Constants::FleetNodes::Waku);
        clusterConfig["FilterNodes"] = getNodes(fleet, Constants::FleetNodes::Waku);
        clusterConfig["LightpushNodes"] = getNodes(fleet, Constants::FleetNodes::Waku);

        nodeConfigJson["ClusterConfig"] = clusterConfig;

        nodeConfigJson["KeyStoreDir"] = toQString(fs::relative(m_keyStoreDir, m_statusgoDataDir));
        return nodeConfigJson;
    }
    catch(std::bad_optional_access)
    {
        return QJsonObject();
    }
}

} // namespace Status::Onboarding
