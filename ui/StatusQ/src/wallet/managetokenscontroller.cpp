#include "managetokenscontroller.h"

#include <tuple>

#include <QElapsedTimer>
#include <QMutableHashIterator>

ManageTokensController::ManageTokensController(QObject* parent)
    : QObject(parent)
    , m_regularTokensModel(new ManageTokensModel(this))
    , m_collectionGroupsModel(new ManageTokensModel(this))
    , m_communityTokensModel(new ManageTokensModel(this))
    , m_communityTokenGroupsModel(new ManageTokensModel(this))
    , m_hiddenTokensModel(new ManageTokensModel(this))
    , m_hiddenCommunityTokenGroupsModel(new ManageTokensModel(this))
    , m_hiddenCollectionGroupsModel(new ManageTokensModel(this))
{
    for (auto model : m_allModels) {
        connect(model, &ManageTokensModel::dirtyChanged, this, &ManageTokensController::dirtyChanged);
    }

    connect(this, &ManageTokensController::sourceModelChanged, this, [this]() {
        if (!m_sourceModel) {
            m_modelConnectionsInitialized = false;
            return;
        }
        if (m_modelConnectionsInitialized)
            return;
        connect(m_sourceModel, &QAbstractItemModel::rowsInserted, this, [this](const QModelIndex &parent, int first, int last) {
#ifdef QT_DEBUG
            QElapsedTimer t;
            t.start();
            qCDebug(manageTokens) << "!!! ADDING" << last-first+1 << "NEW TOKENS";
#endif
            for (int i = first; i <= last; i++)
                addItem(i);

            rebuildCommunityTokenGroupsModel();
            rebuildHiddenCommunityTokenGroupsModel();
            rebuildCollectionGroupsModel();
            rebuildHiddenCollectionGroupsModel();

            for (auto model: m_allModels) {
                model->applySort();
                model->saveCustomSortOrder();
            }
#ifdef QT_DEBUG
            qCDebug(manageTokens) << "!!! ADDING NEW SOURCE DATA TOOK" << t.nsecsElapsed()/1'000'000.f << "ms";
#endif
        });
        connect(m_sourceModel, &QAbstractItemModel::rowsRemoved, this, &ManageTokensController::parseSourceModel);
        connect(m_sourceModel, &QAbstractItemModel::dataChanged, this, &ManageTokensController::parseSourceModel); // NB at this point we don't know in which submodel the item is
        m_modelConnectionsInitialized = true;
    });
}

void ManageTokensController::showHideRegularToken(const QString& symbol, bool flag)
{
    if (flag) { // show
        auto hiddenItem = m_hiddenTokensModel->takeItem(symbol);
        if (hiddenItem) {
            m_regularTokensModel->addItem(*hiddenItem);
            emit tokenShown(hiddenItem->symbol, hiddenItem->name);
        }
    } else { // hide
        auto shownItem = m_regularTokensModel->takeItem(symbol);
        if (shownItem) {
            m_hiddenTokensModel->addItem(*shownItem, false /*prepend*/);
            emit tokenHidden(shownItem->symbol, shownItem->name);
        }
    }
    saveSettings();
}

void ManageTokensController::showHideCommunityToken(const QString& symbol, bool flag)
{
    if (flag) { // show
        auto hiddenItem = m_hiddenTokensModel->takeItem(symbol);
        if (hiddenItem) {
            m_communityTokensModel->addItem(*hiddenItem);
            emit tokenShown(hiddenItem->symbol, hiddenItem->name);
        }
    } else { // hide
        auto shownItem = m_communityTokensModel->takeItem(symbol);
        if (shownItem) {
            m_hiddenTokensModel->addItem(*shownItem, false /*prepend*/);
            emit tokenHidden(shownItem->symbol, shownItem->name);
        }
    }
    m_communityTokensModel->saveCustomSortOrder();
    rebuildCommunityTokenGroupsModel();
    rebuildHiddenCommunityTokenGroupsModel();
    saveSettings();
}

void ManageTokensController::showHideGroup(const QString& groupId, bool flag)
{
    if (flag) { // show
        const auto tokens = m_hiddenTokensModel->takeAllItems(groupId);
        if (!tokens.isEmpty()) {
            for (const auto& token: tokens) {
                m_communityTokensModel->addItem(token);
            }
            emit communityTokenGroupShown(tokens.constFirst().communityName);
        }
        if (m_hiddenCommunityGroups.remove(groupId)) {
            emit hiddenCommunityGroupsChanged();
        }
    } else { // hide
        const auto tokens = m_communityTokensModel->takeAllItems(groupId);
        if (!tokens.isEmpty()) {
            for (const auto& token: tokens) {
                m_hiddenTokensModel->addItem(token, false /*prepend*/);
            }
            emit communityTokenGroupHidden(tokens.constFirst().communityName);
        }
        if (!m_hiddenCommunityGroups.contains(groupId)) {
            m_hiddenCommunityGroups.insert(groupId);
            emit hiddenCommunityGroupsChanged();
        }
    }
    rebuildCommunityTokenGroupsModel();
    m_communityTokenGroupsModel->applySort();
    rebuildHiddenCommunityTokenGroupsModel();
    saveSettings();
}

void ManageTokensController::showHideCollectionGroup(const QString& groupId, bool flag)
{
    if (flag) { // show
        const auto tokens = m_hiddenTokensModel->takeAllItems(groupId);
        if (!tokens.isEmpty()) {
            for (const auto& token: tokens) {
                m_regularTokensModel->addItem(token);
            }
            emit collectionTokenGroupShown(tokens.constFirst().collectionName);
        }
        if (m_hiddenCollectionGroups.remove(groupId)) {
            emit hiddenCollectionGroupsChanged();
        }
    } else { // hide
        const auto tokens = m_regularTokensModel->takeAllItems(groupId);
        if (!tokens.isEmpty()) {
            for (const auto& token: tokens) {
                m_hiddenTokensModel->addItem(token, false /*prepend*/);
            }
            emit collectionTokenGroupHidden(tokens.constFirst().collectionName);
        }
        if (!m_hiddenCollectionGroups.contains(groupId)) {
            m_hiddenCollectionGroups.insert(groupId);
            emit hiddenCollectionGroupsChanged();
        }
    }
    rebuildCollectionGroupsModel();
    m_collectionGroupsModel->applySort();
    rebuildHiddenCollectionGroupsModel();
    saveSettings();
}

void ManageTokensController::saveSettings()
{
    Q_ASSERT(!m_settingsKey.isEmpty());

    setSettingsDirty(true);

    // gather the data to save
    SerializedTokenData result;
    const auto resultCount = m_regularTokensModel->rowCount() + m_communityTokensModel->rowCount() + m_hiddenTokensModel->rowCount() +
                             (m_arrangeByCommunity ? m_communityTokenGroupsModel->rowCount() : 0) +
                             (m_arrangeByCollection ? m_collectionGroupsModel->rowCount() : 0);
    result.reserve(resultCount);

    for(auto model : {m_regularTokensModel, m_communityTokensModel})
        result.insert(model->save());
    if (m_arrangeByCommunity)
        result.insert(m_communityTokenGroupsModel->save());
    if (m_arrangeByCollection)
        result.insert(m_collectionGroupsModel->save());
    result.insert(m_hiddenTokensModel->save(false));

    // save to QSettings
    m_settings.beginGroup(settingsGroupName());

    // arrange by
    m_settings.setValue(QStringLiteral("ArrangeByCommunity"), m_arrangeByCommunity);
    m_settings.setValue(QStringLiteral("ArrangeByCollection"), m_arrangeByCollection);

    // data
    m_settings.beginWriteArray(m_settingsKey);
    SerializedTokenData::const_key_value_iterator it = result.constKeyValueBegin();
    for (auto i = 0; it != result.constKeyValueEnd() && i < result.size(); it++, i++) {
        m_settings.setArrayIndex(i);
        const auto& [pos, visible, groupId, isCommunityGroup, isCollectionGroup] = it->second;
        m_settings.setValue(QStringLiteral("symbol"), it->first);
        m_settings.setValue(QStringLiteral("pos"), pos);
        m_settings.setValue(QStringLiteral("visible"), visible);
        m_settings.setValue(QStringLiteral("groupId"), groupId);
        m_settings.setValue(QStringLiteral("isCommunityGroup"), isCommunityGroup);
        m_settings.setValue(QStringLiteral("isCollectionGroup"), isCollectionGroup);
    }
    m_settings.endArray();

    // hidden groups
    m_settings.setValue(QStringLiteral("HiddenCommunityGroups"), hiddenCommunityGroups());
    m_settings.setValue(QStringLiteral("HiddenCollectionGroups"), hiddenCollectionGroups());

    m_settings.endGroup();
    m_settings.sync();

    // unset dirty
    for (auto model: m_allModels)
        model->setDirty(false);

    loadSettingsData(true); // reload positions and visibility

    incRevision();

    setSettingsDirty(false);
}

void ManageTokensController::clearSettings()
{
    Q_ASSERT(!m_settingsKey.isEmpty());

    // clear the relevant QSettings group
    m_settings.beginGroup(settingsGroupName());
    m_settings.remove(QString());
    m_settings.endGroup();
    m_settings.sync();

    emit settingsDirtyChanged(false);
}

void ManageTokensController::loadSettingsData(bool withGroup)
{
    SerializedTokenData result;

    if (withGroup)
        m_settings.beginGroup(settingsGroupName());

    const auto size = m_settings.beginReadArray(m_settingsKey);
    for (auto i = 0; i < size; i++) {
        m_settings.setArrayIndex(i);
        const auto symbol = m_settings.value(QStringLiteral("symbol")).toString();
        if (symbol.isEmpty()) {
            qCDebug(manageTokens) << Q_FUNC_INFO << "Missing symbol while reading tokens settings";
            continue;
        }
        const auto pos = m_settings.value(QStringLiteral("pos"), INT_MAX).toInt();
        const auto visible = m_settings.value(QStringLiteral("visible"), true).toBool();
        const auto groupId = m_settings.value(QStringLiteral("groupId")).toString();
        const auto isCommunityGroup = m_settings.value(QStringLiteral("isCommunityGroup"), false).toBool();
        const auto isCollectionGroup = m_settings.value(QStringLiteral("isCollectionGroup"), false).toBool();
        result.insert(symbol, {pos, visible, groupId, isCommunityGroup, isCollectionGroup});
    }
    m_settings.endArray();

    if (withGroup)
        m_settings.endGroup();

    if (result != m_settingsData)
        m_settingsData = result;
}

void ManageTokensController::loadSettings()
{
    Q_ASSERT(!m_settingsKey.isEmpty());

    setSettingsDirty(true);
    m_settingsData.clear();

    // load from QSettings
    m_settings.beginGroup(settingsGroupName());

    loadSettingsData();

    // hidden groups
    const auto groups = m_settings.value(QStringLiteral("HiddenCommunityGroups")).toStringList();
    if (!groups.isEmpty()) {
        m_hiddenCommunityGroups = {groups.constBegin(), groups.constEnd()};
        emit hiddenCommunityGroupsChanged();
    }
    const auto collections = m_settings.value(QStringLiteral("HiddenCollectionGroups")).toStringList();
    if (!collections.isEmpty()) {
        m_hiddenCollectionGroups = {collections.constBegin(), collections.constEnd()};
        emit hiddenCollectionGroupsChanged();
    }

    // arrange by
    setArrangeByCommunity(m_settings.value(QStringLiteral("ArrangeByCommunity"), false).toBool());
    setArrangeByCollection(m_settings.value(QStringLiteral("ArrangeByCollection"), false).toBool());

    m_settings.endGroup();

    setSettingsDirty(false);
}

void ManageTokensController::setSettingsDirty(bool dirty)
{
    if (m_settingsDirty == dirty) return;
    m_settingsDirty = dirty;
    emit settingsDirtyChanged(m_settingsDirty);
}

void ManageTokensController::incRevision()
{
    m_revision++;
    emit revisionChanged();
}

QStringList ManageTokensController::hiddenCommunityGroups() const
{
    return {m_hiddenCommunityGroups.constBegin(), m_hiddenCommunityGroups.constEnd()};
}

QStringList ManageTokensController::hiddenCollectionGroups() const
{
    return {m_hiddenCollectionGroups.constBegin(), m_hiddenCollectionGroups.constEnd()};
}

void ManageTokensController::revert()
{
    parseSourceModel();
}

QString ManageTokensController::settingsGroupName() const
{
    return QStringLiteral("ManageTokens-%1").arg(m_settingsKey);
}

bool ManageTokensController::hasSettings() const
{
    Q_ASSERT(!m_settingsKey.isEmpty());
    const auto groups = m_settings.childGroups();
    return groups.contains(settingsGroupName());
}

int ManageTokensController::compareTokens(const QString& lhsSymbol, const QString& rhsSymbol) const
{
    constexpr auto defaultVal = std::make_tuple(INT_MAX, false, QLatin1String(), false, false);

    int leftPos, rightPos;
    bool leftVisible, rightVisible;
    QString leftGroup, rightGroup;
    bool leftIsCommunityGroup, rightIsCommunityGroup, leftIsCollectionGroup, rightIsCollectionGroup;

    std::tie(leftPos, leftVisible, leftGroup, leftIsCommunityGroup, leftIsCollectionGroup) = m_settingsData.value(lhsSymbol, defaultVal);
    std::tie(rightPos, rightVisible, rightGroup, rightIsCommunityGroup, rightIsCollectionGroup) = m_settingsData.value(rhsSymbol, defaultVal);

    // check grouped position
    if (((m_arrangeByCommunity && leftIsCommunityGroup && rightIsCommunityGroup)
         || (m_arrangeByCollection && leftIsCollectionGroup && rightIsCollectionGroup))) {
        leftPos = std::get<0>(m_settingsData.value(leftGroup, defaultVal));
        rightPos = std::get<0>(m_settingsData.value(rightGroup, defaultVal));
    }

    // check if visible
    leftPos = leftVisible ? leftPos : INT_MAX;
    rightPos = rightVisible ? rightPos : INT_MAX;

    if (leftPos < rightPos)
        return -1;
    if (leftPos > rightPos)
        return 1;
    return 0;
}

bool ManageTokensController::filterAcceptsSymbol(const QString& symbol) const
{
    if (symbol.isEmpty()) return true;

    return std::get<1>(m_settingsData.value(symbol, {INT_MAX, true, QString(), false, false}));
}

void ManageTokensController::classBegin()
{
    // empty on purpose
}

void ManageTokensController::componentComplete()
{
    loadSettings();
}

void ManageTokensController::setSourceModel(QAbstractItemModel* newSourceModel)
{
    if(m_sourceModel == newSourceModel) return;

    if(!newSourceModel) {
        disconnect(sourceModel());
        // clear all the models
        for (auto model: m_allModels)
            model->clear();
        m_settingsData.clear();
        m_hiddenCommunityGroups.clear();
        m_hiddenCollectionGroups.clear();
        setSettingsDirty(false);
        m_sourceModel = newSourceModel;
        emit sourceModelChanged();
        return;
    }

    m_sourceModel = newSourceModel;

    connect(m_sourceModel, &QAbstractItemModel::modelReset, this, &ManageTokensController::parseSourceModel);

    if (m_sourceModel && m_sourceModel->roleNames().isEmpty()) { // workaround for when a model has no roles and roles are added when the model is populated (ListModel)
        // QTBUG-57971
        connect(m_sourceModel, &QAbstractItemModel::rowsInserted, this, &ManageTokensController::parseSourceModel);
        return;
    } else {
        parseSourceModel();
    }
}

void ManageTokensController::parseSourceModel()
{
    if (!m_sourceModel)
        return;

    disconnect(m_sourceModel, &QAbstractItemModel::rowsInserted, this, &ManageTokensController::parseSourceModel);

#ifdef QT_DEBUG
    QElapsedTimer t;
    t.start();
#endif

    // clear all the models
    for (auto model: m_allModels)
        model->clear();

    // load settings
    loadSettings();

    // read and transform the original data
    const auto newSize = m_sourceModel->rowCount();
    qCDebug(manageTokens) << "!!! PARSING" << newSize << "TOKENS";
    for (auto i = 0; i < newSize; i++) {
        addItem(i);
    }

    // build community groups model
    rebuildCommunityTokenGroupsModel();
    rebuildHiddenCommunityTokenGroupsModel();

    // build collections
    rebuildCollectionGroupsModel();
    rebuildHiddenCollectionGroupsModel();

    // (pre)sort
    for (auto model: m_allModels) {
        model->applySort();
        model->setDirty(false);
    }

#ifdef QT_DEBUG
    qCDebug(manageTokens) << "!!! PARSING SOURCE DATA TOOK" << t.nsecsElapsed()/1'000'000.f << "ms";
#endif

    emit sourceModelChanged();
}

void ManageTokensController::addItem(int index)
{
    const auto sourceRoleNames = m_sourceModel->roleNames();

    const auto dataForIndex = [&](const QModelIndex &idx, const QByteArray& rolename) -> QVariant {
        const auto key = sourceRoleNames.key(rolename, -1);
        if (key == -1)
            return {};
        return idx.data(key);
    };

    const auto srcIndex = m_sourceModel->index(index, 0);
    const auto symbol = dataForIndex(srcIndex, kSymbolRoleName).toString();
    const auto communityId = dataForIndex(srcIndex, kCommunityIdRoleName).toString();
    const auto communityName = dataForIndex(srcIndex, kCommunityNameRoleName).toString();
    const auto visible = m_settingsData.contains(symbol) ? std::get<1>(m_settingsData.value(symbol)) : true;
    const auto bgColor = dataForIndex(srcIndex, kBackgroundColorRoleName).value<QColor>();
    const auto collectionUid = dataForIndex(srcIndex, kCollectionUidRoleName).toString();

    TokenData token;
    token.symbol = symbol;
    token.name = dataForIndex(srcIndex, kNameRoleName).toString();
    token.image = dataForIndex(srcIndex, kTokenImageRoleName).toString();
    if (bgColor.isValid())
        token.backgroundColor = bgColor;
    token.communityId = communityId;
    token.communityName = !communityName.isEmpty() ? communityName : communityId;
    token.communityImage = dataForIndex(srcIndex, kCommunityImageRoleName).toString();
    token.collectionUid = !collectionUid.isEmpty() ? collectionUid : symbol;
    token.isSelfCollection = collectionUid.isEmpty();
    token.collectionName = dataForIndex(srcIndex, kCollectionNameRoleName).toString();
    token.balance = dataForIndex(srcIndex, kEnabledNetworkBalanceRoleName);
    token.currencyBalance = dataForIndex(srcIndex, kEnabledNetworkCurrencyBalanceRoleName);
    token.balances = dataForIndex(srcIndex, kBalancesRoleName);
    token.decimals = dataForIndex(srcIndex, kDecimalsRoleName);
    token.marketDetails = dataForIndex(srcIndex, kMarketDetailsRoleName);

    token.customSortOrderNo = m_settingsData.contains(symbol) ? std::get<0>(m_settingsData.value(symbol))
                                                              : (visible ? INT_MAX : 0); // append/prepend

    if (!visible)
        m_hiddenTokensModel->addItem(token, /*append*/ false);
    else if (!communityId.isEmpty())
        m_communityTokensModel->addItem(token);
    else
        m_regularTokensModel->addItem(token);
}

bool ManageTokensController::dirty() const
{
    return std::any_of(m_allModels.cbegin(), m_allModels.cend(), [](auto model) {
        return model->dirty();
    });
}

bool ManageTokensController::arrangeByCommunity() const
{
    return m_arrangeByCommunity;
}

void ManageTokensController::setArrangeByCommunity(bool newArrangeByCommunity)
{
    if(m_arrangeByCommunity == newArrangeByCommunity) return;
    m_arrangeByCommunity = newArrangeByCommunity;
    if (m_arrangeByCommunity) {
        rebuildCommunityTokenGroupsModel();
        m_communityTokenGroupsModel->applySortByTokensAmount();
        m_communityTokenGroupsModel->setDirty(true);
    }
    emit arrangeByCommunityChanged();
}

bool ManageTokensController::arrangeByCollection() const
{
    return m_arrangeByCollection;
}

void ManageTokensController::setArrangeByCollection(bool newArrangeByCollection)
{
    if(m_arrangeByCollection == newArrangeByCollection) return;
    m_arrangeByCollection = newArrangeByCollection;
    if (m_arrangeByCollection) {
        rebuildCollectionGroupsModel();
        m_collectionGroupsModel->applySortByTokensAmount();
        m_collectionGroupsModel->setDirty(true);
    }
    emit arrangeByCollectionChanged();
}

void ManageTokensController::rebuildCommunityTokenGroupsModel()
{
    QStringList communityIds;
    QList<TokenData> result;

    const auto count = m_communityTokensModel->rowCount();
    for (auto i = 0; i < count; i++) {
        const auto& communityToken = m_communityTokensModel->itemAt(i);
        const auto communityId = communityToken.communityId;
        if (!communityIds.contains(communityId)) { // insert into groups
            communityIds.append(communityId);

            TokenData tokenGroup;
            tokenGroup.symbol = communityId;
            tokenGroup.communityId = communityId;
            tokenGroup.communityName = communityToken.communityName;
            tokenGroup.communityImage = communityToken.communityImage;
            tokenGroup.backgroundColor = communityToken.backgroundColor;
            tokenGroup.balance = 1;

            if (m_settingsData.contains(communityId)) {
                tokenGroup.customSortOrderNo = std::get<0>(m_settingsData.value(communityId));
            }

            result.append(tokenGroup);
        } else { // update group's childCount
            const auto tokenGroup = std::find_if(result.cbegin(), result.cend(), [communityId](const auto& item) {
                return communityId == item.communityId;
            });
            if (tokenGroup != result.cend()) {
                const auto row = std::distance(result.cbegin(), tokenGroup);
                TokenData& updTokenGroup = result[row];
                updTokenGroup.balance = updTokenGroup.balance.toInt() + 1;
            }
        }
    }

    m_communityTokenGroupsModel->clear();
    for (const auto& group: std::as_const(result))
        m_communityTokenGroupsModel->addItem(group);

    qCDebug(manageTokens) << "!!! GROUPS MODEL REBUILT WITH GROUPS:" << communityIds;
}

void ManageTokensController::rebuildHiddenCommunityTokenGroupsModel()
{
    QStringList communityIds;
    QList<TokenData> result;

    const auto count = m_hiddenTokensModel->rowCount();
    for (auto i = 0; i < count; i++) {
        const auto& communityToken = m_hiddenTokensModel->itemAt(i);
        const auto communityId = communityToken.communityId;
        if (communityId.isEmpty())
            continue;
        if (!communityIds.contains(communityId) && m_hiddenCommunityGroups.contains(communityId)) { // insert into groups
            communityIds.append(communityId);

            TokenData tokenGroup;
            tokenGroup.symbol = communityId;
            tokenGroup.communityId = communityId;
            tokenGroup.communityName = communityToken.communityName;
            tokenGroup.communityImage = communityToken.communityImage;
            tokenGroup.backgroundColor = communityToken.backgroundColor;
            tokenGroup.balance = 1;
            result.append(tokenGroup);
        } else { // update group's childCount
            const auto tokenGroup = std::find_if(result.cbegin(), result.cend(), [communityId](const auto& item) {
                return communityId == item.communityId;
            });
            if (tokenGroup != result.cend()) {
                const auto row = std::distance(result.cbegin(), tokenGroup);
                TokenData& updTokenGroup = result[row];
                updTokenGroup.balance = updTokenGroup.balance.toInt() + 1;
            }
        }
    }

    m_hiddenCommunityTokenGroupsModel->clear();
    for (const auto& group: std::as_const(result))
        m_hiddenCommunityTokenGroupsModel->addItem(group);

    qCDebug(manageTokens) << "!!! HIDDEN GROUPS MODEL REBUILT WITH GROUPS:" << communityIds;
}

void ManageTokensController::rebuildCollectionGroupsModel()
{
    QStringList collectionIds;
    QList<TokenData> result;

    const auto count = m_regularTokensModel->rowCount();
    for (auto i = 0; i < count; i++) {
        const auto& collectionToken = m_regularTokensModel->itemAt(i);
        const auto collectionId = collectionToken.collectionUid;
        const auto isSelfCollection = collectionToken.isSelfCollection;
        if (!collectionIds.contains(collectionId)) { // insert into groups
            collectionIds.append(collectionId);

            const auto collectionName = !collectionToken.collectionName.isEmpty() ? collectionToken.collectionName : collectionToken.name;

            TokenData tokenGroup;
            tokenGroup.symbol = collectionId;
            tokenGroup.collectionUid = collectionId;
            tokenGroup.isSelfCollection = isSelfCollection;
            tokenGroup.collectionName = collectionName;
            tokenGroup.image = collectionToken.image;
            tokenGroup.backgroundColor = collectionToken.backgroundColor;
            tokenGroup.balance = 1;

            if (m_settingsData.contains(collectionId)) {
                tokenGroup.customSortOrderNo = std::get<0>(m_settingsData.value(collectionId));
            }

            result.append(tokenGroup);
        } else if (!isSelfCollection) { // update group's childCount
            const auto tokenGroup = std::find_if(result.cbegin(), result.cend(), [collectionId](const auto& item) {
                return collectionId == item.collectionUid;
            });
            if (tokenGroup != result.cend()) {
                const auto row = std::distance(result.cbegin(), tokenGroup);
                TokenData& updTokenGroup = result[row];
                updTokenGroup.balance = updTokenGroup.balance.toInt() + 1;
            }
        }
    }

    m_collectionGroupsModel->clear();
    for (const auto& group: std::as_const(result))
        m_collectionGroupsModel->addItem(group);

    qCDebug(manageTokens) << "!!! COLLECTION MODEL REBUILT WITH GROUPS:" << collectionIds;
}

void ManageTokensController::rebuildHiddenCollectionGroupsModel()
{
    QStringList collectionIds;
    QList<TokenData> result;

    const auto count = m_hiddenTokensModel->rowCount();
    for (auto i = 0; i < count; i++) {
        const auto& collectionToken = m_hiddenTokensModel->itemAt(i);
        const auto collectionId = collectionToken.collectionUid;
        const auto isSelfCollection = collectionToken.isSelfCollection;
        if (!collectionIds.contains(collectionId) && m_hiddenCollectionGroups.contains(collectionId)) { // insert into groups
            collectionIds.append(collectionId);

            const auto collectionName = !collectionToken.collectionName.isEmpty() ? collectionToken.collectionName : collectionToken.name;

            TokenData tokenGroup;
            tokenGroup.symbol = collectionId;
            tokenGroup.collectionUid = collectionId;
            tokenGroup.isSelfCollection = isSelfCollection;
            tokenGroup.collectionName = collectionName;
            tokenGroup.image = collectionToken.image;
            tokenGroup.backgroundColor = collectionToken.backgroundColor;
            tokenGroup.balance = 1;
            result.append(tokenGroup);
        } else if (!isSelfCollection) { // update group's childCount
            const auto tokenGroup = std::find_if(result.cbegin(), result.cend(), [collectionId](const auto& item) {
                return collectionId == item.collectionUid;
            });
            if (tokenGroup != result.cend()) {
                const auto row = std::distance(result.cbegin(), tokenGroup);
                TokenData& updTokenGroup = result[row];
                updTokenGroup.balance = updTokenGroup.balance.toInt() + 1;
            }
        }
    }

    m_hiddenCollectionGroupsModel->clear();
    for (const auto& group: std::as_const(result))
        m_hiddenCollectionGroupsModel->addItem(group);

    qCDebug(manageTokens) << "!!! HIDDEN COLLECTION GROUPS MODEL REBUILT WITH GROUPS:" << collectionIds;
}

QString ManageTokensController::settingsKey() const
{
    return m_settingsKey;
}

void ManageTokensController::setSettingsKey(const QString& newSettingsKey)
{
    if (m_settingsKey == newSettingsKey)
        return;
    m_settingsKey = newSettingsKey;
    emit settingsKeyChanged();
}
