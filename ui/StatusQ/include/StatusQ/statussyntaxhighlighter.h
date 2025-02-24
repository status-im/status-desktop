#pragma once

#include <QFlags>
#include <QQmlParserStatus>
#include <QQuickTextDocument>
#include <QRegularExpression>
#include <QSyntaxHighlighter>

class QTextCharFormat;

class StatusSyntaxHighlighter : public QSyntaxHighlighter, public QQmlParserStatus
{
    Q_OBJECT

    Q_PROPERTY(QQuickTextDocument* quickTextDocument READ quickTextDocument WRITE setQuickTextDocument NOTIFY
                   quickTextDocumentChanged)
    Q_PROPERTY(QColor codeBackgroundColor READ codeBackgroundColor WRITE setCodeBackgroundColor NOTIFY
                   codeBackgroundColorChanged)
    Q_PROPERTY(QColor codeForegroundColor READ codeForegroundColor WRITE setCodeForegroundColor NOTIFY
                   codeForegroundColorChanged)
    Q_PROPERTY(QColor hyperlinkColor READ hyperlinkColor WRITE setHyperlinkColor NOTIFY
                   hyperlinkColorChanged)
    Q_PROPERTY(QColor hyperlinkHoverColor READ hyperlinkHoverColor WRITE setHyperlinkHoverColor NOTIFY
                   hyperlinkHoverColorChanged)
    Q_PROPERTY(QStringList hyperlinks READ hyperlinks WRITE setHyperlinks NOTIFY
                    hyperlinksChanged)
    Q_PROPERTY(QString highlightedHyperlink READ highlightedHyperlink WRITE setHighlightedHyperlink NOTIFY
                    highlightedHyperlinkChanged)

    Q_PROPERTY(Features features READ features WRITE setFeatures NOTIFY featuresChanged)

    Q_INTERFACES(QQmlParserStatus)

public:
    enum FeatureFlags {
        None = 0,
        SingleLineBold = 1 << 0,
        SingleLineItalic = 1 << 1,
        Code = 1 << 2,
        CodeBlock = 1 << 3,
        SingleLineStrikeThrough = 1 << 4,
        Hyperlink = 1 << 5,
        HighlightedHyperlink = 1 << 6,
        All = SingleLineBold | SingleLineItalic | Code | CodeBlock | SingleLineStrikeThrough | Hyperlink | HighlightedHyperlink
    };
    Q_DECLARE_FLAGS(Features, FeatureFlags)
    Q_FLAG(Features)

    explicit StatusSyntaxHighlighter(QObject* parent = nullptr);

    QQuickTextDocument* quickTextDocument() const;
    void setQuickTextDocument(QQuickTextDocument* quickTextDocument);

protected:
    void classBegin() override{};
    void componentComplete() override;
    void highlightBlock(const QString& text) override;

signals:
    void quickTextDocumentChanged();
    void codeBackgroundColorChanged();
    void codeForegroundColorChanged();
    void hyperlinkColorChanged();
    void hyperlinkHoverColorChanged();
    void hyperlinksChanged();
    void highlightedHyperlinkChanged();
    void featuresChanged();

private:
    QQuickTextDocument* m_quicktextdocument{nullptr};

    QColor m_codeBackgroundColor;
    QColor codeBackgroundColor() const;
    void setCodeBackgroundColor(const QColor& color);

    QColor m_codeForegroundColor;
    QColor codeForegroundColor() const;
    void setCodeForegroundColor(const QColor& color);

    QColor m_hyperlinkColor;
    QColor hyperlinkColor() const;
    void setHyperlinkColor(const QColor& color);

    QColor m_hyperlinkHoverColor;
    QColor hyperlinkHoverColor() const;
    void setHyperlinkHoverColor(const QColor& color);

    QStringList m_hyperlinks;
    QStringList hyperlinks() const;
    void setHyperlinks(const QStringList& hyperlinks);
    QRegularExpression hyperlinksRegularExpression() const;

    QString m_highlightedHyperlink;
    QString highlightedHyperlink() const;
    void setHighlightedHyperlink(const QString& hyperlink);
    QRegularExpression highlightedHyperlinkRegularExpression() const;

    QStringList getPossibleUrlFormats(const QUrl& url) const;
    QRegularExpression buildHyperlinkRegex(QStringList hyperlinks) const;

    Features features() const;
    void setFeatures(Features features);

    void buildRules();
    int findRuleIndex(FeatureFlags flag) const;

    struct HighlightingRule
    {
        int id;
        QRegularExpression pattern;
        QRegularExpression::MatchType matchType{QRegularExpression::PartialPreferCompleteMatch};
        QTextCharFormat format;
    };
    QVector<HighlightingRule> highlightingRules{7};

    QTextCharFormat singlelineBoldFormat;
    QTextCharFormat singleLineItalicFormat;
    QTextCharFormat codeFormat;
    QTextCharFormat singleLineStrikeThroughFormat;
    QTextCharFormat hyperlinkFormat;
    QTextCharFormat highlightedHyperlinkFormat;

    Features m_features{All};
};

Q_DECLARE_OPERATORS_FOR_FLAGS(StatusSyntaxHighlighter::Features)
