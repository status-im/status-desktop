#include "MonitorQtOutput.h"

#include <stdio.h>
#include <stdlib.h>

std::weak_ptr<QString> MonitorQtOutput::m_qtMessageOutputForSharing;
std::mutex MonitorQtOutput::m_mutex;


MonitorQtOutput::MonitorQtOutput()
{
    // Ensure only one instance registers a handler
    // Warning: don't QT's call loger functions inside the critical section
    std::unique_lock<std::mutex> localLock(m_mutex);
    auto globalMsgOut = m_qtMessageOutputForSharing.lock();
    if(!globalMsgOut) {
        // Install message handler if not already done
        m_thisMessageOutput = std::make_shared<QString>();
        m_qtMessageOutputForSharing = m_thisMessageOutput;
        qInstallMessageHandler(qtMessageOutput);
    }
    else {
        m_thisMessageOutput = globalMsgOut;
        m_start = m_thisMessageOutput->length();
    }
}

MonitorQtOutput::~MonitorQtOutput()
{
    std::unique_lock<std::mutex> localLock(m_mutex);
    if(m_thisMessageOutput.use_count() == 1) {
        // Last instance, deregister the handler
        qInstallMessageHandler(0);
        m_thisMessageOutput.reset();
    }
}

void
MonitorQtOutput::qtMessageOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    std::unique_lock<std::mutex> localLock(m_mutex);
    auto globalMsgOut = m_qtMessageOutputForSharing.lock();
    assert(globalMsgOut != nullptr);
    globalMsgOut->append(msg + '\n');
}

QString
MonitorQtOutput::qtOuput()
{
    assert(m_thisMessageOutput->length() >= m_start);
    return m_thisMessageOutput->right(m_thisMessageOutput->length() - m_start);
}
