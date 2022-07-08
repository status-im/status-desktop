#include "ServiceMock.h"

#include <Constants.h>

#include <IOTestHelpers.h>

#include <Onboarding/Accounts/AccountsService.h>
#include <Onboarding/OnboardingController.h>

#include <gtest/gtest.h>

#include <memory>

namespace Onboarding = Status::Onboarding;

namespace fs = std::filesystem;

namespace Status::Testing {

class LoginTest : public ::testing::Test
{
protected:
    static std::shared_ptr<AccountsServiceMock> m_accountsServiceMock;

    std::unique_ptr<Onboarding::AccountsService> m_accountsService;
    std::unique_ptr<Testing::AutoCleanTempTestDir> m_fusedTestFolder;

    static void SetUpTestSuite() {
        m_accountsServiceMock = std::make_shared<AccountsServiceMock>();
    }
    static void TearDownTestSuite() {
        m_accountsServiceMock.reset();
    }

    void SetUp() override {
        m_fusedTestFolder = std::make_unique<Testing::AutoCleanTempTestDir>("LoginTest");
        m_accountsService = std::make_unique<Onboarding::AccountsService>();
        m_accountsService->init(m_fusedTestFolder->tempFolder() / Constants::statusGoDataDirName);
    }

    void TearDown() override {
        m_fusedTestFolder.release();
        m_accountsService.release();
    }
};

std::shared_ptr<AccountsServiceMock> LoginTest::m_accountsServiceMock;

TEST_F(LoginTest, DISABLED_TestLoginController)
{
    // Controller hides as a regular class but at runtime it must be a shared pointer; TODO: refactor
    auto controller = std::make_shared<Onboarding::OnboardingController>(m_accountsServiceMock);
}

} // namespace
