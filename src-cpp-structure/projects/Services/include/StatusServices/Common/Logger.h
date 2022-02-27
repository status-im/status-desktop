#pragma once

#include <QtCore>

namespace Status
{
    // This logger class should be done far better, but this is like a first aid. :)
    // We should improve this class using `qInstallMessageHandler` and `fmt` library for example
    // and make custom logging in the form and place/file we want.

    class Logger final {
    public:

        static void init()
        {
            qInstallMessageHandler(messageHandler);
        }

        static void messageHandler(const QtMsgType type, const QMessageLogContext &context, const QString &msg)
        {
            const char* time = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss.zzz").toLocal8Bit().constData();
            const char* localMsg = msg.toLocal8Bit().constData();
            const char* file = context.file? context.file : "";
            const char* function = context.function? context.function : "";

            switch (type) {
            case QtDebugMsg:
                fprintf(stderr, "Status-DEB [%s] (%s:%u, %s)\nMSG: %s\n", time, file, context.line, function, localMsg);
                break;
            case QtInfoMsg:
                fprintf(stderr, "Status-INF [%s] (%s:%u, %s)\nMSG: %s\n", time, file, context.line, function, localMsg);
                break;
            case QtWarningMsg:
                fprintf(stderr, "Status-WRN [%s] (%s:%u, %s)\nMSG: %s\n", time, file, context.line, function, localMsg);
                break;
            case QtCriticalMsg:
                fprintf(stderr, "Status-CRT [%s] (%s:%u, %s)\nMSG: %s\n", time, file, context.line, function, localMsg);
                break;
            case QtFatalMsg:
                fprintf(stderr, "Status-FAT [%s] (%s:%u, %s)\nMSG: %s\n", time, file, context.line, function, localMsg);
                break;
            }
        }
    };
}
