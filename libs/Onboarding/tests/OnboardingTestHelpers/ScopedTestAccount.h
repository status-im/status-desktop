#pragma once

#include <Wallet/WalletApi.h>

#include <StatusGo/Utils.h>

#include <filesystem>
#include <string>

#include <QString>

class QCoreApplication;

namespace Status::Onboarding
{
class OnboardingController;
class MultiAccount;
} // namespace Status::Onboarding

namespace Wallet = Status::StatusGo::Wallet;
namespace Accounts = Status::StatusGo::Accounts;
namespace GoUtils = Status::StatusGo::Utils;

namespace Status::Testing
{

class AutoCleanTempTestDir;

class ScopedTestAccount final
{
public:
    /*!
     * \brief Create and logs in a new test account
     * \param tempTestSubfolderName subfolder name of the temporary test folder where to initalize user data \see AutoCleanTempTestDir
     * \todo make it more flexible by splitting into create account, login and wait for events
     */
    explicit ScopedTestAccount(const std::string& tempTestSubfolderName,
                               const QString& accountName = defaultAccountName,
                               const QString& accountPassword = defaultAccountPassword);
    ~ScopedTestAccount();

    void processMessages(size_t millis, std::function<bool()> shouldWaitUntilTimeout);
    void logOut();

    static Accounts::ChatOrWalletAccount firstChatAccount();
    static Accounts::ChatOrWalletAccount firstWalletAccount();
    /// Root account
    const Status::Onboarding::MultiAccount& loggedInAccount() const;

    QString password() const
    {
        return m_accountPassword;
    };
    StatusGo::HashedPassword hashedPassword() const
    {
        return GoUtils::hashPassword(m_accountPassword);
    };

    Status::Onboarding::OnboardingController* onboardingController() const;

    /// Temporary test folder that is deleted when class instance goes out of scope
    const std::filesystem::path& fusedTestFolder() const;
    const std::filesystem::path& testDataDir() const;

    QCoreApplication* app()
    {
        return m_app.get();
    };

private:
    std::unique_ptr<AutoCleanTempTestDir> m_fusedTestFolder;
    std::unique_ptr<QCoreApplication> m_app;
    std::filesystem::path m_dataDirPath;
    std::shared_ptr<Status::Onboarding::OnboardingController> m_onboarding;
    std::function<bool()> m_checkIfShouldContinue;

    QString m_accountName;
    QString m_accountPassword;

    static constexpr auto defaultAccountName = "test_name";
    static constexpr auto defaultAccountPassword = "test_pwd*";
};

} // namespace Status::Testing
