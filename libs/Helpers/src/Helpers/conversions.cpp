#include "conversions.h"

namespace fs = std::filesystem;

namespace Status {

QString toQString(const std::string &str)
{
    return QString::fromStdString(str);
}

QString toQString(const fs::path &path) {
    return toQString(path.string());
}

fs::path toPath(const QString &pathStr) {
    return fs::path(pathStr.toStdString());
}

}
