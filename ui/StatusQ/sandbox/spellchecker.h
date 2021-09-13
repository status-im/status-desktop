#ifndef SPELLCHECKER_H
#define SPELLCHECKER_H

#include <QObject>
#include <QVariant>
#include <QQuickTextDocument>
#include <QSyntaxHighlighter>

#ifdef Q_OS_MACOS
class Hunspell;
#endif
class QTextCodec;

class SpellChecker : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString lang READ lang WRITE setLang NOTIFY langChanged)
    Q_PROPERTY(QString userDict READ userDict WRITE setUserDict NOTIFY userDictChanged)

public:
    explicit SpellChecker(QObject *parent = nullptr);
    ~SpellChecker();

    Q_INVOKABLE bool spell(const QString& word);
    Q_INVOKABLE QVariantList suggest(const QString &word);
    Q_INVOKABLE void ignoreWord(const QString &word);
    Q_INVOKABLE void addToUserWordlist(const QString &word);
    Q_INVOKABLE bool isInit() const;

    const QString& lang() const;
    void setLang(const QString& lang);

    const QString& userDict() const;
    void setUserDict(const QString& userDict);

signals:
    void langChanged();
    void userDictChanged();

private:
    void initHunspell();

private:
    QString m_lang;
    QString m_userDict;

    QQuickTextDocument *m_document;
#ifdef Q_OS_MACOS
    Hunspell *m_hunspell;
#endif
    QTextCodec *m_codec;
};

#endif // SPELLCHECKER_H
