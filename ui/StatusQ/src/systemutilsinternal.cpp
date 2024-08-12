#include "StatusQ/systemutilsinternal.h"

SystemUtilsInternal::SystemUtilsInternal(QObject *parent)
    : QObject{parent}
{}

QString SystemUtilsInternal::qtRuntimeVersion() const {
    return qVersion();
}
