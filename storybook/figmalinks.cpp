#include "figmalinks.h"

FigmaLinks::FigmaLinks(const QMap<QString, QStringList>& linksMap, QObject *parent)
    : m_linksMap{linksMap}, QObject{parent}
{
}

const QMap<QString, QStringList>& FigmaLinks::getLinksMap() const
{
    return m_linksMap;
}
