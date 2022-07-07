#include <StatusGo/Accounts/AccountsAPI.h>
#include <StatusGo/Metadata/api_response.h>
#include <StatusGo/Accounts/Accounts.h>

#include <Onboarding/Common/Constants.h>
#include <Onboarding/OnboardingController.h>

#include <IOTestHelpers.h>
#include <ScopedTestAccount.h>

#include <gtest/gtest.h>

namespace Accounts = Status::StatusGo::Accounts;

namespace fs = std::filesystem;

namespace Status::Testing {

TEST(OnboardingApi, TestOpenAccountsNoDataFails) {
    AutoCleanTempTestDir fusedTestFolder{test_info_->name()};

    auto response = Accounts::openAccounts(fusedTestFolder.tempFolder().c_str());
    EXPECT_FALSE(response.containsError());
    EXPECT_EQ(response.result.count(), 0);
}

TEST(OnboardingApi, TestOpenAccountsNoDataCreatesFiles) {
    AutoCleanTempTestDir fusedTestFolder{test_info_->name()};

    auto response = Accounts::openAccounts(fusedTestFolder.tempFolder().c_str());
    EXPECT_FALSE(response.containsError());

    int fileCount = 0;
    for (const auto & file : fs::directory_iterator(fusedTestFolder.tempFolder()))
        fileCount++;
    EXPECT_GT(fileCount, 0);
}

}
