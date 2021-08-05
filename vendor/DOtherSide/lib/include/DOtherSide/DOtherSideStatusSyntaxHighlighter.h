#ifndef STATUSSYNTAXHIGHLIGHTER_H
#define STATUSSYNTAXHIGHLIGHTER_H

#include <QSyntaxHighlighter>
#include <QTextCharFormat>
#include <QRegularExpression>

class QQuickTextDocument;

class StatusSyntaxHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT

public:
    StatusSyntaxHighlighter(QTextDocument *parent = nullptr);

protected:
    void highlightBlock(const QString &text) override;

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

class StatusSyntaxHighlighterHelper : public QObject {
  Q_OBJECT
  Q_PROPERTY(QQuickTextDocument *quickTextDocument READ quickTextDocument WRITE
                 setQuickTextDocument NOTIFY quickTextDocumentChanged)
public:
  StatusSyntaxHighlighterHelper(QObject *parent = nullptr)
      : QObject(parent), m_quicktextdocument(nullptr) {}
  QQuickTextDocument *quickTextDocument() const;
  void setQuickTextDocument(QQuickTextDocument *quickTextDocument);
signals:
  void quickTextDocumentChanged();

private:
  QQuickTextDocument *m_quicktextdocument;
};
#endif // STATUSSYNTAXHIGHLIGHTER_H
