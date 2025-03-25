#include "StatusQ/statussyntaxhighlighter.h"

#include <QQuickTextDocument>
#include <QUrl>

StatusSyntaxHighlighter::StatusSyntaxHighlighter(QObject* parent)
    : QSyntaxHighlighter(parent)
{ }

void StatusSyntaxHighlighter::componentComplete()
{
    buildRules();

    connect(this, &StatusSyntaxHighlighter::hyperlinksChanged, this, [this](){
        const auto index = findRuleIndex(StatusSyntaxHighlighter::Hyperlink);
        if (index == -1) return;

        highlightingRules[index].pattern = hyperlinksRegularExpression();
        rehighlight();
    });
    connect(this, &StatusSyntaxHighlighter::hyperlinkColorChanged, this, [this](){
        const auto index = findRuleIndex(StatusSyntaxHighlighter::Hyperlink);
        if (index == -1) return;

        hyperlinkFormat.setForeground(m_hyperlinkColor);
        highlightedHyperlinkFormat.setForeground(m_hyperlinkColor);
        highlightingRules[index].format = hyperlinkFormat;
        rehighlight();
    });

    connect(this, &StatusSyntaxHighlighter::highlightedHyperlinkChanged, this, [this](){
        const auto index = findRuleIndex(StatusSyntaxHighlighter::HighlightedHyperlink);
        if (index == -1) return;

        highlightingRules[index].pattern = highlightedHyperlinkRegularExpression();
        rehighlight();
    });
    connect(this, &StatusSyntaxHighlighter::hyperlinkHoverColorChanged, this, [this](){
        const auto index = findRuleIndex(StatusSyntaxHighlighter::HighlightedHyperlink);
        if (index == -1) return;

        highlightedHyperlinkFormat.setBackground(m_hyperlinkHoverColor);
        highlightingRules[index].format = highlightedHyperlinkFormat;
        rehighlight();
    });

    connect(this, &StatusSyntaxHighlighter::featuresChanged, this, [this](){
        buildRules();
        rehighlight();
    });
}

void StatusSyntaxHighlighter::buildRules()
{
    HighlightingRule rule;
    highlightingRules.clear();

    if (m_features & StatusSyntaxHighlighter::SingleLineBold)
    {
        //BOLD
        singlelineBoldFormat.setFontWeight(QFont::Bold);
        rule.id = StatusSyntaxHighlighter::SingleLineBold;
        rule.pattern = QRegularExpression(QStringLiteral("(\\*\\*(.*?)\\*\\*)|(\\_\\_(.*?)\\_\\_)"));
        rule.format = singlelineBoldFormat;
        highlightingRules.append(rule);
        //BOLD
    }
    
    if (m_features & StatusSyntaxHighlighter::SingleLineItalic)
    {
        //ITALIC
        singleLineItalicFormat.setFontItalic(true);
        rule.id = StatusSyntaxHighlighter::SingleLineItalic;
        rule.pattern = QRegularExpression(QStringLiteral("(\\*(.*?)\\*)|(\\_(.*?)\\_)"));
        rule.format = singleLineItalicFormat;
        highlightingRules.append(rule);
        //ITALIC
    }

    if (m_features & StatusSyntaxHighlighter::SingleLineStrikeThrough)
    {
        //STRIKETHROUGH
        singleLineStrikeThroughFormat.setFontStrikeOut(true);
        rule.id = StatusSyntaxHighlighter::SingleLineStrikeThrough;
        rule.pattern = QRegularExpression(QStringLiteral("\\~\\~(.*?)\\~\\~"));
        rule.format = singleLineStrikeThroughFormat;
        highlightingRules.append(rule);
        //STRIKETHROUGH
    }

    if (m_features & StatusSyntaxHighlighter::Code)
    {
        //CODE (`foo`)
        codeFormat.setFontFamilies({ QStringLiteral("Roboto Mono") });
        codeFormat.setBackground(m_codeBackgroundColor);
        codeFormat.setForeground(m_codeForegroundColor);
        rule.id = StatusSyntaxHighlighter::Code;
        rule.pattern = QRegularExpression(QStringLiteral("\\`{1}(.+)\\`{1}"),
                                          // to not match single backtick pair inside a triple backtick block below
                                          QRegularExpression::InvertedGreedinessOption);
        rule.format = codeFormat;
        highlightingRules.append(rule);
        //CODE
    }

    if (m_features & StatusSyntaxHighlighter::CodeBlock)
    {
        //CODEBLOCK (```\nfoo\nbar```)
        rule.id = StatusSyntaxHighlighter::CodeBlock;
        rule.pattern = QRegularExpression(QStringLiteral("\\`{3}(.+)\\`{3}"));
        rule.format = codeFormat;
        highlightingRules.append(rule);
        //CODEBLOCK
    }

    if (m_features & StatusSyntaxHighlighter::Hyperlink)
    {
        //HYPERLINKS
        hyperlinkFormat.setForeground(m_hyperlinkColor);
        rule.id = StatusSyntaxHighlighter::Hyperlink;
        rule.pattern = hyperlinksRegularExpression();
        rule.format = hyperlinkFormat;
        rule.matchType = QRegularExpression::NormalMatch;
        highlightingRules.append(rule);
        //HYPERLINKS
    }

    if (m_features & StatusSyntaxHighlighter::HighlightedHyperlink)
    {
        //HIGHLIGHTED 
        highlightedHyperlinkFormat.setForeground(m_hyperlinkColor);
        highlightedHyperlinkFormat.setBackground(m_hyperlinkHoverColor);
        rule.id = StatusSyntaxHighlighter::HighlightedHyperlink;
        rule.pattern = highlightedHyperlinkRegularExpression();
        rule.format = highlightedHyperlinkFormat;
        rule.matchType = QRegularExpression::NormalMatch;
        highlightingRules.append(rule);
    }
}

void StatusSyntaxHighlighter::highlightBlock(const QString& text)
{
    for(const HighlightingRule& rule : std::as_const(highlightingRules))
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
    for(const QString& hyperlink : std::as_const(m_hyperlinks))
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
        return QRegularExpression(QStringLiteral("(?!)")); 
    QString matchHyperlinks = QStringLiteral("(?:^|(?<=\\s))(") + hyperlinks.join('|') + QStringLiteral(")(?:(?=\\s|[[:punct:]])|$)");
    auto regex = QRegularExpression(matchHyperlinks, QRegularExpression::CaseInsensitiveOption | QRegularExpression::UseUnicodePropertiesOption | QRegularExpression::MultilineOption);
    regex.optimize();
    return regex;
}

StatusSyntaxHighlighter::Features StatusSyntaxHighlighter::features() const
{
    return m_features;
}

void StatusSyntaxHighlighter::setFeatures(Features features)
{
    if(features == m_features) return;
    m_features = features;
    emit featuresChanged();
}

int StatusSyntaxHighlighter::findRuleIndex(FeatureFlags flag) const
{
    for (int i = 0; i < highlightingRules.size(); ++i)
    {
        if (highlightingRules[i].id == flag)
            return i;
    }

    return -1;
}
