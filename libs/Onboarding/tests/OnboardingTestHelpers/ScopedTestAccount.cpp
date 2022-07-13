#include "ScopedTestAccount.h"

#include <Constants.h>

#include <IOTestHelpers.h>

#include <Onboarding/Accounts/AccountsService.h>
#include <Onboarding/OnboardingController.h>

#include <StatusGo/Accounts/Accounts.h>
#include <StatusGo/Accounts/AccountsAPI.h>

#include <QCoreApplication>

#include <gtest/gtest.h>

namespace Testing = Status::Testing;
namespace Onboarding = Status::Onboarding;
namespace Accounts = Status::StatusGo::Accounts;

namespace fs = std::filesystem;

namespace Status::Testing {

ScopedTestAccount::ScopedTestAccount(const std::string &tempTestSubfolderName, const QString &accountName, const QString &accountPassword, bool ignorePreviousState)
    : m_fusedTestFolder{std::make_unique<AutoCleanTempTestDir>(tempTestSubfolderName)}
    , m_accountName(accountName)
    , m_accountPassword(accountPassword)
{
    int argc = 1;
    std::string appName{"test"};
    char* args[] = {appName.data()};
    m_app = std::make_unique<QCoreApplication>(argc, reinterpret_cast<char**>(args));

    m_testFolderPath = m_fusedTestFolder->tempFolder() / Constants::statusGoDataDirName;
    fs::create_directory(m_testFolderPath);

    // Setup accounts
    auto accountsService = std::make_shared<Onboarding::AccountsService>();
    auto result = accountsService->init(m_testFolderPath);
    if(!result)
        throw std::runtime_error("ScopedTestAccount - Failed to create temporary test account");

    // TODO refactor and merge account creation events with login into Onboarding controller
    //
    // Create Login early to register and not miss onLoggedIn event signal from setupAccountAndLogin
    //

    // Beware, smartpointer is a requirement
    m_onboarding = std::make_shared<Onboarding::OnboardingController>(accountsService);
    if(m_onboarding->getOpenedAccounts().size() != 0 && !ignorePreviousState)
        throw std::runtime_error("ScopedTestAccount - already have opened account");

    int accountLoggedInCount = 0;
    QObject::connect(m_onboarding.get(), &Onboarding::OnboardingController::accountLoggedIn, [&accountLoggedInCount]() {
        accountLoggedInCount++;
    });
    bool accountLoggedInError = false;
    QObject::connect(m_onboarding.get(), &Onboarding::OnboardingController::accountLoginError, [&accountLoggedInError]() {
        accountLoggedInError = true;
    });

    // Create Accounts
    auto genAccounts = accountsService->generatedAccounts();
    if(genAccounts.size() == 0)
        throw std::runtime_error("ScopedTestAccount - missing generated accounts");

    if(accountsService->isFirstTimeAccountLogin())
        throw std::runtime_error("ScopedTestAccount - Service::isFirstTimeAccountLogin returned true");

    if(!accountsService->setupAccountAndLogin(genAccounts[0].id, m_accountPassword, m_accountName))
        throw std::runtime_error("ScopedTestAccount - Service::setupAccountAndLogin failed");

    if(!accountsService->isFirstTimeAccountLogin())
        throw std::runtime_error("ScopedTestAccount - Service::isFirstTimeAccountLogin returned false");
    if(!accountsService->getLoggedInAccount().isValid())
        throw std::runtime_error("ScopedTestAccount - newly created account is not valid");
    if(accountsService->getLoggedInAccount().name != accountName)
        throw std::runtime_error("ScopedTestAccount - newly created account has a wrong name");
    processMessages(2000, [accountLoggedInCount]() {
        return accountLoggedInCount == 0;
    });
    if(accountLoggedInCount != 1)
        throw std::runtime_error("ScopedTestAccount - missing confirmation of account creation");
    if(accountLoggedInError)
        throw std::runtime_error("ScopedTestAccount - account loggedin error");
}

ScopedTestAccount::~ScopedTestAccount()
{
    const auto rootAccount = m_onboarding->accountsService()->getLoggedInAccount();
    m_onboarding->accountsService()->deleteMultiAccount(rootAccount);
}

void ScopedTestAccount::processMessages(size_t maxWaitTimeMillis, std::function<bool()> shouldWaitUntilTimeout) {
    using namespace std::chrono_literals;
    std::chrono::milliseconds maxWaitTime{maxWaitTimeMillis};
    auto iterationSleepTime = 2ms;
    auto remainingIterations = maxWaitTime/iterationSleepTime;
    while (remainingIterations-- > 0 && shouldWaitUntilTimeout()) {
        std::this_thread::sleep_for(iterationSleepTime);

        QCoreApplication::sendPostedEvents();
    }
}

void ScopedTestAccount::logOut()
{
    if(Status::StatusGo::Accounts::logout().containsError())
        throw std::runtime_error("ScopedTestAccount - failed logging out");
}

Accounts::ChatOrWalletAccount ScopedTestAccount::firstChatAccount()
{
    auto accounts = Accounts::getAccounts();
    auto chatIt = std::find_if(accounts.begin(), accounts.end(), [](const auto& a) {
        return a.isChat;
    });
    if(chatIt == accounts.end())
        throw std::runtime_error("ScopedTestAccount::chatAccount: account not found");
    return *chatIt;
}

Accounts::ChatOrWalletAccount ScopedTestAccount::firstWalletAccount()
{
    auto accounts = Accounts::getAccounts();
    auto walletIt = std::find_if(accounts.begin(), accounts.end(), [](const auto& a) {
        return a.isWallet;
    });
    if(walletIt == accounts.end())
        throw std::runtime_error("ScopedTestAccount::firstWalletAccount: account not found");
    return *walletIt;
}

Onboarding::OnboardingController *ScopedTestAccount::onboardingController() const
{
    return m_onboarding.get();
}

const std::filesystem::path &ScopedTestAccount::fusedTestFolder() const
{
    return m_testFolderPath;
}

}
