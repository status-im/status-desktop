#include "StatusQ/systemutilsinternal.h"

#include <QCoreApplication>
#include <QProcess>

SystemUtilsInternal::SystemUtilsInternal(QObject *parent)
    : QObject{parent}
{}

QString SystemUtilsInternal::qtRuntimeVersion() const {
    return qVersion();
}

void SystemUtilsInternal::restartApplication() const
{
    QProcess::startDetached(QCoreApplication::applicationFilePath(), {});
    QMetaObject::invokeMethod(QCoreApplication::instance(), "quit", Qt::QueuedConnection);
}
