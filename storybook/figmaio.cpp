#include "figmaio.h"

#include <QDebug>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

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
