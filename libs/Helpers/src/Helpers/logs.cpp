#include "helpers.h"

#include <QDateTime>
#include <QDebug>
#include <QString>

#include <iostream>

#include "BuildConfiguration.h"

namespace Status::Helpers {

void logFormatter(QtMsgType type, const QMessageLogContext& context, const QString& msg)
{
    // TODO: Refactor it into development-tools app
    //if(isDebugBuild()) {
        std::cout << msg.toLocal8Bit().data() << std::endl;
        return;
    //}

    QByteArray localMsg = msg.toLocal8Bit();
    const char* file = context.file ? context.file : "";
    QByteArray function =
        context.function
            ? (QString(QStringLiteral("\033[0;33mfunction=\033[94m") + QString(context.function)).toLocal8Bit())
            : QString("").toLocal8Bit();
    QByteArray timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss.zzz").toLocal8Bit();

    const char* log;

    switch(type)
    {
    case QtDebugMsg: log = "\033[0;90mDBG \033[0m%s \033[1m%s \033[0;33mfile=\033[94m%s:%u %s\n"; break;
    case QtInfoMsg: log = "\033[0;36mINF \033[0m%s \033[1m%s \033[0;33mfile=\033[94m%s:%u %s\n"; break;
    case QtWarningMsg: log = "\033[0;33mWRN \033[0m%s \033[1m%s \033[0;33mfile=\033[94m%s:%u %s\n"; break;
    case QtCriticalMsg: log = "\033[0;91mCRT \033[0m%s \033[1;91m%s \033[0;33mfile=\033[94m%s:%u %s\n"; break;
    case QtFatalMsg: log = "\033[0;31m!!! \033[0m%s \033[1m%s \033[0;33mfile=\033[94m%s:%u %s\n"; break;
    }
    fprintf(type == QtCriticalMsg || type == QtFatalMsg ? stderr : stdout,
            log, timestamp.constData(), localMsg.constData(), file, context.line, function.constData());
}

}   // namespace
