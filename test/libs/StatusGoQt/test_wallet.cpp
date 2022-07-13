#include <StatusGo/Accounts/AccountsAPI.h>
#include <StatusGo/Wallet/WalletApi.h>
#include <StatusGo/Metadata/api_response.h>

#include <Onboarding/Accounts/AccountsServiceInterface.h>
#include <Onboarding/Common/Constants.h>
#include <Onboarding/OnboardingController.h>

#include <ScopedTestAccount.h>
#include <StatusGo/Utils.h>

#include <gtest/gtest.h>

namespace Wallet = Status::StatusGo::Wallet;
namespace Utils = Status::StatusGo::Utils;

namespace fs = std::filesystem;

/// \warning for now this namespace contains integration test to check the basic assumptions of status-go while building the C++ wrapper.
/// \warning the tests depend on IO and are not deterministic, fast, focused or reliable. They are here for validation only
/// \todo after status-go API coverage all the integration tests should go away and only test the thin wrapper code
namespace Status::Testing {

TEST(WalletApi, TestGetDerivedAddressesForPath)
{
    constexpr auto testRootAccountName = "test_root_account-name";
    constexpr auto testAccountPassword = "password*";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName, testAccountPassword, true);

    const auto walletAccount = testAccount.firstWalletAccount();
    const auto chatAccount = testAccount.firstChatAccount();
    const auto rootAccount = testAccount.onboardingController()->accountsService()->getLoggedInAccount();
    ASSERT_EQ(rootAccount.address, walletAccount.derivedFrom.value());

    const auto password{Utils::hashPassword(testAccountPassword)};
    const auto testPath = Status::Constants::General::PathWalletRoot;

    // chatAccount.address
    const auto chatDerivedAddresses = Wallet::getDerivedAddressesForPath(password, chatAccount.address, testPath, 3, 1);
    // Check that no change is done
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 2);

    ASSERT_EQ(chatDerivedAddresses.size(), 3);
    // all alreadyCreated are false
    ASSERT_TRUE(std::none_of(chatDerivedAddresses.begin(), chatDerivedAddresses.end(), [](const auto& a) { return a.alreadyCreated; }));
    // all hasActivity are false
    ASSERT_TRUE(std::none_of(chatDerivedAddresses.begin(), chatDerivedAddresses.end(), [](const auto& a) { return a.hasActivity; }));
    // all address are valid
    ASSERT_TRUE(std::none_of(chatDerivedAddresses.begin(), chatDerivedAddresses.end(), [](const auto& a) { return a.address.get().isEmpty(); }));

    const auto walletDerivedAddresses = Wallet::getDerivedAddressesForPath(password, walletAccount.address, testPath, 2, 1);
    ASSERT_EQ(walletDerivedAddresses.size(), 2);
    // all alreadyCreated are false
    ASSERT_TRUE(std::none_of(walletDerivedAddresses.begin(), walletDerivedAddresses.end(), [](const auto& a) { return a.alreadyCreated; }));

    const auto rootDerivedAddresses = Wallet::getDerivedAddressesForPath(password, rootAccount.address, testPath, 4, 1);
    ASSERT_EQ(rootDerivedAddresses.size(), 4);
    ASSERT_EQ(std::count_if(rootDerivedAddresses.begin(), rootDerivedAddresses.end(), [](const auto& a) { return a.alreadyCreated; }), 1);
    const auto &existingAddress = *std::find_if(rootDerivedAddresses.begin(), rootDerivedAddresses.end(), [](const auto& a) { return a.alreadyCreated; });
    ASSERT_EQ(existingAddress.address, walletAccount.address);
    ASSERT_FALSE(existingAddress.hasActivity);
}

} // namespace
