#include <StatusGo/Accounts/AccountsAPI.h>
#include <StatusGo/Metadata/api_response.h>
#include <StatusGo/Accounts/Accounts.h>

#include <Onboarding/Common/Constants.h>
#include <Onboarding/Accounts/AccountsService.h>
#include <Onboarding/OnboardingController.h>
#include <StatusGo/Utils.h>

#include <StatusGo/SignalsManager.h>

#include <IOTestHelpers.h>
#include <ScopedTestAccount.h>

#include <gtest/gtest.h>



namespace Accounts = Status::StatusGo::Accounts;
namespace StatusGo = Status::StatusGo;
namespace Utils = Status::StatusGo::Utils;

namespace fs = std::filesystem;

namespace Status::Testing {

/// \todo fin a way to test the integration within a test environment. Also how about reusing an existing account
TEST(AccountsAPI, TestGetAccounts)
{
    constexpr auto testAccountName = "test_get_accounts_name";
    ScopedTestAccount testAccount(test_info_->name(), testAccountName);

    const auto accounts = Accounts::getAccounts();
    ASSERT_EQ(accounts.size(), 2);

    const auto chatIt = std::find_if(accounts.begin(), accounts.end(), [](const auto& a) { return a.isChat; });
    ASSERT_NE(chatIt, accounts.end());
    const auto &chatAccount = *chatIt;
    ASSERT_EQ(chatAccount.name, testAccountName);
    ASSERT_FALSE(chatAccount.path.get().isEmpty());
    ASSERT_FALSE(chatAccount.derivedFrom.has_value());

    const auto walletIt = std::find_if(accounts.begin(), accounts.end(), [](const auto& a) { return a.isWallet; });
    ASSERT_NE(walletIt, accounts.end());
    const auto &walletAccount = *walletIt;
    ASSERT_NE(walletAccount.name, testAccountName);
    ASSERT_FALSE(walletAccount.path.get().isEmpty());
    ASSERT_TRUE(walletAccount.derivedFrom.has_value());
}

TEST(Accounts, TestGenerateAccountWithDerivedPath_GenerateTwoAccounts)
{
    constexpr auto testRootAccountName = "test-generate_account_with_derived_path-name";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName);

    const auto newTestWalletAccountNameBase = u"test_generated_new_wallet_account-name"_qs;
    const auto newTestAccountColor = QColor("fuchsia");
    const auto newTestAccountEmoji = u""_qs;
    const auto walletAccount = testAccount.firstWalletAccount();
    for(int i = 1; i < 3; ++i) {
        const auto newTestAccountPath = GoAccounts::DerivationPath(Status::Constants::General::PathWalletRoot.get() + "/" + QString::number(i));
        const auto newTestWalletAccountName = newTestWalletAccountNameBase + QString::number(i);
        Accounts::generateAccountWithDerivedPath(testAccount.hashedPassword(),
                                                 newTestWalletAccountName,
                                                 newTestAccountColor, newTestAccountEmoji,
                                                 newTestAccountPath,
                                                 walletAccount.derivedFrom.value());
    }

    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 4);

    for(int i = 1; i < 3; ++i) {
        const auto newTestWalletAccountName = newTestWalletAccountNameBase + QString::number(i);
        const auto newAccountIt = std::find_if(updatedAccounts.begin(), updatedAccounts.end(),
                                         [&newTestWalletAccountName](const auto& a) {
                                             return a.name == newTestWalletAccountName;
                                         });
        ASSERT_NE(newAccountIt, updatedAccounts.end());
        const auto &acc = newAccountIt;
        ASSERT_FALSE(acc->derivedFrom.has_value());
        ASSERT_FALSE(acc->isWallet);
        ASSERT_FALSE(acc->isChat);
        const auto newTestAccountPath = GoAccounts::DerivationPath(Status::Constants::General::PathWalletRoot.get() + "/" + QString::number(i));
        ASSERT_EQ(newTestAccountPath, acc->path);
    }
}

TEST(Accounts, TestGenerateAccountWithDerivedPath_FailsWithAlreadyExists)
{
    constexpr auto testRootAccountName = "test-generate_account_with_derived_path-name";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName);

    const auto newTestWalletAccountName = u"test_generated_new_account-name"_qs;
    const auto newTestAccountColor = QColor("fuchsia");
    const auto newTestAccountEmoji = u""_qs;
    const auto newTestAccountPath = Status::Constants::General::PathDefaultWallet;

    const auto walletAccount = testAccount.firstWalletAccount();
    try {
        Accounts::generateAccountWithDerivedPath(testAccount.hashedPassword(), newTestWalletAccountName,
                                               newTestAccountColor, newTestAccountEmoji,
                                               newTestAccountPath, walletAccount.derivedFrom.value());
        FAIL() << "The first wallet account already exists from the logged in multi-account";
    } catch(const StatusGo::CallPrivateRpcError& e) {
        ASSERT_EQ(e.errorResponse().error.message, "account already exists");
        ASSERT_EQ(e.errorResponse().error.code, -32000);
    }

    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 2);

    const auto newAccountIt = std::find_if(updatedAccounts.begin(), updatedAccounts.end(),
                                     [&newTestWalletAccountName](const auto& a) {
                                         return a.name == newTestWalletAccountName;
                                     });
    ASSERT_EQ(newAccountIt, updatedAccounts.end());
}

TEST(AccountsAPI, TestGenerateAccountWithDerivedPath_WrongPassword)
{
    constexpr auto testRootAccountName = "test-generate_account_with_derived_path-name";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName);

    const auto chatAccount = testAccount.firstChatAccount();
    try {
        Accounts::generateAccountWithDerivedPath(Utils::hashPassword("WrongPassword"), u"test_wrong_pass-name"_qs,
                                               QColor("fuchsia"), "", Status::Constants::General::PathWalletRoot,
                                               chatAccount.address);
        FAIL();
    } catch(const StatusGo::CallPrivateRpcError &exception) {
        const auto &err = exception.errorResponse();
        ASSERT_EQ(err.error.code, StatusGo::defaultErrorCode);
        ASSERT_EQ(err.error.message, "could not decrypt key with given password");
    }

    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 2);
}

TEST(AccountsAPI, TestAddAccountWithMnemonicAndPath)
{
    constexpr auto testRootAccountName = "test_root_account-name";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName);

    const auto newTestAccountName = u"test_import_from_mnemonic-name"_qs;
    const auto newTestAccountColor = QColor("fuchsia");
    const auto newTestAccountEmoji = u""_qs;
    const auto newTestAccountPath = Status::Constants::General::PathWalletRoot;

    Accounts::addAccountWithMnemonicAndPath("festival october control quarter husband dish throw couch depth stadium cigar whisper",
                                          testAccount.hashedPassword(), newTestAccountName, newTestAccountColor, newTestAccountEmoji,
                                          newTestAccountPath);
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 3);

    const auto newAccountIt = std::find_if(updatedAccounts.begin(), updatedAccounts.end(),
                                           [&newTestAccountName](const auto& a) {
        return a.name == newTestAccountName;
    });
    ASSERT_NE(newAccountIt, updatedAccounts.end());
    const auto &newAccount = *newAccountIt;
    ASSERT_FALSE(newAccount.address.get().isEmpty());
    ASSERT_FALSE(newAccount.isChat);
    ASSERT_FALSE(newAccount.isWallet);
    ASSERT_EQ(newAccount.color, newTestAccountColor);
    ASSERT_FALSE(newAccount.derivedFrom.has_value());
    ASSERT_EQ(newAccount.emoji, newTestAccountEmoji);
    ASSERT_EQ(newAccount.mixedcaseAddress.toUpper(), newAccount.address.get().toUpper());
    ASSERT_EQ(newAccount.path, newTestAccountPath);
    ASSERT_FALSE(newAccount.publicKey.isEmpty());
}

/// Show that the menmonic is not validated. Client has to validate the user provided mnemonic
TEST(AccountsAPI, TestAddAccountWithMnemonicAndPath_WrongMnemonicWorks)
{
    constexpr auto testRootAccountName = "test_root_account-name";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName);

    const auto newTestAccountName = u"test_import_from_wrong_mnemonic-name"_qs;
    const auto newTestAccountColor = QColor("fuchsia");
    const auto newTestAccountEmoji = u""_qs;
    const auto newTestAccountPath = Status::Constants::General::PathWalletRoot;

    // Added an inexistent word. The mnemonic is not checked.
    Accounts::addAccountWithMnemonicAndPath("october control quarter husband dish throw couch depth stadium cigar waku",
                                          testAccount.hashedPassword(), newTestAccountName, newTestAccountColor, newTestAccountEmoji,
                                          newTestAccountPath);

    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 3);

    const auto newAccountIt = std::find_if(updatedAccounts.begin(), updatedAccounts.end(),
                                           [&newTestAccountName](const auto& a) {
        return a.name == newTestAccountName;
    });

    ASSERT_NE(newAccountIt, updatedAccounts.end());
    const auto &newAccount = *newAccountIt;
    ASSERT_FALSE(newAccount.address.get().isEmpty());
    ASSERT_FALSE(newAccount.isChat);
    ASSERT_FALSE(newAccount.isWallet);
    ASSERT_EQ(newAccount.color, newTestAccountColor);
    ASSERT_FALSE(newAccount.derivedFrom.has_value());
    ASSERT_EQ(newAccount.emoji, newTestAccountEmoji);
    ASSERT_EQ(newAccount.mixedcaseAddress.toUpper(), newAccount.address.get().toUpper());
    ASSERT_EQ(newAccount.path, newTestAccountPath);
    ASSERT_FALSE(newAccount.publicKey.isEmpty());
}

TEST(AccountsAPI, TestAddAccountWatch)
{
    constexpr auto testRootAccountName = "test_root_account-name";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName);

    const auto newTestAccountName = u"test_watch_only-name"_qs;
    const auto newTestAccountColor = QColor("fuchsia");
    const auto newTestAccountEmoji = u""_qs;

    Accounts::addAccountWatch(Accounts::EOAddress("0x145b6B821523afFC346774b41ACC7b77A171BbA4"), newTestAccountName, newTestAccountColor, newTestAccountEmoji);
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 3);

    const auto newAccountIt = std::find_if(updatedAccounts.begin(), updatedAccounts.end(),
                                           [&newTestAccountName](const auto& a) {
        return a.name == newTestAccountName;
    });
    ASSERT_NE(newAccountIt, updatedAccounts.end());
    const auto &newAccount = *newAccountIt;
    ASSERT_FALSE(newAccount.address.get().isEmpty());
    ASSERT_FALSE(newAccount.isChat);
    ASSERT_FALSE(newAccount.isWallet);
    ASSERT_EQ(newAccount.color, newTestAccountColor);
    ASSERT_FALSE(newAccount.derivedFrom.has_value());
    ASSERT_EQ(newAccount.emoji, newTestAccountEmoji);
    ASSERT_EQ(newAccount.mixedcaseAddress.toUpper(), newAccount.address.get().toUpper());
    ASSERT_TRUE(newAccount.path.get().isEmpty());
    ASSERT_TRUE(newAccount.publicKey.isEmpty());
}

TEST(AccountsAPI, TestDeleteAccount)
{
    constexpr auto testRootAccountName = "test_root_account-name";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName);

    const auto newTestAccountName = u"test_account_to_delete-name"_qs;
    const auto newTestAccountColor = QColor("fuchsia");
    const auto newTestAccountEmoji = u""_qs;

    Accounts::addAccountWatch(Accounts::EOAddress("0x145b6B821523afFC346774b41ACC7b77A171BbA4"), newTestAccountName, newTestAccountColor, newTestAccountEmoji);
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 3);

    const auto newAccountIt = std::find_if(updatedAccounts.begin(), updatedAccounts.end(),
                                           [&newTestAccountName](const auto& a) {
        return a.name == newTestAccountName;
    });
    ASSERT_NE(newAccountIt, updatedAccounts.end());
    const auto &newAccount = *newAccountIt;

    Accounts::deleteAccount(newAccount.address);
    const auto updatedDefaultAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedDefaultAccounts.size(), 2);
}


}
