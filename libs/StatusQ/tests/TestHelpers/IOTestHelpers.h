#pragma once

#include <filesystem>

#include <string>

namespace Status::Testing {

class AutoCleanTempTestDir {
public:
    /// Creates a temporary folder to be used in tests. The folder content's will
    /// be removed when out of scope
    explicit AutoCleanTempTestDir(const std::string& testName);
    ~AutoCleanTempTestDir();

    const std::filesystem::path& testFolder();

private:
    const std::filesystem::path m_testFolder;
};

}
