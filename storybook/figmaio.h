#pragma once

#include <QMap>

class FigmaIO
{
public:
    static QMap<QString, QStringList> read(const QString &file);
};
