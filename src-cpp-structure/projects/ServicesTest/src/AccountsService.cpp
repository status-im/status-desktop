#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include "Utils.h"
#include "StatusTestEnvironment.h"

#include <StatusServices/Accounts/Service.h>
#include <StatusServices/Accounts/ServiceMock.h>

using namespace Status::Test;

class AccountsServices : public ::testing::Test {

public:
    static std::shared_ptr<Status::Accounts::Service> AccountsServiceInst;

protected:

    static void SetUpTestSuite()
    {
        init();
    }

    static void init() {
        AccountsServices::AccountsServiceInst = std::make_shared<Status::Accounts::Service>();
        if(!AccountsServices::initialized)
        {
            AccountsServices::AccountsServiceInst->init(Utils::statusGoDataDir());
            initialized = true;
        }
    }

    static bool initialized;
};

bool AccountsServices::initialized = false;
std::shared_ptr<Status::Accounts::Service> AccountsServices::AccountsServiceInst = nullptr;

TEST_F(AccountsServices, InitService)
{
    EXPECT_CALL(*StatusTestEnvironment::AccountsServiceMockInst, init(Utils::statusGoDataDir())).Times(1);

    StatusTestEnvironment::AccountsServiceMockInst->init(Utils::statusGoDataDir());

    EXPECT_TRUE(::testing::Mock::VerifyAndClearExpectations(StatusTestEnvironment::AccountsServiceMockInst.get()));
}

TEST_F(AccountsServices, GeneratedAccounts)
{
    EXPECT_CALL(::testing::Const(*StatusTestEnvironment::AccountsServiceMockInst), generatedAccounts()).WillRepeatedly(
                ::testing::Invoke(AccountsServices::AccountsServiceInst.get(), &Status::Accounts::Service::generatedAccounts));

    auto genAccounts = StatusTestEnvironment::AccountsServiceMockInst->generatedAccounts();

    ASSERT_EQ(5, genAccounts.size());

    for(const auto& acc : genAccounts)
    {
        ASSERT_STRNE(qUtf8Printable(acc.id), "");
        ASSERT_STRNE(qUtf8Printable(acc.publicKey), "");
        ASSERT_STRNE(qUtf8Printable(acc.address), "");
        ASSERT_STRNE(qUtf8Printable(acc.keyUid), "");
    }
}

TEST_F(AccountsServices, DISABLED_GenerateAlias) // temporary disabled till we see what's happening on the status-go side since it doesn't return aliases for any pk
{
    QString testPubKey = "0x04487f44bac3e90825bfa9720148308cb64835bebb7e888f519cebc127223187067629f8b70d0661a35d4af6516b225286";

    QString alias;
    EXPECT_CALL(*StatusTestEnvironment::AccountsServiceMockInst, generateAlias(testPubKey)).WillRepeatedly(::testing::ReturnPointee(&alias));

    ASSERT_STRNE(qUtf8Printable(alias), "");
    ASSERT_EQ(alias, AccountsServices::AccountsServiceInst->generateAlias(testPubKey));
}
