#pragma once

#include <QObject>
#include <QStringList>
#include <QTimer>
#include <QVariantList>

// One editor's asynchronous spell-check session. The dictionary and worker are shared.
class SpellChecker : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(bool skipCapitalizedWords READ skipCapitalizedWords WRITE setSkipCapitalizedWords NOTIFY skipCapitalizedWordsChanged)
    Q_PROPERTY(int cursorPosition READ cursorPosition WRITE setCursorPosition NOTIFY cursorPositionChanged)
    Q_PROPERTY(bool composing READ composing WRITE setComposing NOTIFY composingChanged)
    Q_PROPERTY(QVariantList issues READ issues NOTIFY issuesChanged)
    Q_PROPERTY(QStringList suggestions READ suggestions NOTIFY suggestionsChanged)
    Q_PROPERTY(bool suggestionsPending READ suggestionsPending NOTIFY suggestionsChanged)
    Q_PROPERTY(int suggestionStart READ suggestionStart NOTIFY suggestionsChanged)
    Q_PROPERTY(QString suggestionWord READ suggestionWord NOTIFY suggestionsChanged)

public:
    explicit SpellChecker(QObject* parent = nullptr);
    bool enabled() const { return m_enabled; }
    void setEnabled(bool value);
    QString language() const { return m_language; }
    void setLanguage(const QString& value);
    bool skipCapitalizedWords() const { return m_skipCapitalizedWords; }
    void setSkipCapitalizedWords(bool value);
    int cursorPosition() const { return m_cursorPosition; }
    void setCursorPosition(int value);
    bool composing() const { return m_composing; }
    void setComposing(bool value);
    QVariantList issues() const { return m_issues; }
    QStringList suggestions() const { return m_suggestions; }
    bool suggestionsPending() const { return m_suggestionsPending; }
    int suggestionStart() const { return m_suggestionStart; }
    QString suggestionWord() const { return m_suggestionWord; }

    void setText(const QString& text);
    void recheck();

    Q_INVOKABLE QVariantMap issueAt(int position) const;
    Q_INVOKABLE void requestSuggestions(int position);
    Q_INVOKABLE void clearSuggestions();

signals:
    void enabledChanged();
    void languageChanged();
    void skipCapitalizedWordsChanged();
    void cursorPositionChanged();
    void composingChanged();
    void issuesChanged();
    void checkFinished();
    void suggestionsChanged();
    void errorOccurred(const QString& message);

private:
    bool supported() const;
    void invalidate();
    void updateIncompleteWord(int position);
    void dispatch();
    void dispatchSuggestions();

    quint64 m_id;
    quint64 m_generation = 0;
    quint64 m_suggestionRequest = 0;
    bool m_enabled = true;
    QString m_language = QStringLiteral("en_US");
    bool m_skipCapitalizedWords = true;
    int m_cursorPosition = -1;
    int m_incompleteEnd = -1;
    bool m_checkPending = false;
    bool m_composing = false;
    bool m_inFlight = false;
    QString m_text;
    QTimer m_timer;
    QVariantList m_issues;
    QStringList m_suggestions;
    bool m_suggestionsPending = false;
    bool m_suggestionsInFlight = false;
    int m_suggestionStart = -1;
    QString m_suggestionWord;
};
