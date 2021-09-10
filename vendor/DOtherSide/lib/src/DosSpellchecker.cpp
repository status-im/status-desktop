#include "../include/DOtherSide/DosSpellchecker.h"

#ifdef Q_OS_MACOS
   #include "hunspell/hunspell.hxx"
#endif

#include <QTextCodec>
#include <QFile>
#include <QDebug>
#include <QLocale>

#include <QRegularExpression>
#include <QApplication>
#include <QDir>

#include <QInputMethod>

SpellChecker::SpellChecker(QObject *parent)
    : QObject(parent)
#ifdef Q_OS_MACOS
    , m_hunspell(nullptr)
#endif
    , m_userDict("userDict_")
{

}

SpellChecker::~SpellChecker()
{
#ifdef Q_OS_MACOS
    delete m_hunspell;
#endif
}

bool SpellChecker::spell(const QString &word)
{
#ifdef Q_OS_MACOS
    return m_hunspell->spell(m_codec->fromUnicode(word).toStdString());
#else
    return true;
#endif
}

bool SpellChecker::isInit() const
{
#ifdef Q_OS_MACOS
    return !m_hunspell;
#else
    return true;
#endif
}

void SpellChecker::initHunspell()
{
#ifdef Q_OS_MACOS
    if (m_hunspell) {
        delete m_hunspell;
    }

    QString dictFile = QApplication::applicationDirPath() + "/dictionaries/" + m_lang  + "/index.dic";
    QString affixFile = QApplication::applicationDirPath() + "/dictionaries/" + m_lang  + "/index.aff";
    QByteArray dictFilePathBA = dictFile.toLocal8Bit();
    QByteArray affixFilePathBA = affixFile.toLocal8Bit();
    m_hunspell = new Hunspell(affixFilePathBA.constData(),
                             dictFilePathBA.constData());

    // detect encoding analyzing the SET option in the affix file
    auto encoding = QStringLiteral("ISO8859-15");
    QFile _affixFile(affixFile);
    if (_affixFile.open(QIODevice::ReadOnly)) {
      QTextStream stream(&_affixFile);
      QRegularExpression enc_detector(
            QStringLiteral("^\\s*SET\\s+([A-Z0-9\\-]+)\\s*"),
            QRegularExpression::CaseInsensitiveOption);
      QString sLine;
      QRegularExpressionMatch match;
      while (!stream.atEnd()) {
        sLine = stream.readLine();
        if (sLine.isEmpty()) { continue; }
        match = enc_detector.match(sLine);
        if (match.hasMatch()) {
          encoding = match.captured(1);
          qDebug() << "Encoding set to " + encoding;
          break;
        }
      }
      _affixFile.close();
    }
    m_codec = QTextCodec::codecForName(encoding.toLatin1().constData());

    QString userDict = m_userDict + m_lang + ".txt";

    if (!userDict.isEmpty()) {
      QFile userDictonaryFile(userDict);
      if (userDictonaryFile.open(QIODevice::ReadOnly)) {
        QTextStream stream(&userDictonaryFile);
        for (QString word = stream.readLine();
             !word.isEmpty();
             word = stream.readLine())
          ignoreWord(word);
        userDictonaryFile.close();
      } else {
        qWarning() << "User dictionary in " << userDict
                   << "could not be opened";
      }
    } else {
      qDebug() << "User dictionary not set.";
    }
#endif
}

QVariantList SpellChecker::suggest(const QString &word)
{
    int numSuggestions = 0;
    QVariantList suggestions;
#ifdef Q_OS_MACOS
    std::vector<std::string> wordlist;
    wordlist = m_hunspell->suggest(m_codec->fromUnicode(word).toStdString());

    numSuggestions = static_cast<int>(wordlist.size());
    if (numSuggestions > 0) {
        suggestions.reserve(numSuggestions);
        for (int i = 0; i < numSuggestions; i++) {
            suggestions << m_codec->toUnicode(
                QByteArray::fromStdString(wordlist[i]));
        }
    }
#endif

    return suggestions;
}

void SpellChecker::ignoreWord(const QString &word)
{
#ifdef Q_OS_MACOS
    m_hunspell->add(m_codec->fromUnicode(word).constData());
#endif
}

void SpellChecker::addToUserWordlist(const QString &word)
{
#ifdef Q_OS_MACOS
    QString userDict = m_userDict + m_lang + ".txt";
    if (!userDict.isEmpty()) {
        QFile userDictonaryFile(userDict);
        if (userDictonaryFile.open(QIODevice::Append)) {
            QTextStream stream(&userDictonaryFile);
            stream << word << "\n";
            userDictonaryFile.close();
        } else {
            qWarning() << "User dictionary in " << userDict
                       << "could not be opened for appending a new word";
        }
    } else {
        qDebug() << "User dictionary not set.";
    }
#endif
}

const QString& SpellChecker::lang() const
{
    return m_lang;
}

void SpellChecker::setLang(const QString& lang)
{
    if (m_lang != lang) {
        m_lang = lang;
        initHunspell();
        emit langChanged();
    }
}

const QString& SpellChecker::userDict() const
{
    return m_userDict;
}

void SpellChecker::setUserDict(const QString& userDict)
{
    if (m_userDict != userDict) {
        m_userDict = userDict;
        emit userDictChanged();
    }
}
