#include "cachecleaner.h"

#include <QCoreApplication>
#include <QQmlEngine>

CacheCleaner::CacheCleaner(QQmlEngine* engine)
    : engine(engine)
{
}

void CacheCleaner::clearComponentCache() const {
    engine->collectGarbage();
    QCoreApplication::sendPostedEvents(nullptr, QEvent::DeferredDelete);
    QCoreApplication::processEvents();

    engine->clearComponentCache();
}
