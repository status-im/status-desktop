#pragma once

#include <filesystem>

#include <string>

namespace Status::Testing {

class AutoCleanTempTestDir {
public:
    /// Creates a temporary folder to be used in tests. The folder content's will
    /// be removed when out of scope
    explicit AutoCleanTempTestDir(const std::string& testName, bool createDir = true);
    ~AutoCleanTempTestDir();

    const std::filesystem::path& tempFolder();

private:
    const std::filesystem::path m_testFolder;
};

}
