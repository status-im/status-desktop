#include "IOTestHelpers.h"

#include <gtest/gtest.h>

namespace fs = std::filesystem;

namespace Status::Testing {

fs::path createTestFolder(const std::string& testName)
{
    auto t = std::time(nullptr);
    auto tm = *std::localtime(&t);
    std::ostringstream timeOss;
    timeOss << std::put_time(&tm, "%d-%m-%Y_%H-%M-%S");
    auto tmpPath = fs::path(testing::TempDir())/(testName + "-" + timeOss.str());
    fs::create_directories(tmpPath);
    return tmpPath;
}

AutoCleanTempTestDir::AutoCleanTempTestDir(const std::string &testName)
    : m_testFolder(createTestFolder(testName))
{
}

AutoCleanTempTestDir::~AutoCleanTempTestDir()
{
   fs::remove_all(m_testFolder);
}

const std::filesystem::path& AutoCleanTempTestDir::testFolder()
{
    return m_testFolder;
}


}
