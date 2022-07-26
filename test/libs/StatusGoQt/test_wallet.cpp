#include <StatusGo/Accounts/AccountsAPI.h>

#include <StatusGo/Wallet/WalletApi.h>

#include <StatusGo/Metadata/api_response.h>

#include <Onboarding/Accounts/AccountsServiceInterface.h>
#include <Onboarding/Accounts/AccountsService.h>
#include <Onboarding/Common/Constants.h>
#include <Onboarding/OnboardingController.h>

#include <ScopedTestAccount.h>
#include <StatusGo/Utils.h>

#include <gtest/gtest.h>

namespace Wallet = Status::StatusGo::Wallet;
namespace Accounts = Status::StatusGo::Accounts;
namespace Utils = Status::StatusGo::Utils;
namespace General = Status::Constants::General;

namespace fs = std::filesystem;

/// \warning for now this namespace contains integration test to check the basic assumptions of status-go while building the C++ wrapper.
/// \warning the tests depend on IO and are not deterministic, fast, focused or reliable. They are here for validation only
/// \todo after status-go API coverage all the integration tests should go away and only test the thin wrapper code
namespace Status::Testing {

TEST(WalletApi, TestGetDerivedAddressesForPath_FromRootAccount)
{
    constexpr auto testRootAccountName = "test_root_account-name";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName);

    const auto walletAccount = testAccount.firstWalletAccount();
    const auto rootAccount = testAccount.onboardingController()->accountsService()->getLoggedInAccount();
    ASSERT_EQ(rootAccount.address, walletAccount.derivedFrom.value());

    const auto testPath = General::PathWalletRoot;

    const auto derivedAddresses = Wallet::getDerivedAddressesForPath(testAccount.hashedPassword(),
                                                                     walletAccount.derivedFrom.value(), testPath, 3, 1);
    // Check that accounts are generated in memory and none is saved
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 2);

    ASSERT_EQ(derivedAddresses.size(), 3);
    auto defaultWalletAccountIt = std::find_if(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.alreadyCreated; });
    ASSERT_NE(defaultWalletAccountIt, derivedAddresses.end());
    const auto& defaultWalletAccount = *defaultWalletAccountIt;
    ASSERT_EQ(defaultWalletAccount.path, General::PathDefaultWallet);
    ASSERT_EQ(defaultWalletAccount.address, walletAccount.address);
    ASSERT_TRUE(defaultWalletAccount.alreadyCreated);

    ASSERT_EQ(1, std::count_if(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.alreadyCreated; }));
    // all hasActivity are false
    ASSERT_TRUE(std::none_of(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.hasActivity; }));
    // all address are valid
    ASSERT_TRUE(std::none_of(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.address.get().isEmpty(); }));
}

TEST(Accounts, TestGetDerivedAddressesForPath_AfterLogin)
{
    constexpr auto testRootAccountName = "test-generate_account_with_derived_path-name";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName);

    testAccount.logOut();

    auto accountsService = std::make_shared<Onboarding::AccountsService>();
    auto result = accountsService->init(testAccount.fusedTestFolder());
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
    QObject::connect(onboarding.get(), &Onboarding::OnboardingController::accountLoginError, [&accountLoggedInError](const QString& error) {
        accountLoggedInError = true;
        qDebug() << "Failed logging in in test" << test_info_->name() << "with error:" << error;
    });

    auto ourAccountRes = std::find_if(accounts.begin(), accounts.end(), [&testRootAccountName](const auto &a) { return a.name == testRootAccountName; });
    auto errorString = accountsService->login(*ourAccountRes, testAccount.password());
    ASSERT_EQ(errorString.length(), 0);

    testAccount.processMessages(1000, [accountLoggedInCount, accountLoggedInError]() {
        return accountLoggedInCount == 0 && !accountLoggedInError;
    });
    ASSERT_EQ(accountLoggedInCount, 1);
    ASSERT_EQ(accountLoggedInError, 0);

    const auto testPath = General::PathWalletRoot;

    const auto walletAccount = testAccount.firstWalletAccount();
    const auto derivedAddresses = Wallet::getDerivedAddressesForPath(testAccount.hashedPassword(),
                                                                     walletAccount.derivedFrom.value(),
                                                                     testPath, 3, 1);
    // Check that accounts are generated in memory and none is saved
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 2);

    ASSERT_EQ(derivedAddresses.size(), 3);
    auto defaultWalletAccountIt = std::find_if(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.alreadyCreated; });
    ASSERT_NE(defaultWalletAccountIt, derivedAddresses.end());
    const auto& defaultWalletAccount = *defaultWalletAccountIt;
    ASSERT_EQ(defaultWalletAccount.path, General::PathDefaultWallet);
    ASSERT_EQ(defaultWalletAccount.address, walletAccount.address);
    ASSERT_TRUE(defaultWalletAccount.alreadyCreated);

    ASSERT_EQ(1, std::count_if(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.alreadyCreated; }));
    // all hasActivity are false
    ASSERT_TRUE(std::none_of(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.hasActivity; }));
    // all address are valid
    ASSERT_TRUE(std::none_of(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.address.get().isEmpty(); }));
}

/// getDerivedAddresses@api.go fron statys-go has a special case when requesting the 6 path will return only one account
TEST(WalletApi, TestGetDerivedAddressesForPath_FromWalletAccount_FirstLevel_SixPathSpecialCase)
{
    constexpr auto testRootAccountName = "test_root_account-name";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName);

    const auto walletAccount = testAccount.firstWalletAccount();

    const auto testPath = General::PathDefaultWallet;

    const auto derivedAddresses = Wallet::getDerivedAddressesForPath(testAccount.hashedPassword(),
                                                                     walletAccount.address, testPath, 4, 1);
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
    const auto firstLevelAddresses = Wallet::getDerivedAddressesForPath(testAccount.hashedPassword(),
                                                                     walletAccount.address, firstLevelPath, 4, 1);

    const auto testPath = Accounts::DerivationPath{General::PathDefaultWallet.get() + u"/0"_qs};

    const auto derivedAddresses = Wallet::getDerivedAddressesForPath(testAccount.hashedPassword(),
                                                                     walletAccount.address, testPath, 4, 1);
    ASSERT_EQ(derivedAddresses.size(), 4);

    // all alreadyCreated are false
    ASSERT_TRUE(std::none_of(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.alreadyCreated; }));
    // all hasActivity are false
    ASSERT_TRUE(std::none_of(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.hasActivity; }));
    // all address are valid
    ASSERT_TRUE(std::none_of(derivedAddresses.begin(), derivedAddresses.end(), [](const auto& a) { return a.address.get().isEmpty(); }));
    ASSERT_TRUE(std::all_of(derivedAddresses.begin(), derivedAddresses.end(), [&testPath](const auto& a) { return a.path.get().startsWith(testPath.get()); }));
}

TEST(WalletApi, TestGetEthereumChains)
{
    ScopedTestAccount testAccount(test_info_->name());

    auto networks = Wallet::getEthereumChains(false);
    ASSERT_GT(networks.size(), 0);
    const auto &network = networks[0];
    ASSERT_FALSE(network.chainName.isEmpty());
    ASSERT_TRUE(network.rpcUrl.isValid());
}

TEST(WalletApi, TestGetTokens)
{
    ScopedTestAccount testAccount(test_info_->name());

    auto networks = Wallet::getEthereumChains(false);
    ASSERT_GT(networks.size(), 0);
    auto mainNetIt = std::find_if(networks.begin(), networks.end(), [](const auto &n){ return n.chainName == "Mainnet"; });
    ASSERT_NE(mainNetIt, networks.end());
    const auto &mainNet = *mainNetIt;

    auto tokens = Wallet::getTokens(mainNet.chainId);

    auto sntIt = std::find_if(tokens.begin(), tokens.end(), [](const auto &t){ return t.symbol == "SNT"; });
    ASSERT_NE(sntIt, tokens.end());
    const auto &snt = *sntIt;
    ASSERT_EQ(snt.chainId, mainNet.chainId);
    ASSERT_TRUE(snt.color.isValid());
}

TEST(WalletApi, TestGetTokensBalancesForChainIDs)
{
    ScopedTestAccount testAccount(test_info_->name());

    auto networks = Wallet::getEthereumChains(false);
    ASSERT_GT(networks.size(), 1);

    auto mainNetIt = std::find_if(networks.begin(), networks.end(), [](const auto &n){ return n.chainName == "Mainnet"; });
    ASSERT_NE(mainNetIt, networks.end());
    const auto &mainNet = *mainNetIt;

    auto mainTokens = Wallet::getTokens(mainNet.chainId);
    auto sntMainIt = std::find_if(mainTokens.begin(), mainTokens.end(), [](const auto &t){ return t.symbol == "SNT"; });
    ASSERT_NE(sntMainIt, mainTokens.end());
    const auto &sntMain = *sntMainIt;

    auto testNetIt = std::find_if(networks.begin(), networks.end(), [](const auto &n){ return n.chainName == "Ropsten"; });
    ASSERT_NE(testNetIt, networks.end());
    const auto &testNet = *testNetIt;

    auto testTokens = Wallet::getTokens(testNet.chainId);
    auto sntTestIt = std::find_if(testTokens.begin(), testTokens.end(), [](const auto &t){ return t.symbol == "STT"; });
    ASSERT_NE(sntTestIt, testTokens.end());
    const auto &sntTest = *sntTestIt;

    auto testAddress = testAccount.firstWalletAccount().address;
    auto balances = Wallet::getTokensBalancesForChainIDs({mainNet.chainId, testNet.chainId},
                                                         {testAddress},
                                                         {sntMain.address, sntTest.address});
    ASSERT_GT(balances.size(), 0);

    ASSERT_TRUE(balances.contains(testAddress));
    const auto &addressBalance = balances[testAddress];
    ASSERT_GT(addressBalance.size(), 0);

    ASSERT_TRUE(addressBalance.contains(sntMain.address));
    ASSERT_EQ(toQString(addressBalance.at(sntMain.address)), "0");

    ASSERT_TRUE(addressBalance.contains(sntTest.address));
    ASSERT_EQ(toQString(addressBalance.at(sntTest.address)), "0");
}

TEST(WalletApi, TestGetTokensBalancesForChainIDs_WatchOnlyAccount)
{
    ScopedTestAccount testAccount(test_info_->name());

    const auto newTestAccountName = u"test_watch_only-name"_qs;
    Accounts::addAccountWatch(Accounts::EOAddress("0xdb5ac1a559b02e12f29fc0ec0e37be8e046def49"), newTestAccountName, QColor("fuchsia"), u""_qs);
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 3);

    const auto newAccountIt = std::find_if(updatedAccounts.begin(), updatedAccounts.end(),
                                           [&newTestAccountName](const auto& a) {
        return a.name == newTestAccountName;
    });
    ASSERT_NE(newAccountIt, updatedAccounts.end());
    const auto &newAccount = *newAccountIt;

    auto networks = Wallet::getEthereumChains(false);
    ASSERT_GT(networks.size(), 1);

    auto mainNetIt = std::find_if(networks.begin(), networks.end(), [](const auto &n){ return n.chainName == "Mainnet"; });
    ASSERT_NE(mainNetIt, networks.end());
    const auto &mainNet = *mainNetIt;

    auto mainTokens = Wallet::getTokens(mainNet.chainId);
    auto sntMainIt = std::find_if(mainTokens.begin(), mainTokens.end(), [](const auto &t){ return t.symbol == "SNT"; });
    ASSERT_NE(sntMainIt, mainTokens.end());
    const auto &sntMain = *sntMainIt;

    auto balances = Wallet::getTokensBalancesForChainIDs({mainNet.chainId},
                                                         {newAccount.address},
                                                         {sntMain.address});
    ASSERT_GT(balances.size(), 0);

    ASSERT_TRUE(balances.contains(newAccount.address));
    const auto &addressBalance = balances[newAccount.address];
    ASSERT_GT(addressBalance.size(), 0);

    ASSERT_TRUE(addressBalance.contains(sntMain.address));
    ASSERT_GT(addressBalance.at(sntMain.address), 0);
}

// TODO
// "{"jsonrpc":"2.0","id":0,"error":{"code":-32000,"message":"no tokens for this network"}}"

} // namespace
