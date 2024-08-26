#include <QCoreApplication>

#include <QElapsedTimer>
#include <QFile>

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

auto getDoc(const QString &filename) -> QJsonDocument
{
  QFile dataFile(filename);
  if (!dataFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
    qWarning() << "Cannot open" << dataFile.fileName() << "file, quit...";
    return {};
  }

  QJsonParseError error;
  QJsonDocument dataDoc = QJsonDocument::fromJson(dataFile.readAll(), &error);
  if (error.error != QJsonParseError::NoError) {
    qWarning() << "Error" << error.error << "while parsing" << dataFile.fileName() << "file:" << error.errorString()
               << "; at offset" << error.offset;
    return {};
  }
  return dataDoc;
}

// https://github.com/milesj/emojibase/blob/master/packages/data/en/messages.raw.json
auto getGroups() -> QMap<int, QString>
{
  return {
      {0, QStringLiteral("smileys, people & body")},
      {1, QStringLiteral("smileys, people & body")},
      // 2 -> skip components
      {3, QStringLiteral("animals & nature")},
      {4, QStringLiteral("food & drink")},
      {5, QStringLiteral("travel & places")},
      {6, QStringLiteral("activities")},
      {7, QStringLiteral("objects")},
      {8, QStringLiteral("symbols")},
      {9, QStringLiteral("flags")},
  };
}

auto getShortnames() -> QMap<QString, QStringList>
{
  // https://github.com/milesj/emojibase/blob/master/packages/data/en/shortcodes/joypixels.raw.json
  const auto filename = QStringLiteral(":/resources/json/joypixels.raw.json");
  QJsonDocument dataDoc = getDoc(filename);
  if (dataDoc.isEmpty() || dataDoc.isNull() || !dataDoc.isObject()) {
    qWarning() << "Empty, null or invalid JSON in" << filename;
    return {};
  }

  constexpr auto wrapInColonsIfNotEmpty = [](const auto &string) {
    if (string.isEmpty())
      return string;
    return QStringLiteral(":%1:").arg(string);
  };

  QJsonObject shortnamesObj = dataDoc.object();
  QMap<QString, QStringList> result;

  for (auto it = shortnamesObj.constBegin(); it != shortnamesObj.constEnd(); it++) {
    const auto key = it.key();
    const auto value = it.value();
    QStringList shortnames;
    if (value.isString())
      shortnames.append(wrapInColonsIfNotEmpty(value.toString()));
    else if (value.isArray()) {
      const auto shortnamesArr = value.toArray();
      for (int i = 0; i < shortnamesArr.size(); i++)
        shortnames.append(wrapInColonsIfNotEmpty(shortnamesArr.at(i).toString()));
    }
    result.insert(key, shortnames);
  }

  return result;
}

auto transformEmoji(const QString& label, const QString& hexcode, const QString& emoji, int order, const QString& category, const QJsonArray& keywords,
                    const QJsonArray& aliases_ascii, const QString& shortname, const QJsonArray& aliases, bool hasSkins) -> QJsonObject {
  return {{"name", label},
          {"unicode", hexcode.toLower()},
          {"emoji_order", order},
          {"category", category},
          {"emoji", emoji},
          {"keywords", keywords},
          {"aliases_ascii", aliases_ascii},
          {"shortname", shortname},
          {"aliases", aliases},
          {"hasSkins", hasSkins}
  };
}

int main(int argc, char *argv[])
{
  QCoreApplication a(argc, argv);

  QElapsedTimer timer;
  timer.start();

  // https://github.com/milesj/emojibase/blob/master/packages/data/en/data.raw.json
  QJsonDocument dataDoc = getDoc(QStringLiteral(":/resources/json/data.raw.json"));

  if (dataDoc.isEmpty() || dataDoc.isNull() || !dataDoc.isArray()) {
    qWarning() << "Unexpected dataFile structure, quit...";
    return EXIT_FAILURE;
  }

  QJsonArray dataArray = dataDoc.array();
  const auto size = dataArray.size();

  qWarning() << "Initially found" << size << "emojis";

  // The mapping:
  // label (string) -> name
  // hexcode (string) -> unicode
  // order (int) -> emoji_order
  // group (int) -> category (string)
  // tags -> keywords (NEW)
  // emoji -> emoji (NEW)
  // shortname (array lookup) -> shortname + aliases (array)
  // emoticon (array or string!) -> aliases_ascii (array)

  const auto groupsMap = getGroups();
  const auto shortNamesMap = getShortnames();

  QJsonArray result;

  for (int i = 0; i < size; i++) {
    const auto value = dataArray.at(i).toObject();
    if (value.isEmpty()) {
      qWarning() << "Unexpected value type at index " << i << "; skipping";
      continue;
    }

    const auto hexcode = value.value(QStringLiteral("hexcode")).toString();
    if (!value.contains(QStringLiteral("group"))) {
      qWarning() << "Skipping modifier emoji:" << hexcode;
      continue;
    }

    const auto groupId = value.value(QStringLiteral("group")).toInt();
    if (groupId == 2) {
      qWarning() << "Skipping skin tone emoji:" << hexcode;
      continue;
    }

    const auto emoji = value.value(QStringLiteral("emoji")).toString();
    const auto label = value.value(QStringLiteral("label")).toString();
    const auto order = value.value(QStringLiteral("order")).toInt();
    const auto category = groupsMap.value(groupId);
    const auto keywords = value.value(QStringLiteral("tags")).toArray();

    auto shortnames = shortNamesMap.value(hexcode);
    const auto shortname = !shortnames.isEmpty() ? shortnames.takeFirst() : QString();
    const auto aliases = QJsonArray::fromStringList(shortnames);

    qDebug() << "Found emoji:" << emoji << QStringLiteral("(hex: '%1' label: '%2' groupId: %3 order: %4)").arg(hexcode).arg(label).arg(groupId).arg(order);

    QJsonArray aliases_ascii;
    const auto emoticon = value.value(QStringLiteral("emoticon"));
    if (emoticon.isString())
      aliases_ascii.append(emoticon.toString());
    else if (emoticon.isArray())
      aliases_ascii = emoticon.toArray();

    const auto skins = value.value(QStringLiteral("skins"));
    result.append(transformEmoji(label, hexcode, emoji, order, category, keywords, aliases_ascii, shortname, aliases, skins.isArray() && !skins.isNull()));

    if (skins.isArray()) {
      const auto skinsArr = skins.toArray();
      for (int j = 0; j < skinsArr.size(); j++) {
        const auto skinnedEmoji = skinsArr.at(j).toObject();
        const auto hexcode = skinnedEmoji.value(QStringLiteral("hexcode")).toString();
        const auto label = skinnedEmoji.value(QStringLiteral("label")).toString();
        const auto emoji = skinnedEmoji.value(QStringLiteral("emoji")).toString();
        const auto order = skinnedEmoji.value(QStringLiteral("order")).toInt();
        result.append(transformEmoji(label, hexcode, emoji, order, category, keywords, aliases_ascii, shortname, aliases, false));
      }
    }
  }

  QJsonDocument resultDoc(result);
  QFile resultFile(QByteArrayLiteral("/tmp/emojiList.json"));
  if (resultFile.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) {
    resultFile.write(resultDoc.toJson(QJsonDocument::Indented));
    qWarning() << "RESULT: exported" << result.size() << "emojis to" << resultFile.fileName();
  } else {
    qWarning() << "Cannot open" << resultFile.fileName() << "for writing the result, quit...";
    return EXIT_FAILURE;
  }

  qWarning() << "RUNTIME:" << timer.elapsed() << "ms";

  return EXIT_SUCCESS;
}
