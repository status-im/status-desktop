#include "StatusTestEnvironment.h"

using namespace Status::Test;

std::shared_ptr<AccountsServiceMock> StatusTestEnvironment::AccountsServiceMockInst = nullptr;

 StatusTestEnvironment::~StatusTestEnvironment()
{
}

void StatusTestEnvironment::SetUp()
{
    init();
}

void StatusTestEnvironment::TearDown()
{
}

void StatusTestEnvironment::init() {
    StatusTestEnvironment::AccountsServiceMockInst = std::make_shared<AccountsServiceMock>();
}


