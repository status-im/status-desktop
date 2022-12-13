#include "TextUtils.h"

#include <QQmlEngine>
#include <QTextDocumentFragment>

TextUtils::TextUtils(QObject *parent) :
    QObject(parent)
{

}

QObject *TextUtils::qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    static TextUtils instance;
    QQmlEngine::setObjectOwnership(&instance, QQmlEngine::CppOwnership);

    return &instance;
}

QString TextUtils::htmlToPlainText(const QString &html) {
    return QTextDocumentFragment::fromHtml( html ).toPlainText();
}
