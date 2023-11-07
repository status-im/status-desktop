#include "StatusQ/statussyntaxhighlighter.h"

#include <QQuickTextDocument>
#include <QUrl>

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

    //HYPERLINKS
    //QRegularExpression to match any hyperlink in m_hyperlinks
    hyperlinkFormat.setForeground(m_hyperlinkColor);
    rule.pattern = hyperlinksRegularExpression();
    rule.format = hyperlinkFormat;
    rule.matchType = QRegularExpression::NormalMatch;
    highlightingRules.append(rule);

    const int hyperlinksRuleIndex = highlightingRules.size() - 1;

    //HIGHLIGHTED 
    highlightedHyperlinkFormat.setForeground(m_hyperlinkColor);
    highlightedHyperlinkFormat.setBackground(m_hyperlinkHoverColor);
    rule.pattern = highlightedHyperlinkRegularExpression();
    rule.format = highlightedHyperlinkFormat;
    rule.matchType = QRegularExpression::NormalMatch;
    highlightingRules.append(rule);

    const int highlightedHyperlinkRuleIndex = highlightingRules.size() - 1;

    connect(this, &StatusSyntaxHighlighter::hyperlinksChanged, this, [hyperlinksRuleIndex, this](){
        highlightingRules[hyperlinksRuleIndex].pattern = hyperlinksRegularExpression();
        rehighlight();
    });
    connect(this, &StatusSyntaxHighlighter::hyperlinkColorChanged, this, [hyperlinksRuleIndex, this](){
        hyperlinkFormat.setForeground(m_hyperlinkColor);
        highlightedHyperlinkFormat.setForeground(m_hyperlinkColor);
        highlightingRules[hyperlinksRuleIndex].format = hyperlinkFormat;
        rehighlight();
    });

    connect(this, &StatusSyntaxHighlighter::highlightedHyperlinkChanged, this, [highlightedHyperlinkRuleIndex, this](){
        highlightingRules[highlightedHyperlinkRuleIndex].pattern = highlightedHyperlinkRegularExpression();
        rehighlight();
    });
    connect(this, &StatusSyntaxHighlighter::hyperlinkHoverColorChanged, this, [highlightedHyperlinkRuleIndex, this](){
        highlightedHyperlinkFormat.setBackground(m_hyperlinkHoverColor);
        highlightingRules[highlightedHyperlinkRuleIndex].format = highlightedHyperlinkFormat;
        rehighlight();
    });
}

void StatusSyntaxHighlighter::highlightBlock(const QString& text)
{
    for(const HighlightingRule& rule : qAsConst(highlightingRules))
    {
        if(rule.pattern.pattern() == QStringLiteral("")) continue;

        QRegularExpressionMatchIterator matchIterator =
            rule.pattern.globalMatch(text, 0, rule.matchType);
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

QColor StatusSyntaxHighlighter::hyperlinkColor() const
{
    return m_hyperlinkColor;
}

void StatusSyntaxHighlighter::setHyperlinkColor(const QColor& color)
{
    if(color == m_hyperlinkColor) return;
    m_hyperlinkColor = color;
    emit hyperlinkColorChanged();
}

QColor StatusSyntaxHighlighter::hyperlinkHoverColor() const
{
    return m_hyperlinkHoverColor;
}

void StatusSyntaxHighlighter::setHyperlinkHoverColor(const QColor& color)
{
    if(color == m_hyperlinkHoverColor) return;
    m_hyperlinkHoverColor = color;
    emit hyperlinkHoverColorChanged();
}

QStringList StatusSyntaxHighlighter::hyperlinks() const
{
    return m_hyperlinks;
}

void StatusSyntaxHighlighter::setHyperlinks(const QStringList& hyperlinks)
{
    if(hyperlinks == m_hyperlinks) return;
    m_hyperlinks = hyperlinks;
    emit hyperlinksChanged();
}
QString StatusSyntaxHighlighter::highlightedHyperlink() const
{
    return m_highlightedHyperlink;
}

void StatusSyntaxHighlighter::setHighlightedHyperlink(const QString& hyperlink)
{
    if(hyperlink == m_highlightedHyperlink) return;
    m_highlightedHyperlink = hyperlink;
    emit highlightedHyperlinkChanged();
}

QRegularExpression StatusSyntaxHighlighter::highlightedHyperlinkRegularExpression() const
{
    const auto possibleUrlFormats = getPossibleUrlFormats(QUrl(m_highlightedHyperlink));
    return buildHyperlinkRegex(possibleUrlFormats);
}

QRegularExpression StatusSyntaxHighlighter::hyperlinksRegularExpression() const
{
    QStringList hyperlinks;
    for(const QString& hyperlink : qAsConst(m_hyperlinks))
    {
        const auto possibleUrlFormats = getPossibleUrlFormats(QUrl(hyperlink));
        hyperlinks.append(possibleUrlFormats);
    }

    return buildHyperlinkRegex(hyperlinks);
}

QStringList StatusSyntaxHighlighter::getPossibleUrlFormats(const QUrl& url) const
{
    QStringList result;
    result.append(QRegularExpression::escape(url.toString()));
    result.append(QRegularExpression::escape(url.toString(QUrl::EncodeUnicode)));
    result.append(QRegularExpression::escape(url.toString(QUrl::FullyEncoded)));
    return result;
}

QRegularExpression StatusSyntaxHighlighter::buildHyperlinkRegex(QStringList hyperlinks) const
{
    hyperlinks.removeAll(QString());

    if(hyperlinks.isEmpty())
        return QRegularExpression("(?!)");
    QString matchHyperlinks = QStringLiteral("(?:^|(?<=\\s))(") + hyperlinks.join("|") + QStringLiteral(")(?:(?=\\s)|$)");
    auto regex = QRegularExpression(matchHyperlinks, QRegularExpression::CaseInsensitiveOption | QRegularExpression::UseUnicodePropertiesOption | QRegularExpression::MultilineOption);
    regex.optimize();
    return regex;
}