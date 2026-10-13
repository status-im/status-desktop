#include <StatusQ/systemutilsinternal.h>

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLocalServer>
#include <QLocalSocket>
#include <QLockFile>
#include <QProcess>
#include <QProcessEnvironment>
#include <QTemporaryDir>
#include <QTest>
#include <QThread>
#include <QTimer>

#include <cstdio>

namespace {

int runRestartHelper(QCoreApplication& app)
{
    const auto directory = qEnvironmentVariable("STATUSQ_RESTART_TEST_DIRECTORY");
    const auto reportPath = directory + "/report.json";
    const auto serverName = "statusq-restart-" + QFileInfo(directory).fileName();
    QLockFile lock(directory + "/backend.lock");

    if (qEnvironmentVariable("STATUSQ_RESTART_TEST_PHASE") == "relaunch") {
        if (qEnvironmentVariable("STATUSQ_RESTART_TEST_REQUEST") == "closed-output") {
            QThread::msleep(600);
            std::fputs("Replacement stdout\n", stdout);
            std::fflush(stdout);
            std::fputs("Replacement stderr\n", stderr);
            std::fflush(stderr);
        }
        QLocalSocket socket;
        socket.connectToServer(serverName);
        const bool previousInstancePresent = socket.waitForConnected(100);
        const bool backendReleased = lock.tryLock(0);
        QJsonObject report {
            {"arguments", QJsonArray::fromStringList(app.arguments().mid(1))},
            {"workingDirectory", QDir::currentPath()},
            {"environment", qEnvironmentVariable("STATUSQ_RESTART_TEST_VALUE")},
            {"previousInstancePresent", previousInstancePresent},
            {"backendReleased", backendReleased}
        };
        QFile file(reportPath);
        if (!file.open(QIODevice::WriteOnly | QIODevice::Append))
            return 1;
        const auto data = QJsonDocument(report).toJson(QJsonDocument::Compact) + '\n';
        return file.write(data) == data.size() ? 0 : 2;
    }

    QLocalServer server;
    if (!server.listen(serverName) || !lock.tryLock(0))
        return 3;

    QTimer::singleShot(0, &app, [&app, directory] {
        const auto request = qEnvironmentVariable("STATUSQ_RESTART_TEST_REQUEST");
        if (request == "quit") {
            app.quit();
            return;
        }

        qputenv("STATUSQ_RESTART_TEST_PHASE", "relaunch");
        SystemUtilsInternal utils;
        if (request == "no-argument")
            utils.restartApplication();
        else
            utils.restartApplication(request == "kill-backend");

        // A second caller must not schedule a second replacement process.
        SystemUtilsInternal otherUtils;
        otherUtils.restartApplication();
        qputenv("STATUSQ_RESTART_TEST_VALUE", "changed during teardown");
        if (!QDir::setCurrent(directory))
            qFatal("Cannot change helper working directory");
    });

    const int result = app.exec();
    // Model the slow backend teardown that happens after exec() returns in Nim.
    QThread::msleep(700);
    if (QFile::exists(reportPath))
        return 4;
    lock.unlock();
    server.close();
    if (qEnvironmentVariable("STATUSQ_RESTART_TEST_REQUEST") == "launch-failure"
            && !QDir().rmdir(directory + "/working directory"))
        return 5;
    return result;
}

} // namespace

class tst_RestartApplication : public QObject
{
    Q_OBJECT

private slots:
    void restart_data()
    {
        QTest::addColumn<QString>("request");
        QTest::addColumn<QStringList>("arguments");
        QTest::newRow("no arguments") << QString("no-argument") << QStringList();
        const QStringList arguments {"--datadir", "data directory", "value with \"quotes\""};
        QTest::newRow("preserve arguments") << QString("restart") << arguments;
        QTest::newRow("desktop ignores killBackend") << QString("kill-backend") << arguments;
        QTest::newRow("launcher closes output pipes") << QString("closed-output") << arguments;
        QTest::newRow("launch failure is logged") << QString("launch-failure") << arguments;
        QTest::newRow("ordinary quit does not restart") << QString("quit") << arguments;
    }

    void restart()
    {
        QFETCH(QString, request);
        QFETCH(QStringList, arguments);
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        const auto workingDirectory = directory.path() + "/working directory";
        QVERIFY(QDir().mkpath(workingDirectory));

        auto environment = QProcessEnvironment::systemEnvironment();
        environment.insert("STATUSQ_RESTART_TEST_DIRECTORY", directory.path());
        environment.insert("STATUSQ_RESTART_TEST_PHASE", "request");
        environment.insert("STATUSQ_RESTART_TEST_REQUEST", request);
        environment.insert("STATUSQ_RESTART_TEST_VALUE", "preserved value");
        QProcess process;
        process.setProcessEnvironment(environment);
        process.setWorkingDirectory(workingDirectory);
        process.start(QCoreApplication::applicationFilePath(), arguments);
        QVERIFY(process.waitForStarted());
        if (!process.waitForFinished(10000)) {
            process.kill();
            process.waitForFinished();
            QFAIL("Restart helper did not shut down");
        }
        QCOMPARE(process.exitStatus(), QProcess::NormalExit);
        const auto output = process.readAllStandardError();
        QVERIFY2(process.exitCode() == 0, output.constData());
        if (request == "closed-output") {
            process.closeReadChannel(QProcess::StandardOutput);
            process.closeReadChannel(QProcess::StandardError);
        }

        QFile reportFile(directory.path() + "/report.json");
        if (request == "launch-failure") {
            QVERIFY2(output.contains("Failed to restart application:"), output.constData());
            QVERIFY(!reportFile.exists());
            return;
        }
        if (request == "quit") {
            QVERIFY(!reportFile.exists());
            return;
        }

        QTRY_VERIFY_WITH_TIMEOUT(reportFile.exists() && reportFile.size() > 0, 10000);
        QTest::qWait(200);
        QVERIFY(reportFile.open(QIODevice::ReadOnly));
        const auto reports = reportFile.readAll().trimmed().split('\n');
        QCOMPARE(reports.size(), 1);
        QJsonParseError error;
        const auto report = QJsonDocument::fromJson(reports.first(), &error).object();
        QCOMPARE(error.error, QJsonParseError::NoError);
        QCOMPARE(report["arguments"].toArray(), QJsonArray::fromStringList(arguments));
        QCOMPARE(report["workingDirectory"].toString(), QDir(workingDirectory).canonicalPath());
        QCOMPARE(report["environment"].toString(), QString("preserved value"));
        QVERIFY(!report["previousInstancePresent"].toBool());
        QVERIFY(report["backendReleased"].toBool());
    }
};

int main(int argc, char* argv[])
{
    QCoreApplication app(argc, argv);
    if (qEnvironmentVariableIsSet("STATUSQ_RESTART_TEST_DIRECTORY"))
        return runRestartHelper(app);

    tst_RestartApplication test;
    return QTest::qExec(&test, argc, argv);
}

#include "tst_restartapplication.moc"
