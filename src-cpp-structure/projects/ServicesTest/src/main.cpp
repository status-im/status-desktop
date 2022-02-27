#include <QtCore>

#include "Utils.h"
#include "StatusTestEnvironment.h"

#include <gtest/gtest.h>

int main(int argc, char *argv[])
{
    Utils::ensureDirectories();

    ::testing::InitGoogleTest(&argc, argv);

    StatusTestEnvironment* const env = new StatusTestEnvironment();
    if (::testing::AddGlobalTestEnvironment(env) != env) {
        qWarning() << "FAILED: AddGlobalTestEnvironment() should return its argument\n";
        ::testing::internal::posix::Abort();
    }

    return RUN_ALL_TESTS();
}
