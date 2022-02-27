#include <gtest/gtest.h>

#include "Utils.h"

#include <StatusServices/Accounts/ServiceMock.h>

using namespace Status::Test;

class StatusTestEnvironment : public ::testing::Environment {
public:
    ~StatusTestEnvironment() override;

    void SetUp() override;

    void TearDown() override;

    static std::shared_ptr<AccountsServiceMock> AccountsServiceMockInst;

protected:
    void init();
};
