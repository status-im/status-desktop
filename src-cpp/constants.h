#pragma once

#include <QString>

namespace Constants
{
const QString DataDir = "/data";
const QString Keystore = "/data/keystore";

QString applicationPath(QString path = "");
QString tmpPath(QString path = "");
QString cachePath(QString path = "");
bool ensureDirectories();

} // namespace Constants
