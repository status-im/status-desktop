#include "StatusQ/shellproxymodel.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonObject>
#include <QSettings>

namespace {
constexpr auto kKeyName = "key";

constexpr auto kTimestampRoleName = "timestamp";
constexpr auto kPinnedRoleName = "pinned";

constexpr auto kSettingsGroupPrefix = "Shell";
constexpr auto kSettingsEntry = "entries";
};

struct ShellItemData {
    ShellItemData(): timestamp(0), pinned(false) {}
    explicit ShellItemData(bool pin): pinned(pin), timestamp(0) {}

    qlonglong timestamp{0}; // serialized as a string in JSON
    bool pinned{false};

    QJsonObject toJson() const {
        return {{kTimestampRoleName, QString::number(timestamp)}, {kPinnedRoleName, pinned}};
    }
    void fromJson(const QJsonObject& obj) {
        timestamp = obj.value(kTimestampRoleName).toString(QStringLiteral("0")).toLongLong();
        pinned = obj.value(kPinnedRoleName).toBool(false);
    }
};

ShellProxyModel::ShellProxyModel(QObject *parent)
    : QIdentityProxyModel{parent}
{
}

ShellProxyModel::~ShellProxyModel()
{
    save();
}

void ShellProxyModel::clear() {
    beginResetModel();

    m_data.clear();

    QSettings settings;
    settings.beginGroup(settingsGroup());
    settings.remove({}); // remove the group
    settings.endGroup();
    settings.sync();

    endResetModel();
}

void ShellProxyModel::save()
{
    if (m_data.isEmpty())
        return;

    QJsonArray result;

    QHashIterator i(m_data);
    while (i.hasNext()) {
        i.next();
        auto entry = i.value().toJson();
        entry.insert(kKeyName, i.key());
        result.append(entry);
    }

    QSettings settings;
    settings.beginGroup(settingsGroup());
    settings.setValue(kSettingsEntry, result);
    settings.endGroup();
    settings.sync();
}

void ShellProxyModel::load()
{
    QSettings settings;
    settings.beginGroup(settingsGroup());
    const auto savedEntries = settings.value(kSettingsEntry).toJsonArray();
    settings.endGroup();

    if (!savedEntries.isEmpty()) {
        beginResetModel();
        m_data.clear();
        for (const auto &savedEntry : savedEntries) {
            if (!savedEntry.isObject())
                continue;
            const auto savedObj = savedEntry.toObject();

            ShellItemData item;
            item.fromJson(savedObj);

            m_data.insert(savedObj.value(kKeyName).toString(), item);
        }
        endResetModel();
    }
}

QVariant ShellProxyModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= rowCount())
        return {};

    const auto keyAtIndex = sourceModel()->data(index, m_keyRoleValue).toString();

    switch (static_cast<ExtraRoles>(role)) {
    case TimestampRole:
        return m_data.value(keyAtIndex).timestamp;
    case PinnedRole:
        return m_data.value(keyAtIndex).pinned;
    }

    return QIdentityProxyModel::data(index, role);
}

bool ShellProxyModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.row() < 0 || index.row() >= rowCount())
        return false;

    const QString keyAtIndex = sourceModel()->data(index, m_keyRoleValue).toString();

    auto &item = m_data[keyAtIndex]; // creates the item if needed

    switch (static_cast<ExtraRoles>(role)) {
    case TimestampRole:
        item.timestamp = value.toLongLong();
        emit dataChanged(index, index, {TimestampRole});
        return true;
    case PinnedRole:
        item.pinned = value.toBool();
        emit dataChanged(index, index, {PinnedRole});
        return true;
    }

    return false;
}

Qt::ItemFlags ShellProxyModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable | Qt::ItemIsSelectable | Qt::ItemNeverHasChildren | QIdentityProxyModel::flags(index);
}

void ShellProxyModel::setSourceModel(QAbstractItemModel *model)
{
    if (sourceModel() == model)
        return;

    if (sourceModel() != nullptr)
        sourceModel()->disconnect(this);

    if (model == nullptr) {
        m_roleNames.clear();
        QIdentityProxyModel::setSourceModel(nullptr);
        return;
    }

    // Workaround for QTBUG-57971
    // delay the roleNames() init after some data had been inserted
    if (model->roleNames().isEmpty())
        connect(model, &QAbstractItemModel::rowsInserted, this, &ShellProxyModel::initRoles);

    QIdentityProxyModel::setSourceModel(model);
}

QHash<int, QByteArray> ShellProxyModel::roleNames() const
{
    return m_roleNames;
}

void ShellProxyModel::classBegin() {
    // empty on purpose
}

void ShellProxyModel::componentComplete() {
     load();
}

void ShellProxyModel::resetInternalData()
{
    // underlying model roles
    m_roleNames.clear();

    if (sourceModel() == nullptr)
        return;

    m_roleNames = sourceModel()->roleNames();

    QHashIterator i(m_roleNames);
    while (i.hasNext()) {
        i.next();
        if (i.value() == kKeyName) {
            m_keyRoleValue = i.key();
            break;
        }
    }

    // extra roles from this model
    m_roleNames.insert({
        {TimestampRole, kTimestampRoleName},
        {PinnedRole, kPinnedRoleName},
    });
}

void ShellProxyModel::initRoles()
{
    disconnect(sourceModel(), &QAbstractItemModel::rowsInserted, this, &ShellProxyModel::initRoles);
    resetInternalData();
}

QString ShellProxyModel::profileId() const
{
    return m_profileId;
}

void ShellProxyModel::setProfileId(const QString &newProfileId)
{
    if (m_profileId == newProfileId)
        return;
    m_profileId = newProfileId;
    emit profileIdChanged();
}

QString ShellProxyModel::settingsGroup() const {
    return QStringLiteral("%1_%2").arg(kSettingsGroupPrefix, m_profileId);
}
