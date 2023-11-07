#pragma once

#include <QQmlParserStatus>
#include <QRegularExpression>
#include <QSyntaxHighlighter>

class QQuickTextDocument;
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

    Q_INTERFACES(QQmlParserStatus)

public:
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

    struct HighlightingRule
    {
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
};
