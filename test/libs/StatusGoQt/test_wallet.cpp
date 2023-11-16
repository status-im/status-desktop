#include <StatusGo/SignalsManager.h>

#include <StatusGo/Accounts/AccountsAPI.h>

#include <StatusGo/Wallet/Transfer/Event.h>
#include <StatusGo/Wallet/WalletApi.h>
#include <StatusGo/Wallet/wallet_types.h>

#include <StatusGo/Metadata/api_response.h>

#include <Onboarding/Accounts/AccountsService.h>
#include <Onboarding/Accounts/AccountsServiceInterface.h>
#include <Onboarding/Common/Constants.h>
#include <Onboarding/OnboardingController.h>

#include <ScopedTestAccount.h>
#include <StatusGo/Utils.h>

#include <chrono>
#include <gtest/gtest.h>

namespace Wallet = Status::StatusGo::Wallet;
namespace Accounts = Status::StatusGo::Accounts;
namespace Utils = Status::StatusGo::Utils;
namespace General = Status::Constants::General;

namespace fs = std::filesystem;

using namespace std::chrono_literals;

/// \warning for now this namespace contains integration test to check the basic assumptions of status-go while building the C++ wrapper.
/// \warning the tests depend on IO and are not deterministic, fast, focused or reliable. They are here for validation only
/// \todo after status-go API coverage all the integration tests should go away and only test the thin wrapper code
namespace Status::Testing
{

TEST(WalletApi, TestGetDerivedAddressesForPath_FromRootAccount)
{
    constexpr auto testRootAccountName = "test_root_account-name";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName);

    const auto walletAccount = testAccount.firstWalletAccount();
    const auto rootAccount = testAccount.onboardingController()->accountsService()->getLoggedInAccount();
    ASSERT_EQ(rootAccount.address, walletAccount.derivedFrom.value());

    const auto testPath = General::PathWalletRoot;

    const auto derivedAddresses = Wallet::getDerivedAddressesForPath(
        testAccount.hashedPassword(), walletAccount.derivedFrom.value(), testPath, 3, 1);
    // Check that accounts are generated in memory and none is saved
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 2);

    ASSERT_EQ(derivedAddresses.size(), 3);
    auto defaultWalletAccountIt =
        std::find_if(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.alreadyCreated; });
    ASSERT_NE(defaultWalletAccountIt, derivedAddresses.end());
    const auto& defaultWalletAccount = *defaultWalletAccountIt;
    ASSERT_EQ(defaultWalletAccount.path, General::PathDefaultWallet);
    ASSERT_EQ(defaultWalletAccount.address, walletAccount.address);
    ASSERT_TRUE(defaultWalletAccount.alreadyCreated);

    ASSERT_EQ(1, std::count_if(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) {
                  return a.alreadyCreated;
              }));
    // all hasActivity are false
    ASSERT_TRUE(
        std::none_of(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.hasActivity; }));
    // all address are valid
    ASSERT_TRUE(std::none_of(
        derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.address.get().isEmpty(); }));
}

TEST(Accounts, TestGetDerivedAddressesForPath_AfterLogin)
{
    constexpr auto testRootAccountName = "test-generate_account_with_derived_path-name";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName);

    testAccount.logOut();

    auto accountsService = std::make_shared<Onboarding::AccountsService>();
    auto result = accountsService->init(testAccount.testDataDir());
    ASSERT_TRUE(result);
    auto onboarding = std::make_shared<Onboarding::OnboardingController>(accountsService);
    EXPECT_EQ(onboarding->getOpenedAccounts().size(), 1);

    auto accounts = accountsService->openAndListAccounts();
    ASSERT_GT(accounts.size(), 0);

    int accountLoggedInCount = 0;
    QObject::connect(onboarding.get(), &Onboarding::OnboardingController::accountLoggedIn, [&accountLoggedInCount]() {
        accountLoggedInCount++;
    });
    bool accountLoggedInError = false;
    QObject::connect(onboarding.get(),
                     &Onboarding::OnboardingController::accountLoginError,
                     [&accountLoggedInError](const QString& error) {
                         accountLoggedInError = true;
                         qDebug() << "Failed logging in in test" << test_info_->name() << "with error:" << error;
                     });

    auto ourAccountRes = std::find_if(accounts.begin(), accounts.end(), [testRootAccountName](const auto& a) {
        return a.name == testRootAccountName;
    });
    auto errorString = accountsService->login(*ourAccountRes, testAccount.password());
    ASSERT_EQ(errorString.length(), 0);

    testAccount.processMessages(1000, [&accountLoggedInCount, &accountLoggedInError]() {
        return accountLoggedInCount == 0 && !accountLoggedInError;
    });
    ASSERT_EQ(accountLoggedInCount, 1);
    ASSERT_EQ(accountLoggedInError, 0);

    const auto testPath = General::PathWalletRoot;

    const auto walletAccount = testAccount.firstWalletAccount();
    const auto derivedAddresses = Wallet::getDerivedAddressesForPath(
        testAccount.hashedPassword(), walletAccount.derivedFrom.value(), testPath, 3, 1);
    // Check that accounts are generated in memory and none is saved
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 2);

    ASSERT_EQ(derivedAddresses.size(), 3);
    auto defaultWalletAccountIt =
        std::find_if(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.alreadyCreated; });
    ASSERT_NE(defaultWalletAccountIt, derivedAddresses.end());
    const auto& defaultWalletAccount = *defaultWalletAccountIt;
    ASSERT_EQ(defaultWalletAccount.path, General::PathDefaultWallet);
    ASSERT_EQ(defaultWalletAccount.address, walletAccount.address);
    ASSERT_TRUE(defaultWalletAccount.alreadyCreated);

    ASSERT_EQ(1, std::count_if(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) {
                  return a.alreadyCreated;
              }));
    // all hasActivity are false
    ASSERT_TRUE(
        std::none_of(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.hasActivity; }));
    // all address are valid
    ASSERT_TRUE(std::none_of(
        derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.address.get().isEmpty(); }));
}

/// getDerivedAddresses@api.go fron statys-go has a special case when requesting the 6 path will return only one account
TEST(WalletApi, TestGetDerivedAddressesForPath_FromWalletAccount_FirstLevel_SixPathSpecialCase)
{
    constexpr auto testRootAccountName = "test_root_account-name";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName);

    const auto walletAccount = testAccount.firstWalletAccount();

    const auto testPath = General::PathDefaultWallet;

    const auto derivedAddresses =
        Wallet::getDerivedAddressesForPath(testAccount.hashedPassword(), walletAccount.address, testPath, 4, 1);
    ASSERT_EQ(derivedAddresses.size(), 1);
    const auto& onlyAccount = derivedAddresses[0];
    // all alreadyCreated are false
    ASSERT_FALSE(onlyAccount.alreadyCreated);
    ASSERT_EQ(onlyAccount.path, General::PathDefaultWallet);
}

TEST(WalletApi, TestGetDerivedAddressesForPath_FromWalletAccount_SecondLevel)
{
    constexpr auto testRootAccountName = "test_root_account-name";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName);

    const auto walletAccount = testAccount.firstWalletAccount();
    const auto firstLevelPath = General::PathDefaultWallet;
    const auto firstLevelAddresses =
        Wallet::getDerivedAddressesForPath(testAccount.hashedPassword(), walletAccount.address, firstLevelPath, 4, 1);

    const auto testPath = Accounts::DerivationPath{General::PathDefaultWallet.get() + u"/0"_qs};

    const auto derivedAddresses =
        Wallet::getDerivedAddressesForPath(testAccount.hashedPassword(), walletAccount.address, testPath, 4, 1);
    ASSERT_EQ(derivedAddresses.size(), 4);

    // all alreadyCreated are false
    ASSERT_TRUE(
        std::none_of(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.alreadyCreated; }));
    // all hasActivity are false
    ASSERT_TRUE(
        std::none_of(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.hasActivity; }));
    // all address are valid
    ASSERT_TRUE(std::none_of(
        derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.address.get().isEmpty(); }));
    ASSERT_TRUE(std::all_of(derivedAddresses.begin(), derivedAddresses.end(), [testPath](const auto& a) {
        return a.path.get().startsWith(testPath.get());
    }));
}

TEST(WalletApi, TestGetEthereumChains)
{
    ScopedTestAccount testAccount(test_info_->name());

    auto networks = Wallet::getEthereumChains(false);
    ASSERT_GT(networks.size(), 0);
    const auto& network = networks[0];
    ASSERT_FALSE(network.chainName.isEmpty());
    ASSERT_TRUE(network.rpcUrl.isValid());
}

TEST(WalletApi, TestGetTokens)
{
    ScopedTestAccount testAccount(test_info_->name());

    auto networks = Wallet::getEthereumChains(false);
    ASSERT_GT(networks.size(), 0);
    auto mainNetIt =
        std::find_if(networks.begin(), networks.end(), [](const auto& n) { return n.chainName == "Ethereum Mainnet"; });
    ASSERT_NE(mainNetIt, networks.end());
    const auto& mainNet = *mainNetIt;

    auto tokens = Wallet::getTokens(mainNet.chainId);

    auto sntIt = std::find_if(tokens.begin(), tokens.end(), [](const auto& t) { return t.symbol == "SNT"; });
    ASSERT_NE(sntIt, tokens.end());
    const auto& snt = *sntIt;
    ASSERT_EQ(snt.chainId, mainNet.chainId);
    ASSERT_TRUE(snt.color.isValid());
}

TEST(WalletApi, TestGetTokensBalancesForChainIDs)
{
    ScopedTestAccount testAccount(test_info_->name());

    auto networks = Wallet::getEthereumChains(false);
    ASSERT_GT(networks.size(), 1);

    auto mainNetIt =
        std::find_if(networks.begin(), networks.end(), [](const auto& n) { return n.chainName == "Ethereum Mainnet"; });
    ASSERT_NE(mainNetIt, networks.end());
    const auto& mainNet = *mainNetIt;

    auto mainTokens = Wallet::getTokens(mainNet.chainId);
    auto sntMainIt =
        std::find_if(mainTokens.begin(), mainTokens.end(), [](const auto& t) { return t.symbol == "SNT"; });
    ASSERT_NE(sntMainIt, mainTokens.end());
    const auto& sntMain = *sntMainIt;

    auto testNetIt =
        std::find_if(networks.begin(), networks.end(), [](const auto& n) { return n.chainName == "Ropsten"; });
    ASSERT_NE(testNetIt, networks.end());
    const auto& testNet = *testNetIt;

    auto testTokens = Wallet::getTokens(testNet.chainId);
    auto sntTestIt =
        std::find_if(testTokens.begin(), testTokens.end(), [](const auto& t) { return t.symbol == "STT"; });
    ASSERT_NE(sntTestIt, testTokens.end());
    const auto& sntTest = *sntTestIt;

    auto testAddress = testAccount.firstWalletAccount().address;
    auto balances = Wallet::getTokensBalancesForChainIDs(
        {mainNet.chainId, testNet.chainId}, {testAddress}, {sntMain.address, sntTest.address});
    ASSERT_GT(balances.size(), 0);

    ASSERT_TRUE(balances.contains(testAddress));
    const auto& addressBalance = balances[testAddress];
    ASSERT_GT(addressBalance.size(), 0);

    ASSERT_TRUE(addressBalance.contains(sntMain.address));
    ASSERT_EQ(toQString(addressBalance.at(sntMain.address)), "0");

    ASSERT_TRUE(addressBalance.contains(sntTest.address));
    ASSERT_EQ(toQString(addressBalance.at(sntTest.address)), "0");
}

struct TestNetwork
{
    QString name;
    bool isTest;
};

struct TestParams
{
    Accounts::EOAddress walletAddress;
    std::vector<TestNetwork> networks;
    QString token;
    QString newTestAccountName;
};

static const std::vector<TestParams> allTestParams{
    // [0] - Goerli ERC20 token test account set
    TestParams{Accounts::EOAddress("0x586e3bd2c40b0f243162ea563a1f43ae9ef25ef9"),
               {{QString("Goerli"), true}},
               QString("USDC"),
               u"test_watch_only-name"_qs},
    // [1] - Main net ERC20 token test account set
    TestParams{Accounts::EOAddress("0xae0c364acb9b105766fea91cfa5aaea31a1821c1"),
               {{QString("Ethereum Mainnet"), false}},
               QString("SNT"),
               u"test_watch_only-name"_qs},
    // [2] - Main net native token account set
    TestParams{Accounts::EOAddress("0x0182e671dfd5f7d21b13714cbe9f92d26b59eeb9"),
               {{QString("Ethereum Mainnet"), false}},
               QString("USDC"),
               u"test_watch_only-name"_qs},
    // [3] - Main net ERC20 test account set
    TestParams{Accounts::EOAddress("0x473780deAF4a2Ac070BBbA936B0cdefe7F267dFc"),
               {{QString("Ethereum Mainnet"), false}},
               QString("ETH"),
               u"test_watch_only-name"_qs},
    // [4] - Arbitrum Goerli native token test account set
    TestParams{Accounts::EOAddress("0xE2d622C817878dA5143bBE06866ca8E35273Ba8a"),
               {{QString("Arbitrum Goerli"), true}, {QString("Goerli"), true}},
               QString("ETH"),
               u"test_watch_only-name"_qs},
};

TestParams getTestParams()
{
    return allTestParams[4];
}

TEST(WalletApi, TestGetTokensBalancesForChainIDs_WatchOnlyAccount)
{
    ScopedTestAccount testAccount(test_info_->name());

    const auto params = getTestParams();

    Accounts::addAccountWatch(Accounts::EOAddress("0xdb5ac1a559b02e12f29fc0ec0e37be8e046def49"),
                              params.newTestAccountName,
                              QColor("fuchsia"),
                              u""_qs);
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 3);

    const auto newAccountIt = std::find_if(updatedAccounts.begin(), updatedAccounts.end(), [&params](const auto& a) {
        return a.name == params.newTestAccountName;
    });
    ASSERT_NE(newAccountIt, updatedAccounts.end());
    const auto& newAccount = *newAccountIt;

    auto networks = Wallet::getEthereumChains(false);
    ASSERT_GT(networks.size(), 1);

    auto mainNetIt =
        std::find_if(networks.begin(), networks.end(), [](const auto& n) { return n.chainName == "Ethereum Mainnet"; });
    ASSERT_NE(mainNetIt, networks.end());
    const auto& mainNet = *mainNetIt;

    auto mainTokens = Wallet::getTokens(mainNet.chainId);
    auto sntMainIt =
        std::find_if(mainTokens.begin(), mainTokens.end(), [](const auto& t) { return t.symbol == "SNT"; });
    ASSERT_NE(sntMainIt, mainTokens.end());
    const auto& sntMain = *sntMainIt;

    auto balances = Wallet::getTokensBalancesForChainIDs({mainNet.chainId}, {newAccount.address}, {sntMain.address});
    ASSERT_GT(balances.size(), 0);

    ASSERT_TRUE(balances.contains(newAccount.address));
    const auto& addressBalance = balances[newAccount.address];
    ASSERT_GT(addressBalance.size(), 0);

    ASSERT_TRUE(addressBalance.contains(sntMain.address));
    ASSERT_GT(addressBalance.at(sntMain.address), 0);
}

TEST(WalletApi, TestCheckRecentHistory)
{
    ScopedTestAccount testAccount(test_info_->name());

    const auto params = getTestParams();

    // Add watch account
    Accounts::addAccountWatch(Accounts::EOAddress("0xe74E17D586227691Cb7b64ed78b1b7B14828B034"),
                              params.newTestAccountName,
                              QColor("fuchsia"),
                              u""_qs);
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 3);

    const auto newAccountIt = std::find_if(updatedAccounts.begin(), updatedAccounts.end(), [&params](const auto& a) {
        return a.name == params.newTestAccountName;
    });
    ASSERT_NE(newAccountIt, updatedAccounts.end());
    const auto& newAccount = *newAccountIt;

    bool startedTransferFetching = false;
    bool historyReady = false;
    QObject::connect(StatusGo::SignalsManager::instance(),
                     &StatusGo::SignalsManager::wallet,
                     testAccount.app(),
                     [&startedTransferFetching, &historyReady](QSharedPointer<StatusGo::EventData> data) {
                         Wallet::Transfer::Event event = data->eventInfo();
                         if(event.type == Wallet::Transfer::Events::FetchingRecentHistory)
                             startedTransferFetching = true;
                         else if(event.type == Wallet::Transfer::Events::RecentHistoryReady)
                             historyReady = true;
                         // Wallet::Transfer::Events::NewTransfers might not be emitted if there is no intermediate transfers
                     });

    Wallet::checkRecentHistory({newAccount.address});

    testAccount.processMessages(50000, [&historyReady]() { return !historyReady; });

    ASSERT_TRUE(startedTransferFetching);
    ASSERT_TRUE(historyReady);
}

TEST(WalletApi, TestGetBalanceHistory)
{
    ScopedTestAccount testAccount(test_info_->name());

    const auto params = getTestParams();

    Accounts::addAccountWatch(params.walletAddress, params.newTestAccountName, QColor("fuchsia"), u""_qs);
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 3);

    auto networks = Wallet::getEthereumChains(false);
    ASSERT_GT(networks.size(), 0);

    std::vector<Wallet::ChainID> chainIDs;
    for(const auto& net : params.networks)
    {
        auto netIt = std::find_if(networks.begin(), networks.end(), [&net](const auto& n) {
            return n.chainName == net.name && n.isTest == net.isTest;
        });
        ASSERT_NE(netIt, networks.end());
        chainIDs.push_back(netIt->chainId);

        auto nativeIt = std::find_if(networks.begin(), networks.end(), [&params](const auto& n) {
            return n.nativeCurrencySymbol == params.token;
        });
        if(nativeIt == networks.end())
        {
            auto tokens = Wallet::getTokens(netIt->chainId);
            auto tokenIt = std::find_if(
                tokens.begin(), tokens.end(), [&params](const auto& t) { return t.symbol == params.token; });
            ASSERT_NE(tokenIt, tokens.end());
        }
    }

    const auto newAccountIt = std::find_if(updatedAccounts.begin(), updatedAccounts.end(), [&params](const auto& a) {
        return a.name == params.newTestAccountName;
    });
    ASSERT_NE(newAccountIt, updatedAccounts.end());
    const auto& newAccount = *newAccountIt;

    auto testIntervals = {Wallet::BalanceHistoryTimeInterval::BalanceHistory7Hours,
                          Wallet::BalanceHistoryTimeInterval::BalanceHistory1Month,
                          Wallet::BalanceHistoryTimeInterval::BalanceHistory6Months,
                          Wallet::BalanceHistoryTimeInterval::BalanceHistory1Year,
                          Wallet::BalanceHistoryTimeInterval::BalanceHistoryAllTime};

    std::map<Wallet::BalanceHistoryTimeInterval, QString> testIntervalsStrs{
        {Wallet::BalanceHistoryTimeInterval::BalanceHistory7Hours, "7H"},
        {Wallet::BalanceHistoryTimeInterval::BalanceHistory1Month, "1M"},
        {Wallet::BalanceHistoryTimeInterval::BalanceHistory6Months, "6M"},
        {Wallet::BalanceHistoryTimeInterval::BalanceHistory1Year, "1Y"},
        {Wallet::BalanceHistoryTimeInterval::BalanceHistoryAllTime, "All"}};

    // Fetch first and watch for finished signal of newAccount.address
    int bhStartedReceivedCount = 0;
    int bhEndedReceivedCount = 0;
    int bhErrorReceivedCount = 0;
    bool targetAccountDone = false;
    QObject::connect(
        StatusGo::SignalsManager::instance(),
        &StatusGo::SignalsManager::wallet,
        testAccount.app(),
        [&targetAccountDone, &bhStartedReceivedCount, &bhEndedReceivedCount, &bhErrorReceivedCount, &newAccount](
            QSharedPointer<StatusGo::EventData> data) {
            Wallet::Transfer::Event event = data->eventInfo();
            if(event.type == Wallet::Transfer::Events::EventBalanceHistoryUpdateStarted)
            {
                bhStartedReceivedCount++;
            }
            else if(event.type == Wallet::Transfer::Events::EventBalanceHistoryUpdateFinished)
            {
                bhEndedReceivedCount++;
                if(event.accounts)
                {
                    auto found = std::find_if(event.accounts.value().begin(),
                                              event.accounts.value().end(),
                                              [&event, &newAccount](const auto& a) { return a == newAccount.address; });
                    if(found != event.accounts.value().end())
                    {
                        targetAccountDone = true;
                    }
                }
            }
            else if(event.type == Wallet::Transfer::Events::EventBalanceHistoryUpdateFinishedWithError)
            {
                bhErrorReceivedCount++;
            }
        });

    std::vector<QString> symbols{params.token};
    Wallet::updateVisibleTokens(symbols);

    Wallet::startWallet();

    testAccount.processMessages(2400000, [&targetAccountDone, &bhEndedReceivedCount, &bhErrorReceivedCount]() {
        return !targetAccountDone && bhEndedReceivedCount < 2 && bhErrorReceivedCount < 1;
    });
    ASSERT_GT(bhStartedReceivedCount, 0);
    ASSERT_EQ(bhErrorReceivedCount, 0);
    ASSERT_GT(bhEndedReceivedCount, 0);
    ASSERT_TRUE(targetAccountDone);

    for(const auto& historyInterval : testIntervals)
    {
        auto balanceHistory = Wallet::getBalanceHistory(chainIDs, newAccount.address, params.token, historyInterval);
        ASSERT_GT(balanceHistory.size(), 0);

        auto weiToEth = [](const StatusGo::Wallet::BigInt& wei) -> double {
            StatusGo::Wallet::BigInt q; // wei / eth
            StatusGo::Wallet::BigInt r; // wei % eth
            auto weiD = StatusGo::Wallet::BigInt("1000000000000000000");
            boost::multiprecision::divide_qr(wei, weiD, q, r);
            StatusGo::Wallet::BigInt rSzabos; // r / szaboD
            StatusGo::Wallet::BigInt qSzabos; // r % szaboD
            auto szaboD = StatusGo::Wallet::BigInt("1000000000000");
            boost::multiprecision::divide_qr(r, szaboD, qSzabos, rSzabos);
            return q.convert_to<double>() + (qSzabos.convert_to<double>() / ((weiD / szaboD).convert_to<double>()));
        };

        auto fileInfo = QFileInfo(
            QString("/tmp/StatusTests/balance/balance_history-%1.csv").arg(testIntervalsStrs[historyInterval]));
        QFile file(fileInfo.absoluteFilePath());
        QDir().mkpath(fileInfo.absolutePath());
        if(file.open(QIODevice::WriteOnly | QIODevice::Text))
        {
            QTextStream out(&file);
            out << "Balance, Timestamp, Block Number, Formatted Date" << Qt::endl;
            for(int i = 0; i < balanceHistory.size(); ++i)
            {
                out << weiToEth(balanceHistory[i].value) << "," << balanceHistory[i].time.toSecsSinceEpoch() << ","
                    << balanceHistory[i].blockNumber.str().c_str() << ","
                    << balanceHistory[i].time.toString("dd.MM.yyyy hh:mm:ss") << Qt::endl;
            }
            file.close();
        }
    }
}

TEST(WalletApi, TestStartWallet)
{
    ScopedTestAccount testAccount(test_info_->name());

    auto params = getTestParams();

    // Add watch account
    Accounts::addAccountWatch(Accounts::EOAddress("0xF38D2CD3C6Ad02dD6f8B68E0A7b2f959819954b6"),
                              params.newTestAccountName,
                              QColor("fuchsia"),
                              u""_qs);
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 3);

    int bhStartedReceivedCount = 0;
    int bhEndedReceivedCount = 0;
    int bhErrorReceivedCount = 0;
    QObject::connect(StatusGo::SignalsManager::instance(),
                     &StatusGo::SignalsManager::wallet,
                     testAccount.app(),
                     [&bhStartedReceivedCount, &bhEndedReceivedCount, &bhErrorReceivedCount](
                         QSharedPointer<StatusGo::EventData> data) {
                         Wallet::Transfer::Event event = data->eventInfo();
                         if(event.type == Wallet::Transfer::Events::EventBalanceHistoryUpdateStarted)
                         {
                             bhStartedReceivedCount++;
                         }
                         else if(event.type == Wallet::Transfer::Events::EventBalanceHistoryUpdateFinished)
                         {
                             bhEndedReceivedCount++;
                         }
                         else if(event.type == Wallet::Transfer::Events::EventBalanceHistoryUpdateFinishedWithError)
                         {
                             bhErrorReceivedCount++;
                         }
                     });

    std::vector<QString> symbols{params.token};
    Wallet::updateVisibleTokens(symbols);

    Wallet::startWallet();

    testAccount.processMessages(240000, [&bhEndedReceivedCount, &bhErrorReceivedCount]() {
        return bhEndedReceivedCount < 2 && bhErrorReceivedCount < 1;
    });
    ASSERT_EQ(bhStartedReceivedCount, 2);
    ASSERT_EQ(bhErrorReceivedCount, 0);
    ASSERT_EQ(bhEndedReceivedCount, 2);
}

TEST(WalletApi, TestStopBalanceHistory)
{
    ScopedTestAccount testAccount(test_info_->name());

    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 2);

    int bhStartedReceivedCount = 0;
    int bhEndedReceivedCount = 0;
    int bhErrorReceivedCount = 0;
    QString stopMessage;
    QObject::connect(StatusGo::SignalsManager::instance(),
                     &StatusGo::SignalsManager::wallet,
                     testAccount.app(),
                     [&stopMessage, &bhStartedReceivedCount, &bhEndedReceivedCount, &bhErrorReceivedCount](
                         QSharedPointer<StatusGo::EventData> data) {
                         Wallet::Transfer::Event event = data->eventInfo();
                         if(event.type == Wallet::Transfer::Events::EventBalanceHistoryUpdateStarted)
                         {
                             bhStartedReceivedCount++;
                         }
                         else if(event.type == Wallet::Transfer::Events::EventBalanceHistoryUpdateFinished)
                         {
                             stopMessage = event.message;
                             bhEndedReceivedCount++;
                         }
                         else if(event.type == Wallet::Transfer::Events::EventBalanceHistoryUpdateFinishedWithError)
                         {
                             bhErrorReceivedCount++;
                         }
                     });
    Wallet::updateVisibleTokens({QString("ETH")});

    Wallet::startWallet();

    bool stopCalled = false;
    testAccount.processMessages(5000,
                                [&stopCalled, &bhStartedReceivedCount, &bhEndedReceivedCount, &bhErrorReceivedCount]() {
                                    if(bhStartedReceivedCount == 1 && !stopCalled)
                                    {
                                        stopCalled = true;
                                        std::this_thread::sleep_for(std::chrono::seconds(1));
                                        Wallet::stopWallet();
                                    }
                                    return bhEndedReceivedCount < 1 && bhErrorReceivedCount < 1;
                                });
    ASSERT_EQ(bhStartedReceivedCount, 1);
    ASSERT_EQ(bhErrorReceivedCount, 0);
    ASSERT_EQ(bhEndedReceivedCount, 1);
    ASSERT_EQ("Service canceled", stopMessage);

    stopMessage = "";

    // Do an empty run
    Wallet::updateVisibleTokens({});

    Wallet::stopWallet();

    stopCalled = false;
    testAccount.processMessages(1000,
                                [&stopCalled, &bhStartedReceivedCount, &bhEndedReceivedCount, &bhErrorReceivedCount]() {
                                    return bhEndedReceivedCount < 2 && bhErrorReceivedCount < 2;
                                });

    ASSERT_EQ(bhStartedReceivedCount, 2);
    ASSERT_EQ(bhErrorReceivedCount, 0);
    ASSERT_EQ(bhEndedReceivedCount, 2);
    ASSERT_EQ("", stopMessage);
}

} // namespace Status::Testing
