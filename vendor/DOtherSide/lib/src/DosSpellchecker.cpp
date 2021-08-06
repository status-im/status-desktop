#include "DosSpellchecker.h"

#include "hunspell.hxx"
#include <QTextCodec>
#include <QFile>
#include <QDebug>
#include <QLocale>

#include <QRegularExpression>
#include <QApplication>
#include <QDir>

#include <QInputMethod>

SpellChecker::SpellChecker(QObject *parent)
    : QSyntaxHighlighter(parent)
{
    auto language = QLocale::system().bcp47Name();

#ifdef Q_OS_MACOS
    QString dictFile = QApplication::applicationDirPath() + + "/dictionaries/" + language  + "/index.dic";
    QString affixFile = QApplication::applicationDirPath() + + "/dictionaries/" + language  + "/index.aff";
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

    QString userDict = "userDict_" + language + ".txt";

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
    auto language = QLocale::scriptToString(QLocale::system().script());

    QString userDict = "userDict_" + language + ".txt";
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

void SpellChecker::setText(const QString &text)
{
    if (m_text != text) {
        m_text = text;
        emit textChanged();
        makeDisplayText(m_text);
    }
}

const QString &SpellChecker::text() const
{
    return m_text;
}

const QString &SpellChecker::displayText() const
{
    return m_displayText;
}

QQuickTextDocument *SpellChecker::textDocument() const
{
    return m_document;
}

void SpellChecker::setTextDocument(QQuickTextDocument *document)
{
    if (m_document != document) {
        m_document = document;
        setDocument(m_document->textDocument());
        emit textDocumentChanged();
    }
}

void SpellChecker::highlightBlock(const QString &text)
{
    QTextCharFormat format;
    format.setFontUnderline(true);

    QRegularExpression expression("\\S+");
    QRegularExpressionMatchIterator i = expression.globalMatch(text);
    while(i.hasNext()) {
        QRegularExpressionMatch match = i.next();
        if (!spell(match.captured())) {
            setFormat(match.capturedStart(), match.capturedLength(), format);
        }
    }
}

void SpellChecker::makeDisplayText(const QString &text)
{
    auto words = text.split(" ");
    QString gPattern = "<u style=\"color: red;\">%1</u>";

    m_displayText = ""; // todo optimize delta
    for (const auto& word: qAsConst(words)) {
        if (!spell(word)) {
            m_displayText.append(" " + gPattern.arg(word));
        } else {
            m_displayText.append(" " + word);
        }
    }

    emit displayTextChanged();
}
