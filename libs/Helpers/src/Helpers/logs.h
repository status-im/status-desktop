#pragma once

#include <QDateTime>
#include <QDebug>
#include <QString>

namespace Status::Helpers {

/// Formats with colloring output if not a development build
void logFormatter(QtMsgType type, const QMessageLogContext& context, const QString& msg);

}
