#include <gtest/gtest.h>

#include <StatusGo/Accounts/Accounts.h>

#include <IOTestHelpers.h>

namespace Accounts = Status::StatusGo::Accounts;
namespace StatusGo = Status::StatusGo;

namespace fs = std::filesystem;

namespace Status::Testing {

TEST(Onboarding, TestOpenAccountsNoDataFails) {
    AutoCleanTempTestDir fusedTestFolder{test_info_->name()};

    auto response = Accounts::openAccounts(fusedTestFolder.tempFolder().c_str());
    EXPECT_FALSE(response.containsError());
    EXPECT_EQ(response.result.count(), 0);
}

TEST(Onboarding, TestOpenAccountsNoDataDoesNotCreateFiles) {
    AutoCleanTempTestDir fusedTestFolder{test_info_->name()};

    auto response = Accounts::openAccounts(fusedTestFolder.tempFolder().c_str());
    EXPECT_FALSE(response.containsError());

    int fileCount = 0;
    for (const auto & file : fs::directory_iterator(fusedTestFolder.tempFolder()))
        fileCount++;
    EXPECT_EQ(fileCount, 0);
}

}
