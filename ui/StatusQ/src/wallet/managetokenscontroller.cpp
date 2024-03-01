#include "managetokenscontroller.h"

#include "tokendata.h"

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
        connect(m_sourceModel,
                &QAbstractItemModel::rowsInserted,
                this,
                [this](const QModelIndex& parent, int first, int last) {
#ifdef QT_DEBUG
                    QElapsedTimer t;
                    t.start();
                    qCDebug(manageTokens) << "!!! ADDING" << last - first + 1 << "NEW TOKENS";
#endif
                    for (int i = first; i <= last; i++)
                        addItem(i);

                    rebuildCommunityTokenGroupsModel();
                    rebuildHiddenCommunityTokenGroupsModel();
                    reloadCommunityIds();
                    m_communityTokensModel->setCommunityIds(m_communityIds);
                    rebuildCollectionGroupsModel();
                    rebuildHiddenCollectionGroupsModel();

                    for (auto model : m_allModels) {
                        model->applySort();
                        model->saveCustomSortOrder();
                    }
#ifdef QT_DEBUG
                    qCDebug(manageTokens)
                        << "!!! ADDING NEW SOURCE DATA TOOK" << t.nsecsElapsed() / 1'000'000.f << "ms";
#endif
                });
        connect(m_sourceModel, &QAbstractItemModel::rowsRemoved, this, &ManageTokensController::requestLoadSettings);
        connect(m_sourceModel,
                &QAbstractItemModel::dataChanged,
                this,
                &ManageTokensController::requestLoadSettings); // NB at this point we don't know in
                                                               // which submodel the item is
        connect(m_communityTokensModel, &ManageTokensModel::rowsMoved, this, [this]() {
            if (!m_arrangeByCommunity)
                rebuildCommunityTokenGroupsModel();
            reloadCommunityIds();
            m_communityTokensModel->setCommunityIds(m_communityIds);
            m_communityTokensModel->saveCustomSortOrder();
        });
        connect(m_communityTokenGroupsModel,
                &ManageTokensModel::rowsMoved,
                this,
                [this](const QModelIndex& parent, int start, int end, const QModelIndex& destination, int toRow) {
                    qCDebug(manageTokens) << "!!! COMMUNITY GROUP MOVED FROM" << start << "TO" << toRow;
                    reloadCommunityIds();
                    m_communityTokensModel->setCommunityIds(m_communityIds);
                    m_communityTokensModel->saveCustomSortOrder();
                    m_communityTokensModel->applySort();
                });
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
    requestSaveSettings(serializeSettingsAsJson());
}

void ManageTokensController::showHideCommunityToken(const QString& symbol, bool flag)
{
    if (flag) { // show
        auto hiddenItem = m_hiddenTokensModel->takeItem(symbol);
        if (hiddenItem) {
            m_communityTokensModel->addItem(*hiddenItem);
            if (!m_communityIds.contains(hiddenItem->communityId))
                m_communityIds.append(hiddenItem->communityId);
            emit tokenShown(hiddenItem->symbol, hiddenItem->name);
        }
    } else { // hide
        auto shownItem = m_communityTokensModel->takeItem(symbol);
        if (shownItem) {
            m_hiddenTokensModel->addItem(*shownItem, false /*prepend*/);
            if (!m_communityTokensModel->hasCommunityIdToken(shownItem->communityId))
                m_communityIds.removeAll(shownItem->communityId);
            emit tokenHidden(shownItem->symbol, shownItem->name);
        }
    }
    m_communityTokensModel->setCommunityIds(m_communityIds);
    m_communityTokensModel->saveCustomSortOrder();
    rebuildCommunityTokenGroupsModel();
    rebuildHiddenCommunityTokenGroupsModel();
    requestSaveSettings(serializeSettingsAsJson());
}

void ManageTokensController::showHideGroup(const QString& groupId, bool flag)
{
    if (flag) { // show
        const auto tokens = m_hiddenTokensModel->takeAllItems(groupId);
        if (!tokens.isEmpty()) {
            for (const auto& token : tokens) {
                m_communityTokensModel->addItem(token);
            }
            emit communityTokenGroupShown(tokens.constFirst().communityName);
        }
        m_communityIds.append(groupId);
        if (m_hiddenCommunityGroups.remove(groupId)) {
            emit hiddenCommunityGroupsChanged();
        }
    } else { // hide
        const auto tokens = m_communityTokensModel->takeAllItems(groupId);
        if (!tokens.isEmpty()) {
            for (const auto& token : tokens) {
                m_hiddenTokensModel->addItem(token, false /*prepend*/);
            }
            emit communityTokenGroupHidden(tokens.constFirst().communityName);
        }
        m_communityIds.removeAll(groupId);
        if (!m_hiddenCommunityGroups.contains(groupId)) {
            m_hiddenCommunityGroups.insert(groupId);
            emit hiddenCommunityGroupsChanged();
        }
    }
    rebuildCommunityTokenGroupsModel();
    rebuildHiddenCommunityTokenGroupsModel();
    requestSaveSettings(serializeSettingsAsJson());
}

void ManageTokensController::showHideCollectionGroup(const QString& groupId, bool flag)
{
    if (flag) { // show
        const auto tokens = m_hiddenTokensModel->takeAllItems(groupId);
        if (!tokens.isEmpty()) {
            for (const auto& token : tokens) {
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
            for (const auto& token : tokens) {
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
    rebuildHiddenCollectionGroupsModel();
    requestSaveSettings(serializeSettingsAsJson());
}

void ManageTokensController::saveToQSettings(const QString& json)
{
    Q_ASSERT(!m_settingsKey.isEmpty());

    savingStarted();

    // save to QSettings
    m_settings.beginGroup(settingsGroupName());

    // data
    m_settings.setValue(m_settingsKey, json);

    m_settings.endGroup();
    m_settings.sync();

    savingFinished();
}

void ManageTokensController::clearQSettings()
{
    Q_ASSERT(!m_settingsKey.isEmpty());

    // clear the relevant QSettings group
    m_settings.beginGroup(settingsGroupName());
    m_settings.remove(QString());
    m_settings.endGroup();
    m_settings.sync();

    emit settingsDirtyChanged(false);
}

void ManageTokensController::loadFromQSettings()
{
    Q_ASSERT(!m_settingsKey.isEmpty());

    loadingStarted();

    // load from QSettings
    m_settings.beginGroup(settingsGroupName());
    const auto jsonData = m_settings.value(m_settingsKey).toString();
    m_settings.endGroup();

    loadingFinished(jsonData);
}

void ManageTokensController::setSettingsDirty(bool dirty)
{
    if (m_settingsDirty == dirty)
        return;
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

void ManageTokensController::revert() { requestLoadSettings(); }

void ManageTokensController::savingStarted()
{
    setSettingsDirty(true); // save to QSettings
    m_settings.beginGroup(settingsGroupName());

    m_settings.setValue(QStringLiteral("ArrangeByCommunity"), m_arrangeByCommunity);
    m_settings.setValue(QStringLiteral("ArrangeByCollection"), m_arrangeByCollection);

    m_settings.endGroup();
}

void ManageTokensController::savingFinished()
{
    // unset dirty
    for (auto model : m_allModels)
        model->setDirty(false);

    incRevision();

    setSettingsDirty(false);
}

void ManageTokensController::loadingStarted()
{
    setSettingsDirty(true);
    m_settingsData.clear();

    m_settings.beginGroup(settingsGroupName());

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
}

void ManageTokensController::loadingFinished(const QString& jsonData)
{
    if (!jsonData.isEmpty()) {
        auto result = tokenOrdersFromJson(jsonData, m_serializeAsCollectibles);
        if (result != m_settingsData) {
            m_settingsData = result;
        }
    }

    parseSourceModel();
    setSettingsDirty(false);
}

QString ManageTokensController::serializeSettingsAsJson()
{
    SerializedTokenData result;
    for (auto model : {m_regularTokensModel, m_communityTokensModel})
        result.insert(model->save());
    result.insert(m_hiddenTokensModel->save(false));
    auto json = tokenOrdersToJson(result, m_serializeAsCollectibles);
    return json;
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
    const auto left = m_settingsData.value(lhsSymbol, TokenOrder());
    const auto right = m_settingsData.value(rhsSymbol, TokenOrder());

    // check if visible
    auto leftPos = left.visible ? left.sortOrder : undefinedTokenOrder;
    auto rightPos = right.visible ? right.sortOrder : undefinedTokenOrder;

    if (leftPos < rightPos)
        return -1;
    if (leftPos > rightPos)
        return 1;
    return 0;
}

bool ManageTokensController::filterAcceptsSymbol(const QString& symbol) const
{
    if (symbol.isEmpty())
        return true;

    if (!m_settingsData.contains(symbol)) {
        return true;
    }
    return m_settingsData.value(symbol).visible;
}

void ManageTokensController::classBegin()
{
    // empty on purpose
}

void ManageTokensController::componentComplete() { requestLoadSettings(); }

void ManageTokensController::setSourceModel(QAbstractItemModel* newSourceModel)
{
    if (m_sourceModel == newSourceModel)
        return;

    if (!newSourceModel) {
        disconnect(sourceModel());
        // clear all the models
        for (auto model : m_allModels)
            model->clear();
        m_settingsData.clear();
        m_communityIds.clear();
        m_hiddenCommunityGroups.clear();
        m_hiddenCollectionGroups.clear();
        setSettingsDirty(false);
        m_sourceModel = newSourceModel;
        emit sourceModelChanged();
        return;
    }

    m_sourceModel = newSourceModel;

    connect(m_sourceModel, &QAbstractItemModel::modelReset, this, &ManageTokensController::requestLoadSettings);

    if (m_sourceModel && m_sourceModel->roleNames().isEmpty()) { // workaround for when a model has no roles and roles
                                                                 // are added when the model is populated (ListModel)
        // QTBUG-57971
        connect(m_sourceModel, &QAbstractItemModel::rowsInserted, this, &ManageTokensController::requestLoadSettings);
        return;
    } else {
        requestLoadSettings();
    }
}

void ManageTokensController::parseSourceModel()
{
    if (!m_sourceModel)
        return;

    disconnect(m_sourceModel, &QAbstractItemModel::rowsInserted, this, &ManageTokensController::requestLoadSettings);

#ifdef QT_DEBUG
    QElapsedTimer t;
    t.start();
#endif

    // clear all the models
    for (auto model : m_allModels)
        model->clear();

    // read and transform the original data
    const auto newSize = m_sourceModel->rowCount();
    qCDebug(manageTokens) << "!!! PARSING" << newSize << "TOKENS";
    for (auto i = 0; i < newSize; i++) {
        addItem(i);
    }

    // build community groups model
    rebuildCommunityTokenGroupsModel();
    rebuildHiddenCommunityTokenGroupsModel();
    reloadCommunityIds();
    m_communityTokensModel->setCommunityIds(m_communityIds);

    // build collections
    rebuildCollectionGroupsModel();
    rebuildHiddenCollectionGroupsModel();

    // (pre)sort
    for (auto model : m_allModels) {
        model->applySort();
        model->saveCustomSortOrder();
        model->setDirty(false);
    }

#ifdef QT_DEBUG
    qCDebug(manageTokens) << "!!! PARSING SOURCE DATA TOOK" << t.nsecsElapsed() / 1'000'000.f << "ms";
#endif

    emit sourceModelChanged();
}

void ManageTokensController::addItem(int index)
{
    const auto sourceRoleNames = m_sourceModel->roleNames();

    const auto dataForIndex = [&](const QModelIndex& idx, const QByteArray& rolename) -> QVariant {
        const auto key = sourceRoleNames.key(rolename, -1);
        if (key == -1)
            return {};
        return idx.data(key);
    };

    const auto srcIndex = m_sourceModel->index(index, 0);
    const auto symbol = dataForIndex(srcIndex, kSymbolRoleName).toString();
    const auto communityId = dataForIndex(srcIndex, kCommunityIdRoleName).toString();
    const auto communityName = dataForIndex(srcIndex, kCommunityNameRoleName).toString();
    const auto visible = m_settingsData.contains(symbol) ? m_settingsData.value(symbol).visible : true;
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

    token.customSortOrderNo = m_settingsData.contains(symbol) ? m_settingsData.value(symbol).sortOrder
                                                              : (visible ? undefinedTokenOrder : 0); // append/prepend

    if (!visible)
        m_hiddenTokensModel->addItem(token, /*append*/ false);
    else if (!communityId.isEmpty())
        m_communityTokensModel->addItem(token);
    else
        m_regularTokensModel->addItem(token);
}

bool ManageTokensController::dirty() const
{
    return std::any_of(m_allModels.cbegin(), m_allModels.cend(), [](auto model) { return model->dirty(); });
}

bool ManageTokensController::arrangeByCommunity() const { return m_arrangeByCommunity; }

void ManageTokensController::setArrangeByCommunity(bool newArrangeByCommunity)
{
    if (m_arrangeByCommunity == newArrangeByCommunity)
        return;
    m_arrangeByCommunity = newArrangeByCommunity;
    if (m_arrangeByCommunity) {
        rebuildCommunityTokenGroupsModel();
        m_communityTokenGroupsModel->applySortByTokensAmount();
        m_communityTokenGroupsModel->setDirty(true);
    }
    emit arrangeByCommunityChanged();
}

bool ManageTokensController::arrangeByCollection() const { return m_arrangeByCollection; }

void ManageTokensController::setArrangeByCollection(bool newArrangeByCollection)
{
    if (m_arrangeByCollection == newArrangeByCollection)
        return;
    m_arrangeByCollection = newArrangeByCollection;
    if (m_arrangeByCollection) {
        rebuildCollectionGroupsModel();
        m_collectionGroupsModel->applySortByTokensAmount();
        m_collectionGroupsModel->setDirty(true);
    }
    emit arrangeByCollectionChanged();
}

void ManageTokensController::reloadCommunityIds()
{
    m_communityIds.clear();
    auto model = m_arrangeByCommunity ? m_communityTokenGroupsModel : m_communityTokensModel;
    const auto count = model->count();
    for (int i = 0; i < count; i++) {
        const auto& token = model->itemAt(i);
        if (!m_communityIds.contains(token.communityId))
            m_communityIds.append(token.communityId);
    }
    qCDebug(manageTokens) << "!!! FOUND UNIQUE COMMUNITY GROUP IDs:" << m_communityIds;
}

void ManageTokensController::rebuildCommunityTokenGroupsModel()
{
    QStringList communityIds;
    QList<TokenData> result;

    const auto count = m_communityTokensModel->count();
    for (auto i = 0; i < count; i++) {
        const auto& communityToken = m_communityTokensModel->itemAt(i);
        const auto communityId = communityToken.communityId;
        if (!communityIds.contains(communityId)) { // insert into groups
            communityIds.append(communityId);

            TokenData tokenGroup;
            tokenGroup.communityId = communityId;
            tokenGroup.communityName = communityToken.communityName;
            tokenGroup.communityImage = communityToken.communityImage;
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

    m_communityTokenGroupsModel->clear();
    for (const auto& group : std::as_const(result))
        m_communityTokenGroupsModel->addItem(group);

    qCDebug(manageTokens) << "!!! GROUPS MODEL REBUILT WITH GROUPS:" << communityIds;
}

void ManageTokensController::rebuildHiddenCommunityTokenGroupsModel()
{
    QStringList communityIds;
    QList<TokenData> result;

    const auto count = m_hiddenTokensModel->count();
    for (auto i = 0; i < count; i++) {
        const auto& communityToken = m_hiddenTokensModel->itemAt(i);
        const auto communityId = communityToken.communityId;
        if (communityId.isEmpty())
            continue;
        if (!communityIds.contains(communityId) &&
            m_hiddenCommunityGroups.contains(communityId)) { // insert into groups
            communityIds.append(communityId);

            TokenData tokenGroup;
            tokenGroup.communityId = communityId;
            tokenGroup.communityName = communityToken.communityName;
            tokenGroup.communityImage = communityToken.communityImage;
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
    for (const auto& group : std::as_const(result))
        m_hiddenCommunityTokenGroupsModel->addItem(group);

    qCDebug(manageTokens) << "!!! HIDDEN GROUPS MODEL REBUILT WITH GROUPS:" << communityIds;
}

void ManageTokensController::rebuildCollectionGroupsModel()
{
    QStringList collectionIds;
    QList<TokenData> result;

    const auto count = m_regularTokensModel->count();
    for (auto i = 0; i < count; i++) {
        const auto& collectionToken = m_regularTokensModel->itemAt(i);
        const auto collectionId = collectionToken.collectionUid;
        const auto isSelfCollection = collectionToken.isSelfCollection;
        if (!collectionIds.contains(collectionId)) { // insert into groups
            collectionIds.append(collectionId);

            const auto collectionName =
                !collectionToken.collectionName.isEmpty() ? collectionToken.collectionName : collectionToken.name;

            TokenData tokenGroup;
            tokenGroup.collectionUid = collectionId;
            tokenGroup.isSelfCollection = isSelfCollection;
            tokenGroup.collectionName = collectionName;
            tokenGroup.image = collectionToken.image;
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

    m_collectionGroupsModel->clear();
    for (const auto& group : std::as_const(result))
        m_collectionGroupsModel->addItem(group);

    qCDebug(manageTokens) << "!!! COLLECTION MODEL REBUILT WITH GROUPS:" << collectionIds;
}

void ManageTokensController::rebuildHiddenCollectionGroupsModel()
{
    QStringList collectionIds;
    QList<TokenData> result;

    const auto count = m_hiddenTokensModel->count();
    for (auto i = 0; i < count; i++) {
        const auto& collectionToken = m_hiddenTokensModel->itemAt(i);
        const auto collectionId = collectionToken.collectionUid;
        const auto isSelfCollection = collectionToken.isSelfCollection;
        if (!collectionIds.contains(collectionId) &&
            m_hiddenCollectionGroups.contains(collectionId)) { // insert into groups
            collectionIds.append(collectionId);

            const auto collectionName =
                !collectionToken.collectionName.isEmpty() ? collectionToken.collectionName : collectionToken.name;

            TokenData tokenGroup;
            tokenGroup.collectionUid = collectionId;
            tokenGroup.isSelfCollection = isSelfCollection;
            tokenGroup.collectionName = collectionName;
            tokenGroup.image = collectionToken.image;
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
    for (const auto& group : std::as_const(result))
        m_hiddenCollectionGroupsModel->addItem(group);

    qCDebug(manageTokens) << "!!! HIDDEN COLLECTION GROUPS MODEL REBUILT WITH GROUPS:" << collectionIds;
}

QString ManageTokensController::settingsKey() const { return m_settingsKey; }

void ManageTokensController::setSettingsKey(const QString& newSettingsKey)
{
    if (m_settingsKey == newSettingsKey)
        return;
    m_settingsKey = newSettingsKey;
    emit settingsKeyChanged();
}

bool ManageTokensController::serializeAsCollectibles() const { return m_serializeAsCollectibles; }

void ManageTokensController::setSerializeAsCollectibles(const bool newSerializeAsCollectibles)
{
    if (m_serializeAsCollectibles == newSerializeAsCollectibles)
        return;
    m_serializeAsCollectibles = newSerializeAsCollectibles;
    emit serializeAsCollectiblesChanged();
}