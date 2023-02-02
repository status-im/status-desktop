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

private:
    QQuickTextDocument* m_quicktextdocument{nullptr};

    QColor m_codeBackgroundColor;
    QColor codeBackgroundColor() const;
    void setCodeBackgroundColor(const QColor& color);

    QColor m_codeForegroundColor;
    QColor codeForegroundColor() const;
    void setCodeForegroundColor(const QColor& color);

    struct HighlightingRule
    {
        QRegularExpression pattern;
        QTextCharFormat format;
    };
    QVector<HighlightingRule> highlightingRules{5};

    QTextCharFormat singlelineBoldFormat;
    QTextCharFormat singleLineItalicFormat;
    QTextCharFormat codeFormat;
    QTextCharFormat singleLineStrikeThroughFormat;
};
