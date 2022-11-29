#pragma once

#include <QMap>

class FigmaIO
{
public:
    static QMap<QString, QStringList> read(const QString &file);
    static void write(const QString &file, const QMap<QString, QStringList> &map);
};
