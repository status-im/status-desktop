#pragma once

#include <filesystem>

#include <QString>

namespace Status {

QString toString(const std::filesystem::path& path);
std::filesystem::path toPath(const QString& pathStr);

}
