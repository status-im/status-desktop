#include <StatusGo/Messenger/Service.h>

#include <Onboarding/Accounts/AccountsService.h>

#include <StatusGo/SignalsManager.h>

#include <ScopedTestAccount.h>

#include <gtest/gtest.h>

namespace fs = std::filesystem;

namespace Status::Testing {

/// This is an integration test to check that status-go doesn't crash on apple silicon when starting Me
/// \warning the test depends on IO and it is not deterministic, fast, focused or reliable. It is here for validation only
/// \todo fin a way to test the integration within a test environment. Also how about reusing an existing account
TEST(MessagingApi, TestStartMessaging)
{
    bool nodeReady = false;
    QObject::connect(StatusGo::SignalsManager::instance(), &StatusGo::SignalsManager::nodeReady, [&nodeReady](const QString& error) {
        if(error.isEmpty()) {
            if(nodeReady) {
                nodeReady = false;
            } else
                nodeReady = true;
        }
    });

    ScopedTestAccount testAccount(test_info_->name());

    ASSERT_TRUE(StatusGo::Messenger::startMessenger());

    testAccount.processMessages(1000, [nodeReady]() {
        return !nodeReady;
    });
    ASSERT_TRUE(nodeReady);
}

} // namespace
