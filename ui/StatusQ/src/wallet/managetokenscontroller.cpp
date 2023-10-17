#include "managetokenscontroller.h"

#include <QElapsedTimer>

ManageTokensController::ManageTokensController(QObject* parent)
    : QObject(parent)
    , m_regularTokensModel(new ManageTokensModel(this))
    , m_communityTokensModel(new ManageTokensModel(this))
    , m_communityTokenGroupsModel(new ManageTokensModel(this))
    , m_hiddenTokensModel(new ManageTokensModel(this))
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
            qCInfo(manageTokens) << "!!! ADDING" << last-first+1 << "NEW TOKENS";
#endif
            for (int i = first; i <= last; i++)
                addItem(i);
            reloadCommunityIds();
            m_communityTokensModel->setCommunityIds(m_communityIds);
            m_communityTokensModel->saveCustomSortOrder();
            rebuildCommunityTokenGroupsModel();
#ifdef QT_DEBUG
            qCInfo(manageTokens) << "!!! ADDING NEW SOURCE DATA TOOK" << t.nsecsElapsed()/1'000'000.f << "ms";
#endif
        });
        connect(m_sourceModel, &QAbstractItemModel::rowsRemoved, this, &ManageTokensController::parseSourceModel);
        connect(m_sourceModel, &QAbstractItemModel::dataChanged, this, &ManageTokensController::parseSourceModel); // NB at this point we don't know in which submodel the item is
        connect(m_communityTokensModel, &ManageTokensModel::rowsMoved, this, [this]() {
            if (!m_arrangeByCommunity)
                rebuildCommunityTokenGroupsModel();
            reloadCommunityIds();
            m_communityTokensModel->setCommunityIds(m_communityIds);
            m_communityTokensModel->saveCustomSortOrder();
        });
        connect(m_communityTokenGroupsModel, &ManageTokensModel::rowsMoved, this, [this](const QModelIndex &parent, int start, int end, const QModelIndex &destination, int toRow) {
            qCDebug(manageTokens) << "!!! GROUP MOVED FROM" << start << "TO" << toRow;
            // FIXME swap toRow<->start instead of reloadCommunityIds()?
            reloadCommunityIds();
            m_communityTokensModel->setCommunityIds(m_communityIds);
            m_communityTokensModel->saveCustomSortOrder();
        });
        m_modelConnectionsInitialized = true;
    });
}

void ManageTokensController::showHideRegularToken(int row, bool flag)
{
    if (flag) { // show
        auto hiddenItem = m_hiddenTokensModel->takeItem(row);
        if (hiddenItem)
            m_regularTokensModel->addItem(*hiddenItem);
    } else { // hide
        auto shownItem = m_regularTokensModel->takeItem(row);
        if (shownItem)
            m_hiddenTokensModel->addItem(*shownItem, false /*prepend*/);
    }
}

void ManageTokensController::showHideCommunityToken(int row, bool flag)
{
    if (flag) { // show
        auto hiddenItem = m_hiddenTokensModel->takeItem(row);
        if (hiddenItem) {
            m_communityTokensModel->addItem(*hiddenItem);
            if (!m_communityIds.contains(hiddenItem->communityId))
                m_communityIds.append(hiddenItem->communityId);
        }
    } else { // hide
        auto shownItem = m_communityTokensModel->takeItem(row);
        if (shownItem) {
            m_hiddenTokensModel->addItem(*shownItem, false /*prepend*/);
            if (!m_communityTokensModel->hasCommunityIdToken(shownItem->communityId))
                m_communityIds.removeAll(shownItem->communityId);
        }
    }
    m_communityTokensModel->setCommunityIds(m_communityIds);
    m_communityTokensModel->saveCustomSortOrder();
    rebuildCommunityTokenGroupsModel();
}

void ManageTokensController::showHideGroup(const QString& groupId, bool flag)
{
    if (flag) { // show
        const auto tokens = m_hiddenTokensModel->takeAllItems(groupId);
        for (const auto& token: tokens) {
            m_communityTokensModel->addItem(token);
        }
        m_communityIds.append(groupId);
    } else { // hide
        const auto tokens = m_communityTokensModel->takeAllItems(groupId);
        for (const auto& token: tokens) {
            m_hiddenTokensModel->addItem(token, false /*prepend*/);
        }
        m_communityIds.removeAll(groupId);
    }
    m_communityTokensModel->setCommunityIds(m_communityIds);
    m_communityTokensModel->saveCustomSortOrder();
    rebuildCommunityTokenGroupsModel();
}

void ManageTokensController::saveSettings()
{
    Q_ASSERT(!m_settingsKey.isEmpty());

    // gather the data to save
    SerializedTokenData result;
    for (auto model: {m_regularTokensModel, m_communityTokensModel})
        result.insert(model->save());
    result.insert(m_hiddenTokensModel->save(false));

    // save to QSettings
    m_settings.beginGroup(QStringLiteral("ManageTokens-%1").arg(m_settingsKey));
    m_settings.beginWriteArray(m_settingsKey);
    SerializedTokenData::const_key_value_iterator it = result.constKeyValueBegin();
    for (auto i = 0; it != result.constKeyValueEnd() && i < result.size(); it++, i++) {
        m_settings.setArrayIndex(i);
        const auto tuple = it->second;
        m_settings.setValue(QStringLiteral("symbol"), it->first);
        m_settings.setValue(QStringLiteral("pos"), std::get<0>(tuple));
        m_settings.setValue(QStringLiteral("visible"), std::get<1>(tuple));
        m_settings.setValue(QStringLiteral("groupId"), std::get<2>(tuple));
    }
    m_settings.endArray();
    m_settings.endGroup();
    m_settings.sync();

    // unset dirty
    for (auto model: m_allModels)
        model->setDirty(false);
}

void ManageTokensController::clearSettings()
{
    Q_ASSERT(!m_settingsKey.isEmpty());

    // clear the relevant QSettings group
    m_settings.beginGroup(QStringLiteral("ManageTokens-%1").arg(m_settingsKey));
    m_settings.remove(QString());
    m_settings.endGroup();
    m_settings.sync();
}

void ManageTokensController::loadSettings()
{
    Q_ASSERT(!m_settingsKey.isEmpty());

    m_settingsData.clear();

    // load from QSettings
    m_settings.beginGroup(QStringLiteral("ManageTokens-%1").arg(m_settingsKey));
    const auto size = m_settings.beginReadArray(m_settingsKey);
    for (auto i = 0; i < size; i++) {
        m_settings.setArrayIndex(i);
        const auto symbol = m_settings.value(QStringLiteral("symbol")).toString();
        if (symbol.isEmpty()) {
            qCWarning(manageTokens) << Q_FUNC_INFO << "Missing symbol while reading tokens settings";
            continue;
        }
        const auto pos = m_settings.value(QStringLiteral("pos"), -1).toInt();
        const auto visible = m_settings.value(QStringLiteral("visible"), true).toBool();
        const auto groupId = m_settings.value(QStringLiteral("groupId")).toString();
        m_settingsData.insert(symbol, {pos, visible, groupId});
    }
    m_settings.endArray();
    m_settings.endGroup();
}

void ManageTokensController::revert()
{
    loadSettings();
    parseSourceModel();
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
        m_communityIds.clear();
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
    m_communityIds.clear();

    // read and transform the original data
    const auto newSize = m_sourceModel->rowCount();
    qCInfo(manageTokens) << "!!! PARSING" << newSize << "TOKENS";
    for (auto i = 0; i < newSize; i++) {
        addItem(i);
    }

    // build community groups model
    rebuildCommunityTokenGroupsModel();
    reloadCommunityIds();
    m_communityTokensModel->setCommunityIds(m_communityIds);

    // (pre)sort
    for (auto model: m_allModels) {
        model->applySort();
        model->saveCustomSortOrder();
        model->setDirty(false);
    }

#ifdef QT_DEBUG
    qCInfo(manageTokens) << "!!! PARSING SOURCE DATA TOOK" << t.nsecsElapsed()/1'000'000.f << "ms";
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

    TokenData token;
    token.symbol = symbol;
    token.name = dataForIndex(srcIndex, kNameRoleName).toString();
    token.image = dataForIndex(srcIndex, kTokenImageRoleName).toString();
    token.communityId = communityId;
    token.communityName = !communityName.isEmpty() ? communityName : communityId;
    token.communityImage = dataForIndex(srcIndex, kCommunityImageRoleName).toString();
    token.collectionUid = dataForIndex(srcIndex, kCollectionUidRoleName).toString();
    token.collectionName = dataForIndex(srcIndex, kCollectionNameRoleName).toString();
    token.balance = dataForIndex(srcIndex, kEnabledNetworkBalanceRoleName);
    token.currencyBalance = dataForIndex(srcIndex, kEnabledNetworkCurrencyBalanceRoleName);

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
    if (!m_arrangeByCommunity)
        m_communityTokensModel->applySort();
    else
        rebuildCommunityTokenGroupsModel();
    emit arrangeByCommunityChanged();
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
                TokenData updTokenGroup = result.takeAt(row);
                updTokenGroup.balance = updTokenGroup.balance.toInt() + 1;
                result.insert(row, updTokenGroup);
            }
        }
    }

    m_communityTokenGroupsModel->clear();
    for (const auto& group: result)
        m_communityTokenGroupsModel->addItem(group);

    qCDebug(manageTokens) << "!!! GROUPS MODEL REBUILT WITH GROUPS:" << communityIds;
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
