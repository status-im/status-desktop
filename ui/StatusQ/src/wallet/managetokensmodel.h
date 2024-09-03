#pragma once

#include "tokendata.h"

#include <QAbstractListModel>
#include <QColor>
#include <QLoggingCategory>

#include <optional>

Q_DECLARE_LOGGING_CATEGORY(manageTokens)

namespace
{
const auto kSymbolRoleName = QByteArrayLiteral("symbol");
const auto kNameRoleName = QByteArrayLiteral("name");
const auto kCommunityIdRoleName = QByteArrayLiteral("communityId");
const auto kCommunityNameRoleName = QByteArrayLiteral("communityName");
const auto kCommunityImageRoleName = QByteArrayLiteral("communityImage");
const auto kCollectionUidRoleName = QByteArrayLiteral("collectionUid");
const auto kCollectionNameRoleName = QByteArrayLiteral("collectionName");
const auto kEnabledNetworkBalanceRoleName = QByteArrayLiteral("enabledNetworkBalance"); // TODO add an extra (separate role) for group->childCount
const auto kEnabledNetworkCurrencyBalanceRoleName = QByteArrayLiteral("enabledNetworkCurrencyBalance");
const auto kCustomSortOrderNoRoleName = QByteArrayLiteral("customSortOrderNo");
const auto kTokenImageUrlRoleName = QByteArrayLiteral("imageUrl");
const auto kTokenImageRoleName = QByteArrayLiteral("image");
const auto kCollectibleMediaUrlRoleName = QByteArrayLiteral("mediaUrl");
const auto kBackgroundColorRoleName = QByteArrayLiteral("backgroundColor");
const auto kBalancesRoleName = QByteArrayLiteral("balances");
const auto kDecimalsRoleName = QByteArrayLiteral("decimals");
const auto kMarketDetailsRoleName = QByteArrayLiteral("marketDetails");
const auto kIsSelfCollectionRoleName = QByteArrayLiteral("isSelfCollection");
// TODO add communityPrivilegesLevel for collectibles
} // namespace

class ManageTokensModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged FINAL)
    Q_PROPERTY(bool dirty READ dirty NOTIFY dirtyChanged FINAL)

public:
    enum TokenDataRoles {
        SymbolRole = Qt::UserRole + 1,
        NameRole,
        CommunityIdRole,
        CommunityNameRole,
        CommunityImageRole,
        CollectionUidRole,
        CollectionNameRole,
        BalanceRole,
        CurrencyBalanceRole,
        CustomSortOrderNoRole,
        TokenImageRole,
        TokenBackgroundColorRole,
        TokenBalancesRole,
        TokenDecimalsRole,
        TokenMarketDetailsRole,
        IsSelfCollectionRole,
    };
    Q_ENUM(TokenDataRoles)

    explicit ManageTokensModel(QObject* parent = nullptr);

    Q_INVOKABLE void moveItem(int fromRow, int toRow);

    void addItem(const TokenData& item, bool append = true);
    std::optional<TokenData> takeItem(const QString& symbol);
    QList<TokenData> takeAllItems(const QString& groupId);
    void clear();

    SerializedTokenData save(bool isVisible = true, bool itemsAreGroups = false);

    bool dirty() const;
    void setDirty(bool flag);

    void saveCustomSortOrder();
    void applySort();
    void applySortByTokensAmount();

    const TokenData& itemAt(int row) const { return m_data.at(row); }
    TokenData& itemAt(int row) { return m_data[row]; }

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;

signals:
    void countChanged();
    void dirtyChanged();

private:
    bool m_dirty{false};

    QList<TokenData> m_data;
};
