#pragma once
#include <QDateTime>
#include <QDebug>
#include <QString>

void logFormatter(QtMsgType type, const QMessageLogContext& context, const QString& msg);
