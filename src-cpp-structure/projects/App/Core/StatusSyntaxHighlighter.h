#pragma once

#include <QtCore>
#include <QtGui>
#include <QtQuick/QQuickTextDocument>

namespace Status {

    class StatusSyntaxHighlighter : public QSyntaxHighlighter
    {
        Q_OBJECT

    public:
        StatusSyntaxHighlighter(QTextDocument* parent = nullptr);

    protected:
        void highlightBlock(const QString& text) override;

    private:
        struct HighlightingRule
        {
            QRegularExpression pattern;
            QTextCharFormat format;
        };
        QVector<HighlightingRule> highlightingRules;

        QTextCharFormat singlelineBoldFormat;
        QTextCharFormat singleLineItalicFormat;
        QTextCharFormat singlelineCodeBlockFormat;
        QTextCharFormat singleLineStrikeThroughFormat;
        QTextCharFormat multiLineCodeBlockFormat;
    };

    class StatusSyntaxHighlighterHelper : public QObject
    {
        Q_OBJECT
        Q_PROPERTY(QQuickTextDocument* quickTextDocument READ quickTextDocument WRITE setQuickTextDocument NOTIFY
                   quickTextDocumentChanged)
    public:
        StatusSyntaxHighlighterHelper(QObject* parent = nullptr)
            : QObject(parent)
            , m_quicktextdocument(nullptr)
        { }

        QQuickTextDocument* quickTextDocument() const;
        void setQuickTextDocument(QQuickTextDocument* quickTextDocument);
    signals:
        void quickTextDocumentChanged();

    private:
        QQuickTextDocument* m_quicktextdocument;
    };
}
