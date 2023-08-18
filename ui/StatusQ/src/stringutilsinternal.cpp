#include "StatusQ/stringutilsinternal.h"

StringUtilsInternal::StringUtilsInternal(QObject* parent)
    : QObject(parent)
{
}

QString StringUtilsInternal::escapeHtml(const QString &unsafe) const
{
    return unsafe.toHtmlEscaped();
}

QObject* StringUtilsInternal::qmlInstance(QQmlEngine *engine,
                                          QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    return new StringUtilsInternal;
}
