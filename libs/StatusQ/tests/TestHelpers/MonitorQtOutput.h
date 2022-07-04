#pragma once

#include <QQuickItem>
#include <QtGlobal>

#include <memory>
#include <mutex>

namespace Status::Testing {

///
/// \brief Monitor output for tests and declaratively control message handler availability
///
/// The captured buffer is global and each instance has a reference to it and a start pointer
/// from its creation or last clear call
/// The first instance installs a QT message handler @see Qt::qInstallMessageHandler then
/// All other instances share the global buffer until the last instance goes out of scope and deregisters
/// from Qt's global message handler and destroyes the buffer
///
/// \todo Check that QML doesn't keep instance between test runs
///
class MonitorQtOutput : public QQuickItem
{
    Q_OBJECT

    QML_ELEMENT
public:
    MonitorQtOutput();
    ~MonitorQtOutput();

    /// Return captured output from the global buffer. That is from the instantiation or last `clear()` was called
    Q_INVOKABLE QString qtOuput();
    /// Reset buffer start after the last line. qtOutput won't return anything until new output is captured
    Q_INVOKABLE void restartCapturing();

signals:

private:
    static void qtMessageOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg);
    static QtMessageHandler m_previousHandler;

    // Use it to keep track of qInstallMessageHandler call
    static std::weak_ptr<QString> m_qtMessageOutputForSharing;
    static std::mutex m_mutex;
    std::shared_ptr<QString> m_thisMessageOutput;
    int m_start = 0;
};

}
