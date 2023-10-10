#include "testsrunner.h"

#include <QDir>
#include <QProcess>

TestsRunner::TestsRunner(const QString& testRunnerExecutablePath,
                         const QString& testsBasePath, QObject* parent)
    : QObject{parent}, m_testRunnerExecutablePath{testRunnerExecutablePath},
      m_testsBasePath{testsBasePath}
{
}

int TestsRunner::testsCount(const QString& fileName)
{
    QStringList arguments;
    arguments << QStringLiteral("-functions");
    arguments << QStringLiteral("-input")
              << m_testsBasePath + QDir::separator() + fileName;

    QProcess testRunnerProcess;
    testRunnerProcess.setProgram(m_testRunnerExecutablePath);
    testRunnerProcess.setArguments(arguments);
    testRunnerProcess.open(QIODevice::Text | QIODevice::ReadWrite);
    testRunnerProcess.waitForFinished();

    if (testRunnerProcess.exitCode())
        return 0;

    QByteArray functions = testRunnerProcess.readAllStandardError();
    return functions.count('\n');
}

QObject* TestsRunner::runTests(const QString& fileName)
{
    QStringList arguments;
    arguments << QStringLiteral("-platform") << QStringLiteral("offscreen");
    arguments << QStringLiteral("-input")
              << m_testsBasePath + QDir::separator() + fileName;

    QProcess *testRunnerProcess = new QProcess(this);
    testRunnerProcess->setProcessChannelMode(QProcess::ForwardedChannels);
    testRunnerProcess->start(m_testRunnerExecutablePath, arguments);

    using FinishHandlerType = void (QProcess::*)(int, QProcess::ExitStatus);

    connect(testRunnerProcess,
            static_cast<FinishHandlerType>(&QProcess::finished),
            testRunnerProcess, &QObject::deleteLater);

    return testRunnerProcess;
}

QString TestsRunner::testsPath() const
{
    return m_testsBasePath;
}
