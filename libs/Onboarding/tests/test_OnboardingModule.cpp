#include <IOTestHelpers.h>

#include "ServiceMock.h"

#include <Constants.h>

#include <Onboarding/Accounts/AccountsService.h>
#include <Onboarding/OnboardingController.h>

#include <StatusGo/SignalsManager.h>
#include <StatusGo/Accounts/Accounts.h>

#include <ScopedTestAccount.h>

#include <QCoreApplication>

#include <gtest/gtest.h>

namespace Testing = Status::Testing;
namespace Onboarding = Status::Onboarding;

namespace fs = std::filesystem;

namespace Status::Testing {

static std::unique_ptr<Onboarding::AccountsService> m_accountsServiceMock;

TEST(OnboardingModule, TestInitService)
{
    Testing::AutoCleanTempTestDir fusedTestFolder{test_info_->name()};
    auto testFolderPath = fusedTestFolder.tempFolder() / Constants::statusGoDataDirName;
    fs::create_directory(testFolderPath);
    auto accountsService = std::make_unique<Onboarding::AccountsService>();
    ASSERT_TRUE(accountsService->init(testFolderPath));
}

/// This integration end to end test is here for documentation purpose and until all the functionality is covered by unit-tests
/// \warning the test depends on IO and it is not deterministic, fast, focused or reliable and uses production classes. It is here for documenting only and dev process
/// \todo refactor into unit-tests with mocked interfaces
TEST(OnboardingModule, TestCreateAndLoginAccountEndToEnd)
{
    int argc = 1;
    std::string appName{"test"};
    char* args[] = {appName.data()};
    QCoreApplication dummyApp{argc, reinterpret_cast<char**>(args)};

    Testing::AutoCleanTempTestDir fusedTestFolder{test_info_->name()};
    auto testFolderPath = fusedTestFolder.tempFolder() / "Status Desktop";
    fs::create_directory(testFolderPath);

    // Setup accounts
    auto accountsService = std::make_shared<Onboarding::AccountsService>();
    auto result = accountsService->init(testFolderPath);
    ASSERT_TRUE(result);

    // TODO refactor and merge account creation events with login into Onboarding controller
    //
    // Create Login early to register and not miss onLoggedIn event signal from setupAccountAndLogin
    //

    // Beware, smartpointer is a requirement
    auto onboarding = std::make_shared<Onboarding::OnboardingController>(accountsService);
    EXPECT_EQ(onboarding->getOpenedAccounts().size(), 0);

    int accountLoggedInCount = 0;
    QObject::connect(onboarding.get(), &Onboarding::OnboardingController::accountLoggedIn, [&accountLoggedInCount]() {
        accountLoggedInCount++;
    });
    bool accountLoggedInError = false;
    QObject::connect(onboarding.get(), &Onboarding::OnboardingController::accountLoginError, [&accountLoggedInError]() {
        accountLoggedInError = true;
    });

    // Create Accounts
    auto genAccounts = accountsService->generatedAccounts();
    ASSERT_GT(genAccounts.size(), 0);

    ASSERT_FALSE(accountsService->isFirstTimeAccountLogin());

    constexpr auto accountName = "test_name";
    constexpr auto accountPassword = "test_pwd*";
    ASSERT_TRUE(accountsService->setupAccountAndLogin(genAccounts[0].id, accountPassword, accountName));

    ASSERT_TRUE(accountsService->isFirstTimeAccountLogin());
    ASSERT_TRUE(accountsService->getLoggedInAccount().isValid());
    ASSERT_TRUE(accountsService->getLoggedInAccount().name == accountName);
    ASSERT_FALSE(accountsService->getImportedAccount().isValid());

    using namespace std::chrono_literals;
    auto maxWaitTime = 2000ms;
    auto iterationSleepTime = 2ms;
    auto remainingIterations = maxWaitTime/iterationSleepTime;
    while (remainingIterations-- > 0 && accountLoggedInCount == 0) {
        std::this_thread::sleep_for(iterationSleepTime);

        QCoreApplication::sendPostedEvents();
    }

    EXPECT_EQ(accountLoggedInCount, 1);
    EXPECT_FALSE(accountLoggedInError);
    EXPECT_FALSE(Status::StatusGo::Accounts::logout().containsError());
}

/// This integration end to end test is here for documentation purpose and until all the functionality is covered by unit-tests
/// \warning the test depends on IO and it is not deterministic, fast, focused or reliable. It is here for validation only
/// \todo find a way to test the integration within a test environment. Also how about reusing an existing account
/// \todo due to keeping status-go keeping the state thsi works only run separately
TEST(OnboardingModule, TestLoginEndToEnd)
{
    // Create test account and login
    //
    bool createAndLogin = false;
    QObject::connect(StatusGo::SignalsManager::instance(), &StatusGo::SignalsManager::nodeLogin, [&createAndLogin](const QString& error) {
        if(error.isEmpty()) {
            if(createAndLogin) {
                createAndLogin = false;
            } else
                createAndLogin = true;
        }
    });

    constexpr auto accountName = "TestLoginAccountName";
    constexpr auto accountPassword = "1234567890";
    ScopedTestAccount testAccount(test_info_->name(), accountName, accountPassword, true);
    testAccount.processMessages(1000, [createAndLogin]() {
        return !createAndLogin;
    });
    ASSERT_TRUE(createAndLogin);

    testAccount.logOut();

    // Test account log in
    //

    // Setup accounts
    auto accountsService = std::make_shared<Onboarding::AccountsService>();
    auto result = accountsService->init(testAccount.fusedTestFolder());
    ASSERT_TRUE(result);

    auto onboarding = std::make_shared<Onboarding::OnboardingController>(accountsService);
    // We don't have a way yet to simulate status-go process exit
    //EXPECT_EQ(onboarding->getOpenedAccounts().count(), 0);

    auto accounts = accountsService->openAndListAccounts();
    //ASSERT_EQ(accounts.size(), 1);
    ASSERT_GT(accounts.size(), 0);

    int accountLoggedInCount = 0;
    QObject::connect(onboarding.get(), &Onboarding::OnboardingController::accountLoggedIn, [&accountLoggedInCount]() {
        accountLoggedInCount++;
    });
    bool accountLoggedInError = false;
    QObject::connect(onboarding.get(), &Onboarding::OnboardingController::accountLoginError, [&accountLoggedInError]() {
        accountLoggedInError = true;
    });

    // Workaround until we reset the status-go state
    auto ourAccountRes = std::find_if(accounts.begin(), accounts.end(), [accountName](const auto &a) { return a.name == accountName; });
    auto errorString = accountsService->login(*ourAccountRes, accountPassword);
    ASSERT_EQ(errorString.length(), 0);

    testAccount.processMessages(1000, [accountLoggedInCount, accountLoggedInError]() {
        return accountLoggedInCount == 0 && !accountLoggedInError;
    });
    ASSERT_EQ(accountLoggedInCount, 1);
    ASSERT_EQ(accountLoggedInError, 0);
}

} // namespace
