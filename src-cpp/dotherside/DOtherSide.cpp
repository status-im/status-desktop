#include "DOtherSide.h"
#include "SpellChecker.h"
#include "StatusSyntaxHighlighter.h"
#include "StatusWindow.h"

void DOtherSide::registerMetaTypes()
{
    qRegisterMetaType<QVector<int>>();
    qmlRegisterType<StatusWindow>("DotherSide", 0, 1, "StatusWindow");
    qmlRegisterType<StatusSyntaxHighlighterHelper>("DotherSide", 0, 1, "StatusSyntaxHighlighter");
    qmlRegisterType<SpellChecker>("DotherSide", 0, 1, "SpellChecker");
}
