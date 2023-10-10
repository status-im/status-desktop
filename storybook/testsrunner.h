#pragma once

#include <QObject>

class TestsRunner : public QObject
{
    Q_OBJECT
public:
    explicit TestsRunner(const QString& testRunnerExecutablePath,
                         const QString& testsPath, QObject *parent = nullptr);

    Q_INVOKABLE int testsCount(const QString& path);
    Q_INVOKABLE QObject* runTests(const QString& path);
    Q_INVOKABLE QString testsPath() const;

private:
    QString m_testRunnerExecutablePath;
    QString m_testsBasePath;
};
