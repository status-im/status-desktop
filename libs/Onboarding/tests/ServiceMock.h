#pragma once

#include "Onboarding/Accounts/AccountsServiceInterface.h"

#include <gmock/gmock.h>

namespace Onboarding = Status::Onboarding;

namespace Status::Testing
{

/*!
 * \brief The AccountsServiceMock test class
 *
 * \todo Consider if this is really neaded for testing controllers
 * \todo Move it to mocks subfolder
 */
class AccountsServiceMock final : public Onboarding::AccountsServiceInterface
{
public:
    virtual ~AccountsServiceMock() override {};

    MOCK_METHOD(bool, init, (const fs::path&), (override));
    MOCK_METHOD(std::vector<Onboarding::MultiAccount>, openAndListAccounts, (), (override));
    MOCK_METHOD(const std::vector<Onboarding::GeneratedMultiAccount>&, generatedAccounts, (), (const, override));
    MOCK_METHOD(bool, setupAccountAndLogin, (const QString&, const QString&, const QString&), (override));
    MOCK_METHOD(const Onboarding::MultiAccount&, getLoggedInAccount, (), (const, override));
    MOCK_METHOD(const Onboarding::GeneratedMultiAccount&, getImportedAccount, (), (const, override));
    MOCK_METHOD(bool, isFirstTimeAccountLogin, (), (const, override));
    MOCK_METHOD(bool, setKeyStoreDir, (const QString&), (override));
    MOCK_METHOD(QString, login, (Onboarding::MultiAccount, const QString&), (override));
    MOCK_METHOD(void, clear, (), (override));
    MOCK_METHOD(QString, generateAlias, (const QString&), (override));
    MOCK_METHOD(void, deleteMultiAccount, (const Onboarding::MultiAccount&), (override));
};

}
