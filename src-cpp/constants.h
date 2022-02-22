#pragma once

#include <QString>

namespace Constants
{
inline constexpr auto DataDir = "/data";
inline constexpr auto Keystore = "/data/keystore";

QString applicationPath(const QString& path = "");
QString tmpPath(const QString& path = "");
QString cachePath(const QString& path = "");
bool ensureDirectories();
} // namespace Constants
