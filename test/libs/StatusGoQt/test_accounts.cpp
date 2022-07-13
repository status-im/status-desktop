#include <StatusGo/Accounts/AccountsAPI.h>
#include <StatusGo/Metadata/api_response.h>
#include <StatusGo/Accounts/Accounts.h>

#include <Onboarding/Common/Constants.h>
#include <Onboarding/OnboardingController.h>
#include <StatusGo/Utils.h>

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
    constexpr auto testAccountPassword = "password*";
    ScopedTestAccount testAccount(test_info_->name(), testAccountName, testAccountPassword, true);

    const auto accounts = Accounts::getAccounts();
    // TODO: enable after calling reset to status-go
    //ASSERT_EQ(accounts.size(), 2);

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

TEST(Accounts, TestGenerateAccountWithDerivedPath)
{
    constexpr auto testRootAccountName = "test-generate_account_with_derived_path-name";
    constexpr auto testAccountPassword = "password*";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName, testAccountPassword, true);

    auto password{Utils::hashPassword(testAccountPassword)};
    const auto newTestAccountName = u"test_generated_new_account-name"_qs;
    const auto newTestAccountColor = QColor("fuchsia");
    const auto newTestAccountEmoji = u""_qs;
    const auto newTestAccountPath = Status::Constants::General::PathWalletRoot;

    const auto chatAccount = testAccount.firstChatAccount();
    Accounts::generateAccountWithDerivedPath(password, newTestAccountName,
                                           newTestAccountColor, newTestAccountEmoji,
                                           newTestAccountPath, chatAccount.address);
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 3);

    const auto newAccountIt = std::find_if(updatedAccounts.begin(), updatedAccounts.end(),
                                     [newTestAccountName = std::as_const(newTestAccountName)](const auto& a) {
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

TEST(AccountsAPI, TestGenerateAccountWithDerivedPath_WrongPassword)
{
    constexpr auto testRootAccountName = "test-generate_account_with_derived_path-name";
    constexpr auto testAccountPassword = "password*";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName, testAccountPassword, true);

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
    constexpr auto testAccountPassword = "password*";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName, testAccountPassword, true);

    auto password{Utils::hashPassword(testAccountPassword)};
    const auto newTestAccountName = u"test_import_from_mnemonic-name"_qs;
    const auto newTestAccountColor = QColor("fuchsia");
    const auto newTestAccountEmoji = u""_qs;
    const auto newTestAccountPath = Status::Constants::General::PathWalletRoot;

    Accounts::addAccountWithMnemonicAndPath("festival october control quarter husband dish throw couch depth stadium cigar whisper",
                                          password, newTestAccountName, newTestAccountColor, newTestAccountEmoji,
                                          newTestAccountPath);
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 3);

    const auto newAccountIt = std::find_if(updatedAccounts.begin(), updatedAccounts.end(),
                                           [newTestAccountName = std::as_const(newTestAccountName)](const auto& a) {
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
    constexpr auto testAccountPassword = "password*";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName, testAccountPassword, true);

    auto password{Utils::hashPassword(testAccountPassword)};
    const auto newTestAccountName = u"test_import_from_wrong_mnemonic-name"_qs;
    const auto newTestAccountColor = QColor("fuchsia");
    const auto newTestAccountEmoji = u""_qs;
    const auto newTestAccountPath = Status::Constants::General::PathWalletRoot;

    // Added an inexistent word. The mnemonic is not checked.
    Accounts::addAccountWithMnemonicAndPath("october control quarter husband dish throw couch depth stadium cigar waku",
                                          password, newTestAccountName, newTestAccountColor, newTestAccountEmoji,
                                          newTestAccountPath);

    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 3);

    const auto newAccountIt = std::find_if(updatedAccounts.begin(), updatedAccounts.end(),
                                           [newTestAccountName = std::as_const(newTestAccountName)](const auto& a) {
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
    constexpr auto testAccountPassword = "password*";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName, testAccountPassword, true);

    const auto newTestAccountName = u"test_watch_only-name"_qs;
    const auto newTestAccountColor = QColor("fuchsia");
    const auto newTestAccountEmoji = u""_qs;

    Accounts::addAccountWatch(Accounts::EOAddress("0x145b6B821523afFC346774b41ACC7b77A171BbA4"), newTestAccountName, newTestAccountColor, newTestAccountEmoji);
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 3);

    const auto newAccountIt = std::find_if(updatedAccounts.begin(), updatedAccounts.end(),
                                           [newTestAccountName = std::as_const(newTestAccountName)](const auto& a) {
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
    constexpr auto testAccountPassword = "password*";
    ScopedTestAccount testAccount(test_info_->name(), testRootAccountName, testAccountPassword, true);

    const auto newTestAccountName = u"test_account_to_delete-name"_qs;
    const auto newTestAccountColor = QColor("fuchsia");
    const auto newTestAccountEmoji = u""_qs;

    Accounts::addAccountWatch(Accounts::EOAddress("0x145b6B821523afFC346774b41ACC7b77A171BbA4"), newTestAccountName, newTestAccountColor, newTestAccountEmoji);
    const auto updatedAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedAccounts.size(), 3);

    const auto newAccountIt = std::find_if(updatedAccounts.begin(), updatedAccounts.end(),
                                           [newTestAccountName = std::as_const(newTestAccountName)](const auto& a) {
        return a.name == newTestAccountName;
    });
    ASSERT_NE(newAccountIt, updatedAccounts.end());
    const auto &newAccount = *newAccountIt;

    Accounts::deleteAccount(newAccount.address);
    const auto updatedDefaultAccounts = Accounts::getAccounts();
    ASSERT_EQ(updatedDefaultAccounts.size(), 2);
}


}
