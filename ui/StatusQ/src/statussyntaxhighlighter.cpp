#include "StatusQ/statussyntaxhighlighter.h"

#include <QQuickTextDocument>

StatusSyntaxHighlighter::StatusSyntaxHighlighter(QObject* parent)
    : QSyntaxHighlighter(parent)
{ }

void StatusSyntaxHighlighter::componentComplete()
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

    //STRIKETHROUGH
    singleLineStrikeThroughFormat.setFontStrikeOut(true);
    rule.pattern = QRegularExpression(QStringLiteral("\\~\\~(.*?)\\~\\~"));
    rule.format = singleLineStrikeThroughFormat;
    highlightingRules.append(rule);
    //STRIKETHROUGH

    //CODE (`foo`)
    codeFormat.setFontFamily(QStringLiteral("Roboto Mono"));
    codeFormat.setBackground(m_codeBackgroundColor);
    codeFormat.setForeground(m_codeForegroundColor);
    rule.pattern = QRegularExpression(QStringLiteral("\\`{1}(.+)\\`{1}"),
                                      // to not match single backtick pair inside a triple backtick block below
                                      QRegularExpression::InvertedGreedinessOption);
    rule.format = codeFormat;
    highlightingRules.append(rule);
    //CODE

    //CODEBLOCK (```\nfoo\nbar```)
    rule.pattern = QRegularExpression(QStringLiteral("\\`{3}(.+)\\`{3}"));
    rule.format = codeFormat;
    highlightingRules.append(rule);
    //CODEBLOCK
}

void StatusSyntaxHighlighter::highlightBlock(const QString& text)
{
    for(const HighlightingRule& rule : qAsConst(highlightingRules))
    {
        QRegularExpressionMatchIterator matchIterator =
            rule.pattern.globalMatch(text, 0, QRegularExpression::PartialPreferCompleteMatch);
        while(matchIterator.hasNext())
        {
            const QRegularExpressionMatch match = matchIterator.next();
            setFormat(match.capturedStart(), match.capturedLength(), rule.format);
        }
    }
}

QQuickTextDocument* StatusSyntaxHighlighter::quickTextDocument() const
{
    return m_quicktextdocument;
}

void StatusSyntaxHighlighter::setQuickTextDocument(QQuickTextDocument* quickTextDocument)
{
    if(!quickTextDocument) return;
    if(quickTextDocument == m_quicktextdocument) return;

    m_quicktextdocument = quickTextDocument;
    setDocument(m_quicktextdocument->textDocument());
    emit quickTextDocumentChanged();
}

QColor StatusSyntaxHighlighter::codeBackgroundColor() const
{
    return m_codeBackgroundColor;
}

void StatusSyntaxHighlighter::setCodeBackgroundColor(const QColor& color)
{
    if(color == m_codeBackgroundColor) return;
    m_codeBackgroundColor = color;
    emit codeBackgroundColorChanged();
}

QColor StatusSyntaxHighlighter::codeForegroundColor() const
{
    return m_codeForegroundColor;
}

void StatusSyntaxHighlighter::setCodeForegroundColor(const QColor& color)
{
    if(color == m_codeForegroundColor) return;
    m_codeForegroundColor = color;
    emit codeForegroundColorChanged();
}
