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
    return fs::path(testing::TempDir())/"StatusTests"/(testName + "-" + timeOss.str());
}

AutoCleanTempTestDir::AutoCleanTempTestDir(const std::string &testName, bool createDir)
    : m_testFolder(createTestFolder(testName))
{
    if(createDir)
        fs::create_directories(m_testFolder);
}

AutoCleanTempTestDir::~AutoCleanTempTestDir()
{
    // TODO: Consider making this concurrent safe and cleanup the root folder as well if empty
    fs::remove_all(m_testFolder);
}

const std::filesystem::path& AutoCleanTempTestDir::tempFolder()
{
    return m_testFolder;
}

}
