#include "sectionsdecoratormodel.h"

#include "modelutils.h"

#include <QScopeGuard>

SectionsDecoratorModel::SectionsDecoratorModel(QObject *parent)
    : QAbstractListModel{parent}
{
}

void SectionsDecoratorModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    if (m_sourceModel == nullptr && sourceModel == nullptr)
        return;

    if (m_sourceModel != nullptr) {
        qWarning("Changing source model is not supported!");
        return;
    }

    m_sourceModel = sourceModel;

    initialize();

    connect(sourceModel, &QAbstractItemModel::modelReset, this,
            &SectionsDecoratorModel::initialize);
    connect(sourceModel, &QAbstractItemModel::rowsMoved, this,
            &SectionsDecoratorModel::initialize);

    connect(sourceModel, &QAbstractItemModel::rowsInserted, this,
            &SectionsDecoratorModel::onInserted);
    connect(sourceModel, &QAbstractItemModel::rowsRemoved, this,
            &SectionsDecoratorModel::onRemoved);

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
    } else if (role == SectionRole && rowMetadata.isSection) {
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
    roles.insert(SectionRole, QByteArrayLiteral("section"));
    roles.insert(IsSectionRole, QByteArrayLiteral("isSection"));
    roles.insert(IsFoldedRole, QByteArrayLiteral("isFolded"));
    roles.insert(SubitemsCountRole, QByteArrayLiteral("subitemsCount"));

    return roles;
}

void SectionsDecoratorModel::flipFolding(int index)
{
    if (index < 0 || index >= m_rowsMetadata.size())
        return;

    auto &row = m_rowsMetadata[index];

    if (!row.isSection)
        return;

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

void SectionsDecoratorModel::initialize()
{
    beginResetModel();
    auto endResetModelGuard = qScopeGuard([this] { endResetModel(); });

    m_rowsMetadata.clear();

    const auto categoryRoleOpt = ModelUtils::findRole(
                QByteArrayLiteral("category"), m_sourceModel);

    if (!categoryRoleOpt) {
        qWarning("Category role not found!");
        return;
    }

    m_sectionRole = *categoryRoleOpt;
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

void SectionsDecoratorModel::onInserted(const QModelIndex &parent,
                                        int first, int last)
{
    if (first != last) {
        initialize();
        return;
    }

    const QVariant sectionVariant = m_sourceModel->data(
                m_sourceModel->index(first, 0), m_sectionRole);
    const QString section = sectionVariant.toString();

    auto insertNewSection = [this, &section](int index) {
        beginInsertRows(QModelIndex{}, index, index + 1);

        m_rowsMetadata.insert(m_rowsMetadata.begin() + index, RowMetadata{});
        m_rowsMetadata.insert(m_rowsMetadata.begin() + index,
                              RowMetadata{ true, section, false, 0, 1});
        calculateOffsets();
        endInsertRows();
    };

    int itemsCounter = 0;
    int sectionIndex = 0;

    while (sectionIndex < m_rowsMetadata.size()) {
        auto& sectionMetadata = m_rowsMetadata.at(sectionIndex);

        if (sectionMetadata.sectionName == section) {
            sectionMetadata.count++;

            emit dataChanged(index(sectionIndex, 0), index(sectionIndex, 0),
                             { Roles::SubitemsCountRole });

            if (sectionMetadata.folded) {
                // update folded section only
                calculateOffsets();

            } else {
                // insert item into unfolded section
                auto insertIndex = sectionIndex + (first - itemsCounter) + 1;

                beginInsertRows(QModelIndex{}, insertIndex, insertIndex);
                m_rowsMetadata.insert(m_rowsMetadata.begin() + insertIndex, RowMetadata{});
                calculateOffsets();
                endInsertRows();
            }

            break;
        }

        if (sectionMetadata.sectionName != section && itemsCounter == first) {
            insertNewSection(sectionIndex);
            break;
        }

        itemsCounter += sectionMetadata.count;
        sectionIndex += 1 + (sectionMetadata.folded ? 0 : sectionMetadata.count);
    }

    if (sectionIndex == m_rowsMetadata.size())
        insertNewSection(sectionIndex);
}

void SectionsDecoratorModel::onRemoved(const QModelIndex &parent,
                                       int first, int last)
{
    if (first != last) {
        initialize();
        return;
    }

    int itemsCounter = 0;
    int sectionIndex = 0;

    while (sectionIndex < m_rowsMetadata.size()) {
        auto& sectionMetadata = m_rowsMetadata.at(sectionIndex);

        if (first < itemsCounter + sectionMetadata.count) {

            if (sectionMetadata.folded) {
                if (sectionMetadata.count == 1) {
                    auto removeIndex = sectionIndex + (first - itemsCounter);
                    beginRemoveRows(QModelIndex{}, removeIndex, removeIndex);
                    m_rowsMetadata.erase(m_rowsMetadata.begin() + removeIndex,
                                         m_rowsMetadata.begin() + removeIndex + 1);
                    calculateOffsets();
                    endRemoveRows();
                } else {
                    sectionMetadata.count--;
                    calculateOffsets();

                    emit dataChanged(index(sectionIndex, 0), index(sectionIndex, 0),
                                     { Roles::SubitemsCountRole });
                }
            } else {
                if (sectionMetadata.count == 1) {
                    auto removeIndex = sectionIndex + (first - itemsCounter);
                    beginRemoveRows(QModelIndex{}, removeIndex, removeIndex + 1);
                    m_rowsMetadata.erase(m_rowsMetadata.begin() + removeIndex,
                                         m_rowsMetadata.begin() + removeIndex + 2);
                } else {
                    sectionMetadata.count--;
                    emit dataChanged(index(sectionIndex, 0), index(sectionIndex, 0),
                                     { Roles::SubitemsCountRole });

                    auto removeIndex = sectionIndex + (first - itemsCounter) + 1;

                    beginRemoveRows(QModelIndex{}, removeIndex, removeIndex);
                    m_rowsMetadata.erase(m_rowsMetadata.begin() + removeIndex);
                }

                calculateOffsets();
                endRemoveRows();
            }

            break;
        }

        itemsCounter += sectionMetadata.count;
        sectionIndex += 1 + (sectionMetadata.folded ? 0 : sectionMetadata.count);
    }
}
