#include "StatusServices/Accounts/Service.h"

#include "StatusBackend/Accounts.h"
#include "StatusBackend/Utils.h"

using namespace Status::Accounts;

Service::Service()
    : m_isFirstTimeAccountLogin(false)
{
}

void Service::init(const QString& statusgoDataDir)
{
    m_statusgoDataDir = statusgoDataDir;
    auto response = Backend::Accounts::generateAddresses(Constants::General::AccountDefaultPaths);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return;
    }

    foreach(const auto& genAddressObj, response.result)
    {
        auto gAcc = GeneratedAccountDto::toGeneratedAccountDto(genAddressObj.toObject());
        gAcc.alias = generateAlias(gAcc.derivedAccounts.whisper.publicKey);
        gAcc.identicon = generateIdenticon(gAcc.derivedAccounts.whisper.publicKey);
        m_generatedAccounts.append(std::move(gAcc));
    }
}

QVector<AccountDto> Service::openedAccounts()
{
    auto response = Backend::Accounts::openAccounts(m_statusgoDataDir);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return QVector<AccountDto>();
    }

    QJsonArray multiAccounts = response.result;
    QVector<AccountDto> result;
    foreach(const auto& value, multiAccounts)
    {
        result << AccountDto::toAccountDto(value.toObject());
    }
    return result;
}

const QVector<GeneratedAccountDto>& Service::generatedAccounts() const
{
    return m_generatedAccounts;
}

bool Service::setupAccount(const QString& accountId, const QString& password)
{
    QString installationId(QUuid::createUuid().toString(QUuid::WithoutBraces));
    QJsonObject accountData(getAccountDataForAccountId(accountId));
    QJsonArray subAccountData(getSubaccountDataForAccountId(accountId));
    QJsonObject settings(getAccountSettings(accountId, installationId));
    QJsonObject nodeConfig(getDefaultNodeConfig(installationId));

    QString hashedPassword(Backend::Utils::hashString(password));

    Service::storeDerivedAccounts(accountId, hashedPassword, Constants::General::AccountDefaultPaths);

    m_loggedInAccount = saveAccountAndLogin(hashedPassword, accountData, subAccountData, settings, nodeConfig);

    return getLoggedInAccount().isValid();
}

const AccountDto& Service::getLoggedInAccount() const
{
    return m_loggedInAccount;
}

const GeneratedAccountDto& Service::getImportedAccount() const
{
    return m_importedAccount;
}

bool Service::isFirstTimeAccountLogin() const
{
    return m_isFirstTimeAccountLogin;
}

QString Service::validateMnemonic(const QString& mnemonic)
{
    // TODO:
    return "";
}

bool Service::importMnemonic(const QString& mnemonic)
{
    // TODO:
    return false;
}

QString Service::login(AccountDto account, const QString& password)
{
    QString hashedPassword(Backend::Utils::hashString(password));

    QString thumbnailImage;
    QString largeImage;

    foreach(const Image& img, account.images)
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

    auto response = Backend::Accounts::login(account.name, account.keyUid, hashedPassword, account.identicon,
                                             thumbnailImage, largeImage);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return QString();
    }

    qInfo() << "Account logged in";

    m_loggedInAccount = std::move(account);

    return QString();
}

void Service::clear()
{
    m_generatedAccounts.clear();
    m_loggedInAccount = AccountDto();
    m_importedAccount = GeneratedAccountDto();
    m_isFirstTimeAccountLogin = false;
}

QString Service::generateAlias(const QString& publicKey)
{
    auto response = Backend::Accounts::generateAlias(publicKey);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return QString();
    }

    return response.result;
}

QString Service::generateIdenticon(const QString& publicKey)
{
    auto response = Backend::Accounts::generateIdenticon(publicKey);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return QString();
    }

    return response.result;
}

bool Service::verifyAccountPassword(const QString& account, const QString& password)
{
    // TODO:
    return false;
}

DerivedAccounts Service::storeDerivedAccounts(const QString& accountId, const QString& hashedPassword,
                                              const QVector<QString>& paths)
{
    auto response = Backend::Accounts::storeDerivedAccounts(accountId, hashedPassword, paths);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return DerivedAccounts();
    }
    return DerivedAccounts::toDerivedAccounts(response.result);
}

AccountDto Service::saveAccountAndLogin(const QString& hashedPassword, const QJsonObject& account,
                                        const QJsonArray& subaccounts, const QJsonObject& settings,
                                        const QJsonObject& config)
{
    auto response = Backend::Accounts::saveAccountAndLogin(hashedPassword, account, subaccounts, settings, config);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return AccountDto();
    }

    m_isFirstTimeAccountLogin = true;
    return AccountDto::toAccountDto(response.result);
}

QJsonObject Service::prepareAccountJsonObject(const GeneratedAccountDto& account) const
{
    return QJsonObject{{"name", account.alias},
        {"address", account.address},
        {"photo-path", account.identicon},
        {"identicon", account.identicon},
        {"key-uid", account.keyUid},
        {"keycard-pairing", QJsonValue()}};
}

QJsonObject Service::getAccountDataForAccountId(const QString& accountId) const
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

    qDebug() << "account not found";
    return QJsonObject();
}

QJsonArray Service::prepareSubaccountJsonObject(const GeneratedAccountDto& account) const
{
    return QJsonArray{
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
            {"name", account.alias},
            {"identicon", account.identicon},
            {"chat", true}
        }
    };
}

QJsonArray Service::getSubaccountDataForAccountId(const QString& accountId) const
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

    qDebug() << "account not found";
    return QJsonArray();
}

QString Service::generateSigningPhrase(const int count) const
{
    QStringList words;
    for(int i = 0; i < count; i++)
    {
        words.append(Constants::SigningPhrases[QRandomGenerator::global()->bounded(
                    static_cast<int>(Constants::SigningPhrases.size()))]);
    }
    return words.join(" ");
}

QJsonObject Service::prepareAccountSettingsJsonObject(const GeneratedAccountDto& account,
                                                      const QString& installationId) const
{
    QFile defaultNetworks(":/resources/default-networks.json");
    if(!defaultNetworks.open(QIODevice::ReadOnly))
    {
        qDebug() << "unable to open `default-networks.json` for reading";
        return QJsonObject();
    }

    QByteArray readData = defaultNetworks.readAll();
    defaultNetworks.close();

    QString defaultNetworksContent = readData.replace("%INFURA_KEY%", INFURA_KEY);
    QJsonArray defaultNetworksJson = QJsonDocument::fromJson(defaultNetworksContent.toUtf8()).array();

    return QJsonObject{
        {"key-uid", account.keyUid},
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
        {"wallet/visible-tokens", {
                {Constants::General::DefaultNetworkName, QJsonArray{"SNT"}}
            }
        },
        {"appearance", 0},
        {"networks/current-network", Constants::General::DefaultNetworkName},
        {"installation-id", installationId}
    };
}

QJsonObject Service::getAccountSettings(const QString& accountId, const QString& installationId) const
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

QJsonObject Service::getDefaultNodeConfig(const QString& installationId) const
{
    QFile nodeConfig(":/resources/node-config.json");
    if(!nodeConfig.open(QIODevice::ReadOnly))
    {
        qDebug() << "unable to open `node-config.json` for reading";
        return QJsonObject();
    }

    QString nodeConfigContent = nodeConfig.readAll();
    nodeConfig.close();


    QFile fleets(":/resources/fleets.json");
    if(!fleets.open(QIODevice::ReadOnly))
    {
        qDebug() << "unable to open `fleets.json` for reading";
        return QJsonObject();
    }

    QByteArray readFleetData = fleets.readAll();
    fleets.close();


    nodeConfigContent = nodeConfigContent.replace("%INSTALLATIONID%", installationId);
    nodeConfigContent = nodeConfigContent.replace("%INFURA_KEY%", INFURA_KEY);
    QJsonObject nodeConfigJson = QJsonDocument::fromJson(nodeConfigContent.toUtf8()).object();
    QJsonObject clusterConfig = nodeConfigJson["ClusterConfig"].toObject();

    QJsonObject fleetsJson = QJsonDocument::fromJson(readFleetData).object()["fleets"].toObject();
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
}
