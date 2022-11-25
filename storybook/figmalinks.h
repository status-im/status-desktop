#pragma once

#include <QObject>
#include <QMap>

class FigmaLinks : public QObject
{
    Q_OBJECT
public:
    explicit FigmaLinks(const QMap<QString, QStringList>& mapping,
                          QObject *parent = nullptr);
    const QMap<QString, QStringList>& getLinksMap() const;

private:
    QMap<QString, QStringList> m_linksMap;
};
