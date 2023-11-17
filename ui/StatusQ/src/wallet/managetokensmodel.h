#pragma once

#include <QAbstractListModel>
#include <QColor>
#include <QLoggingCategory>

#include <optional>
#include <tuple>

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
const auto kTokenImageRoleName = QByteArrayLiteral("imageUrl");
const auto kBackgroundColorRoleName = QByteArrayLiteral("backgroundColor");
// TODO add communityPrivilegesLevel for collectibles
} // namespace

struct TokenData {
    QString symbol, name, communityId, communityName, communityImage, collectionUid, collectionName, image;
    QColor backgroundColor{Qt::transparent};
    QVariant balance, currencyBalance;
    int customSortOrderNo{INT_MAX};
};

// symbol -> {sortOrder, visible, groupId}
using SerializedTokenData = QHash<QString, std::tuple<int, bool, QString>>;

class ManageTokensModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)
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
    };
    Q_ENUM(TokenDataRoles)

    explicit ManageTokensModel(QObject* parent = nullptr);

    Q_INVOKABLE void moveItem(int fromRow, int toRow);

    void addItem(const TokenData& item, bool append = true);
    std::optional<TokenData> takeItem(int row);
    QList<TokenData> takeAllItems(const QString& communityId);
    void clear();

    SerializedTokenData save(bool isVisible = true);

    bool dirty() const;
    void setDirty(bool flag);

    void saveCustomSortOrder();
    void applySort();

    int count() const { return rowCount(); }
    const TokenData& itemAt(int row) const { return m_data.at(row); }

    void setCommunityIds(const QStringList& ids) { m_communityIds = ids; };
    bool hasCommunityIdToken(const QString& communityId) const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;

signals:
    void countChanged();
    void dirtyChanged();

private:
    QStringList m_communityIds;

    bool m_dirty{false};

    QList<TokenData> m_data;
};
