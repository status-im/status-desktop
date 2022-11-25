#include "figmadecoratormodel.h"

#include "figmalinks.h"
#include "figmalinksmodel.h"
#include "modelutils.h"

FigmaDecoratorModel::FigmaDecoratorModel(QObject *parent)
    : QIdentityProxyModel{parent}
{
}

QHash<int, QByteArray> FigmaDecoratorModel::roleNames() const
{
    auto roles = QIdentityProxyModel::roleNames();
    roles.insert(FigmaRole, QByteArrayLiteral("figma"));

    return roles;
}

QVariant FigmaDecoratorModel::data(const QModelIndex &proxyIndex, int role) const
{
    if (!checkIndex(proxyIndex, CheckIndexOption::IndexIsValid))
        return {};

    if (role == FigmaRole) {
        static FigmaLinksModel empty({});

        if (!m_titleRole)
            return QVariant::fromValue(&empty);

        const auto title = data(proxyIndex, m_titleRole.value()).toString();
        auto it = m_submodels.find(title);

        if (it == m_submodels.end()) {
            QStringList links;

            if (m_figmaLinks)
                links = m_figmaLinks->getLinksMap().value(title, {});

            auto linksModel = new FigmaLinksModel(
                        links, const_cast<FigmaDecoratorModel*>(this));
            it = m_submodels.insert(title, linksModel);
        }

        return QVariant::fromValue(it.value());
    }

    return QIdentityProxyModel::data(proxyIndex, role);
}

FigmaLinks* FigmaDecoratorModel::getFigmaLinks() const
{
    return m_figmaLinks;
}

void FigmaDecoratorModel::setFigmaLinks(FigmaLinks *figmaLinks)
{
    if (figmaLinks == m_figmaLinks)
        return;

    m_figmaLinks = figmaLinks;
    const auto& linksMap = m_figmaLinks
            ? m_figmaLinks->getLinksMap()
            : QMap<QString, QStringList>{};

    auto linksIt = linksMap.constBegin();
    while (linksIt != linksMap.constEnd()) {
        if (m_submodels.contains(linksIt.key()))
            m_submodels.value(linksIt.key())->setContent(linksIt.value());
        ++linksIt;
    }

    auto submodelsIt = m_submodels.constBegin();
    while (submodelsIt != m_submodels.constEnd()) {
        if (!linksMap.contains(submodelsIt.key()))
            submodelsIt.value()->setContent({});
        ++submodelsIt;
    }

    emit figmaLinksChanged();
}

void FigmaDecoratorModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    qDeleteAll(m_submodels);
    m_submodels.clear();

    m_titleRole = ModelUtils::findRole(QByteArrayLiteral("title"), sourceModel);

    if(!m_titleRole)
        qWarning("The source model is missing title role!");

    QIdentityProxyModel::setSourceModel(sourceModel);
}
