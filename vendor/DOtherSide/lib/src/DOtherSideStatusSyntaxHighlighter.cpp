#include "DOtherSide/DOtherSideStatusSyntaxHighlighter.h"
#include <QQuickTextDocument>
#include <Qt>
#include <QBrush>

StatusSyntaxHighlighter::StatusSyntaxHighlighter(QTextDocument *parent)
    : QSyntaxHighlighter(parent)
{
    HighlightingRule rule;

//BOLD
    singlelineBoldFormat.setFontWeight(QFont::Bold);
    rule.pattern = QRegularExpression(QStringLiteral("(\\*\\*(.*?)\\*\\*)|(\\_\\_(.*?)\\_\\_)"));
    rule.format = singlelineBoldFormat;
    highlightingRules.append(rule);
//BOLD

//ITALIC
    singleLineItalicFormat.setFontItalic(true);
    rule.pattern = QRegularExpression(QStringLiteral("(\\*(.*?)\\*)|(\\_(.*?)\\_)"));
    rule.format = singleLineItalicFormat;
    highlightingRules.append(rule);
//ITALIC

//CODE
    singlelineCodeBlockFormat.setFontFamily("Roboto Mono");
    singlelineCodeBlockFormat.setBackground(QBrush(Qt::lightGray));
    rule.pattern = QRegularExpression(QStringLiteral("\\`(.*?)\\`"));
    rule.format = singlelineCodeBlockFormat;
    highlightingRules.append(rule);
//CODE

//STRIKETHROUGH
    singleLineStrikeThroughFormat.setFontStrikeOut(true);
    rule.pattern = QRegularExpression(QStringLiteral("\\~\\~(.*?)\\~\\~"));
    rule.format = singleLineStrikeThroughFormat;
    highlightingRules.append(rule);
//STRIKETHROUGH

//CODE BLOCK
    multiLineCodeBlockFormat.setFontFamily("Roboto Mono");
    multiLineCodeBlockFormat.setBackground(QBrush(Qt::lightGray));
    rule.pattern = QRegularExpression(QStringLiteral("\\`\\`\\`(.*?)\\`\\`\\`"));
    rule.format = multiLineCodeBlockFormat;
    highlightingRules.append(rule);
//CODE BLOCK
}

void StatusSyntaxHighlighter::highlightBlock(const QString &text)
{
    for (const HighlightingRule &rule : qAsConst(highlightingRules)) {
        QRegularExpressionMatchIterator matchIterator = rule.pattern.globalMatch(text);
        while (matchIterator.hasNext()) {
            QRegularExpressionMatch match = matchIterator.next();
            setFormat(match.capturedStart(), match.capturedLength(), rule.format);
        }
    }
    setCurrentBlockState(0);
}

QQuickTextDocument *StatusSyntaxHighlighterHelper::quickTextDocument() const {
    return m_quicktextdocument;
}

void StatusSyntaxHighlighterHelper::setQuickTextDocument(
        QQuickTextDocument *quickTextDocument) {
    m_quicktextdocument = quickTextDocument;
    if (m_quicktextdocument) {
        new StatusSyntaxHighlighter(m_quicktextdocument->textDocument());
    }
}
