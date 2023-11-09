#include "managetokensmodel.h"

#include <algorithm>

Q_LOGGING_CATEGORY(manageTokens, "status.models.manageTokens", QtInfoMsg)

ManageTokensModel::ManageTokensModel(QObject* parent)
    : QAbstractListModel(parent)
{
    connect(this, &QAbstractItemModel::rowsInserted, this, &ManageTokensModel::countChanged);
    connect(this, &QAbstractItemModel::rowsRemoved, this, &ManageTokensModel::countChanged);
    connect(this, &QAbstractItemModel::modelReset, this, &ManageTokensModel::countChanged);
    connect(this, &QAbstractItemModel::layoutChanged, this, &ManageTokensModel::countChanged);
}

void ManageTokensModel::moveItem(int fromRow, int toRow)
{
    qCDebug(manageTokens) << Q_FUNC_INFO << "from" << fromRow << "to" << toRow;

    if (toRow < 0 || toRow >= rowCount() || fromRow < 0 || fromRow >= rowCount())
        return;

    auto destRow = toRow;
    if (toRow > fromRow)
        destRow++;

    beginMoveRows({}, fromRow, fromRow, {}, destRow);
    m_data.move(fromRow, toRow);
    endMoveRows();
    setDirty(true);
}

void ManageTokensModel::addItem(const TokenData& item, bool append)
{
    const auto destRow = append ? rowCount() : 0;
    beginInsertRows({}, destRow, destRow);
    append ? m_data.append(item) : m_data.prepend(item);
    endInsertRows();
    setDirty(true);
}

std::optional<TokenData> ManageTokensModel::takeItem(int row)
{
    if (row < 0 || row >= rowCount())
        return {};

    beginRemoveRows({}, row, row);
    auto res = m_data.takeAt(row);
    endRemoveRows();
    setDirty(true);
    return res;
}

QList<TokenData> ManageTokensModel::takeAllItems(const QString& communityId)
{
    QList<TokenData> result;
    QList<int> indexesToRemove;

    for (int i = 0; i < m_data.count(); i++) {
        const auto &token = m_data.at(i);
        if (token.communityId == communityId) {
            result.append(token);
            indexesToRemove.append(i);
        }
    }

    QList<int>::reverse_iterator its;
    for(its = indexesToRemove.rbegin(); its != indexesToRemove.rend(); ++its) {
        const auto row = *its;
        beginRemoveRows({}, row, row);
        m_data.removeAt(row);
        endRemoveRows();
    }

    setDirty(true);
    return result;
}

void ManageTokensModel::clear()
{
    beginResetModel();
    m_data.clear();
    endResetModel();
    setDirty(false);
}

SerializedTokenData ManageTokensModel::save(bool isVisible)
{
    saveCustomSortOrder();
    const auto size = count();
    SerializedTokenData result;
    for (int i = 0; i < size; i++) {
        const auto& token = itemAt(i);
        const auto groupId = !token.communityId.isEmpty() ? token.communityId : token.collectionUid;
        result.insert(token.symbol, {i, isVisible, groupId});
    }
    setDirty(false);
    return result;
}

int ManageTokensModel::rowCount(const QModelIndex& parent) const
{
    return m_data.size();
}

QHash<int, QByteArray> ManageTokensModel::roleNames() const
{
    static const QHash<int, QByteArray> roles {
        {SymbolRole, kSymbolRoleName},
        {NameRole, kNameRoleName},
        {CommunityIdRole, kCommunityIdRoleName},
        {CommunityNameRole, kCommunityNameRoleName},
        {CommunityImageRole, kCommunityImageRoleName},
        {CollectionUidRole, kCollectionUidRoleName},
        {CollectionNameRole, kCollectionNameRoleName},
        {BalanceRole, kEnabledNetworkBalanceRoleName},
        {CurrencyBalanceRole, kEnabledNetworkCurrencyBalanceRoleName},
        {CustomSortOrderNoRole, kCustomSortOrderNoRoleName},
        {TokenImageRole, kTokenImageRoleName},
        {TokenBackgroundColorRole, kBackgroundColorRoleName},
    };

    return roles;
}

QVariant ManageTokensModel::data(const QModelIndex& index, int role) const
{
    if (!checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid | QAbstractItemModel::CheckIndexOption::ParentIsInvalid))
        return {};

    const auto& token = m_data.at(index.row());

    switch(static_cast<TokenDataRoles>(role))
    {
    case SymbolRole: return token.symbol;
    case NameRole: return token.name;
    case CommunityIdRole: return token.communityId;
    case CommunityNameRole: return token.communityName;
    case CommunityImageRole: return token.communityImage;
    case CollectionUidRole: return token.collectionUid;
    case CollectionNameRole: return token.collectionName;
    case BalanceRole: return token.balance;
    case CurrencyBalanceRole: return token.currencyBalance;
    case CustomSortOrderNoRole: return token.customSortOrderNo;
    case TokenImageRole: return token.image;
    case TokenBackgroundColorRole: return token.backgroundColor;
    }

    return {};
}

bool ManageTokensModel::dirty() const
{
    return m_dirty;
}

void ManageTokensModel::setDirty(bool flag)
{
    if (m_dirty == flag) return;
    m_dirty = flag;
    emit dirtyChanged();
}

void ManageTokensModel::saveCustomSortOrder()
{
    const auto count = rowCount();
    for (auto i = 0; i < count; i++) {
        TokenData newToken{m_data.at(i)};
        if (newToken.communityId.isEmpty()) {
            newToken.customSortOrderNo = i;
        } else {
            const auto communityIdx = m_communityIds.indexOf(newToken.communityId) + 1;
            newToken.customSortOrderNo = i + (communityIdx * 100'000);
        }
        m_data[i] = newToken;
    }
    emit dataChanged(index(0, 0), index(count - 1, 0), {TokenDataRoles::CustomSortOrderNoRole});
}

void ManageTokensModel::applySort()
{
    emit layoutAboutToBeChanged({}, QAbstractItemModel::VerticalSortHint);

    // clazy:exclude=clazy-detaching-member
    std::stable_sort(m_data.begin(), m_data.end(), [this](const TokenData& lhs, const TokenData& rhs) {
        return lhs.customSortOrderNo < rhs.customSortOrderNo;
    });

    emit layoutChanged({}, QAbstractItemModel::VerticalSortHint);
}

bool ManageTokensModel::hasCommunityIdToken(const QString& communityId) const
{
    return std::any_of(m_data.cbegin(), m_data.constEnd(), [communityId](const auto& token) {
        return token.communityId == communityId;
    });
}
