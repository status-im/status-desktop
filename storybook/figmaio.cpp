#include "figmaio.h"

#include <QDebug>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSaveFile>

QMap<QString, QStringList> FigmaIO::read(const QString &file)
{
    QFile f(file);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "FigmaIO::read - failed to open file:" << file;
        return {};
    }

    QJsonParseError error;
    auto jsonDoc = QJsonDocument::fromJson(f.readAll(), &error);

    if (error.error != QJsonParseError::NoError) {
        qWarning() << "FigmaIO::read - error parsing json file:" << file
                   << "->" << error.errorString();
        return {};
    }

    QMap<QString, QStringList> mapping;

    if (jsonDoc.isObject()) {
        auto rootObject = jsonDoc.object();

        auto i = rootObject.constBegin();
        while (i != rootObject.constEnd()) {
            QJsonValue val = i.value();
            QJsonArray links = val.toArray();

            QStringList linksList;
            linksList.reserve(links.size());

            for (const QJsonValue &link : qAsConst(links))
                if (link.isString())
                    linksList << link.toString();

            mapping.insert(i.key(), linksList);
            ++i;
        }
    }

    return mapping;
}

void FigmaIO::write(const QString &file, const QMap<QString, QStringList> &map)
{
    QJsonObject rootObject;

    std::for_each(map.constKeyValueBegin(), map.constKeyValueEnd(),
                  [&rootObject](auto entry) {
        const auto& [key, links] = entry;
        rootObject.insert(key, QJsonArray::fromStringList(links));
    });

    QSaveFile saveFile(file);
    if (!saveFile.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qWarning() << "FigmaIO::write - failed to open file:" << file;
        return;
    }

    QJsonDocument doc(rootObject);
    saveFile.write(doc.toJson());

    bool commitResult = saveFile.commit();

    if (!commitResult)
        qWarning() << "FigmaIO::write - failed to write to file:" << file;
}
