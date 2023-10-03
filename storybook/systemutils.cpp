#include "systemutils.h"

#include <QtGlobal>

SystemUtils::SystemUtils(QObject *parent) : QObject(parent) {}

QString SystemUtils::getEnvVar(const QString &varName) {
    return qEnvironmentVariable(varName.toUtf8().constData(), "");
}
