#include "cachecleaner.h"

#include <QQmlEngine>

CacheCleaner::CacheCleaner(QQmlEngine* engine)
    : engine(engine)
{
}

void CacheCleaner::clearComponentCache() const {
    engine->clearComponentCache();
}
