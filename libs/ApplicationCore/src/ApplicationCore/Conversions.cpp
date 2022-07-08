#include "Conversions.h"

namespace fs = std::filesystem;

namespace Status {

QString toString(const fs::path &path) {
    return QString::fromStdString(path.string());
}

fs::path toPath(const QString &pathStr) {
    return fs::path(pathStr.toStdString());
}

}
