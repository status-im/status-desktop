#include "conversions.h"

namespace fs = std::filesystem;

namespace Status {

QString toQString(const fs::path &path) {
    return QString::fromStdString(path.string());
}

fs::path toPath(const QString &pathStr) {
    return fs::path(pathStr.toStdString());
}

}
