#pragma once

#include <QQuickItem>
#include <QtGlobal>

#include <memory>
#include <mutex>

///
/// \brief Monitor output for tests and declarativelly control message handler availability
/// \todo Check that QML doesn't keep instance between test runs
///
class MonitorQtOutput : public QQuickItem
{
    Q_OBJECT
public:
    MonitorQtOutput();
    ~MonitorQtOutput();

    Q_INVOKABLE QString qtOuput();

signals:

private:
    static void qtMessageOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg);

    // Use it to keep track of qInstallMessageHandler call
    static std::weak_ptr<QString> m_qtMessageOutputForSharing;
    static std::mutex m_mutex;
    std::shared_ptr<QString> m_thisMessageOutput;
    int m_start = 0;
};
