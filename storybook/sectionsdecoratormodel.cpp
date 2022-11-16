#include "sectionsdecoratormodel.h"

#include <QScopeGuard>

SectionsDecoratorModel::SectionsDecoratorModel(QObject *parent)
    : QAbstractListModel{parent}
{
}

void SectionsDecoratorModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    if (m_sourceModel != nullptr) {
        qWarning("Changing source model is not supported!");
        return;
    }

    m_sourceModel = sourceModel;

    initialize();

    connect(sourceModel, &QAbstractItemModel::modelReset, this, &SectionsDecoratorModel::initialize);
    connect(sourceModel, &QAbstractItemModel::rowsInserted, this, &SectionsDecoratorModel::initialize);
    connect(sourceModel, &QAbstractItemModel::rowsRemoved, this, &SectionsDecoratorModel::initialize);
    connect(sourceModel, &QAbstractItemModel::rowsMoved, this, &SectionsDecoratorModel::initialize);

    emit sourceModelChanged();
}

QAbstractItemModel* SectionsDecoratorModel::sourceModel() const
{
    return m_sourceModel;
}

int SectionsDecoratorModel::rowCount(const QModelIndex &parent) const
{
    return m_rowsMetadata.size();
}

QVariant SectionsDecoratorModel::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid))
        return {};

    const int row = index.row();
    const RowMetadata &rowMetadata = m_rowsMetadata[row];

    if (role == IsFoldedRole) {
        return rowMetadata.folded;
    } else if (role == SubitemsCountRole) {
        return rowMetadata.count;
    } else if (role == IsSectionRole) {
        return rowMetadata.isSection;
    } else if (role == m_sectionRole && rowMetadata.isSection) {
        return rowMetadata.sectionName;
    }

    if (!rowMetadata.isSection) {
        return sourceModel()->data(
                    sourceModel()->index(row - rowMetadata.offset, 0), role);
    } else {
        return QVariant();
    }
}

QHash<int, QByteArray> SectionsDecoratorModel::roleNames() const
{
    auto roles = m_sourceModel ? m_sourceModel->roleNames() : QHash<int, QByteArray>{};
    roles.insert(IsSectionRole, QByteArrayLiteral("isSection"));
    roles.insert(IsFoldedRole, QByteArrayLiteral("isFolded"));
    roles.insert(SubitemsCountRole, QByteArrayLiteral("subitemsCount"));

    return roles;
}

void SectionsDecoratorModel::flipFolding(int index)
{
    auto &row = m_rowsMetadata[index];
    row.folded = !row.folded;

    const auto idx = this->index(index, 0, {});

    if (row.folded) {
        beginRemoveRows(QModelIndex(), index + 1, index + row.count);
        m_rowsMetadata.erase(m_rowsMetadata.begin() + index + 1,
                             m_rowsMetadata.begin() + index + 1 + row.count);
        calculateOffsets();
        endRemoveRows();
    } else {
        beginInsertRows(QModelIndex(), index + 1, index + row.count);
        m_rowsMetadata.insert(m_rowsMetadata.begin() + index + 1, row.count,
                              RowMetadata{false});
        calculateOffsets();
        endInsertRows();
    }

    emit dataChanged(idx, idx, { IsFoldedRole });
}

void SectionsDecoratorModel::calculateOffsets()
{
    std::for_each(m_rowsMetadata.begin(), m_rowsMetadata.end(),
                  [offset = 0](RowMetadata &row) mutable {
        if (row.isSection) {
            ++offset;

            if (row.folded)
                offset -= row.count;
        } else {
            row.offset = offset;
        }
    });
}

std::optional<int> SectionsDecoratorModel::findSectionRole() const
{
    const auto roleNames = m_sourceModel->roleNames();
    auto i = roleNames.constBegin();

    while (i != roleNames.constEnd()) {
        if (i.value() == QStringLiteral("section"))
            return i.key();
        ++i;
    }

    return std::nullopt;
}

void SectionsDecoratorModel::initialize()
{
    beginResetModel();
    auto endResetModelGuard = qScopeGuard([this] { endResetModel(); });

    m_rowsMetadata.clear();

    const auto sectionRoleOpt = findSectionRole();

    if (!sectionRoleOpt) {
        qWarning("Section role not found!");
        return;
    }

    m_sectionRole = *sectionRoleOpt;
    QString prevSection;
    int prevSectionIndex = 0;

    for (int i = 0; i < m_sourceModel->rowCount(); i++) {
        const QVariant sectionVariant = m_sourceModel->data(
                    m_sourceModel->index(i, 0), m_sectionRole);
        const QString section = sectionVariant.toString();

        if (prevSection != section) {
            m_rowsMetadata.push_back({true, section});
            prevSection = section;
            prevSectionIndex = m_rowsMetadata.size() - 1;
        }

        m_rowsMetadata.push_back({false});
        m_rowsMetadata[prevSectionIndex].count++;
    }

    calculateOffsets();
}
