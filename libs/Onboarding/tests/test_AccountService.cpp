#include "ServiceMock.h"

#include <IOTestHelpers.h>
#include <Constants.h>

#include <StatusGo/Accounts/Accounts.h>

#include <Onboarding/Accounts/AccountsService.h>
#include <Onboarding/Common/Constants.h>

#include <gtest/gtest.h>

namespace Testing = Status::Testing;
namespace Onboarding = Status::Onboarding;

namespace fs = std::filesystem;

namespace Status::Testing {

class AccountsService : public ::testing::Test
{
protected:
    std::unique_ptr<Onboarding::AccountsService> m_accountsService;
    std::unique_ptr<Testing::AutoCleanTempTestDir> m_fusedTestFolder;

    void SetUp() override {
        m_fusedTestFolder = std::make_unique<Testing::AutoCleanTempTestDir>("TestAccountsService");
        m_accountsService = std::make_unique<Onboarding::AccountsService>();
        m_accountsService->init(m_fusedTestFolder->tempFolder() / Constants::statusGoDataDirName);
    }

    void TearDown() override {
        m_fusedTestFolder.reset();
        m_accountsService.reset();
    }
};


TEST_F(AccountsService, GeneratedAccounts)
{
    auto genAccounts = m_accountsService->generatedAccounts();

    ASSERT_EQ(5, genAccounts.size());

    for(const auto& acc : genAccounts)
    {
        ASSERT_STRNE(qUtf8Printable(acc.id), "");
        ASSERT_STRNE(qUtf8Printable(acc.publicKey), "");
        ASSERT_STRNE(qUtf8Printable(acc.address), "");
        ASSERT_STRNE(qUtf8Printable(acc.keyUid), "");
    }
}

TEST_F(AccountsService, DISABLED_GenerateAlias) // temporary disabled till we see what's happening on the status-go side since it doesn't return aliases for any pk
{
    QString testPubKey = "0x04487f44bac3e90825bfa9720148308cb64835bebb7e888f519cebc127223187067629f8b70d0661a35d4af6516b225286";

    auto alias = m_accountsService->generateAlias(testPubKey);

    ASSERT_NE(alias, QString(""));
}

} // namespace
