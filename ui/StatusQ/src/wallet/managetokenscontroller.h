#include <QObject>
#include <QQmlParserStatus>
#include <QSettings>

#include <array>

#include "managetokensmodel.h"

class QAbstractItemModel;

class ManageTokensController : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)

    // input properties
    Q_PROPERTY(QAbstractItemModel* sourceModel READ sourceModel WRITE setSourceModel NOTIFY sourceModelChanged FINAL)
    Q_PROPERTY(QString settingsKey READ settingsKey WRITE setSettingsKey NOTIFY settingsKeyChanged FINAL REQUIRED)

    Q_PROPERTY(bool arrangeByCommunity READ arrangeByCommunity WRITE setArrangeByCommunity NOTIFY arrangeByCommunityChanged FINAL)
    Q_PROPERTY(bool arrangeByCollection READ arrangeByCollection WRITE setArrangeByCollection NOTIFY arrangeByCollectionChanged FINAL)

    // output properties
    Q_PROPERTY(QAbstractItemModel* regularTokensModel READ regularTokensModel CONSTANT FINAL)
    Q_PROPERTY(QAbstractItemModel* collectionGroupsModel READ collectionGroupsModel CONSTANT FINAL)
    Q_PROPERTY(QAbstractItemModel* communityTokensModel READ communityTokensModel CONSTANT FINAL)
    Q_PROPERTY(QAbstractItemModel* communityTokenGroupsModel READ communityTokenGroupsModel CONSTANT FINAL)
    Q_PROPERTY(QAbstractItemModel* hiddenTokensModel READ hiddenTokensModel CONSTANT FINAL)

    Q_PROPERTY(QStringList hiddenCommunityGroups READ hiddenCommunityGroups NOTIFY hiddenCommunityGroupsChanged FINAL)
    Q_PROPERTY(QAbstractItemModel* hiddenCommunityTokenGroupsModel READ hiddenCommunityTokenGroupsModel CONSTANT FINAL)
    Q_PROPERTY(QStringList hiddenCollectionGroups READ hiddenCollectionGroups NOTIFY hiddenCollectionGroupsChanged FINAL)
    Q_PROPERTY(QAbstractItemModel* hiddenCollectionGroupsModel READ hiddenCollectionGroupsModel CONSTANT FINAL)

    Q_PROPERTY(bool dirty READ dirty NOTIFY dirtyChanged FINAL)
    Q_PROPERTY(bool hasSettings READ hasSettings NOTIFY settingsDirtyChanged FINAL)
    Q_PROPERTY(bool settingsDirty READ settingsDirty NOTIFY settingsDirtyChanged FINAL)
    Q_PROPERTY(int revision READ revision NOTIFY revisionChanged FINAL)

public:
    explicit ManageTokensController(QObject* parent = nullptr);

    Q_INVOKABLE void showHideRegularToken(const QString& symbol, bool flag);
    Q_INVOKABLE void showHideCommunityToken(const QString& symbol, bool flag);
    Q_INVOKABLE void showHideGroup(const QString& groupId, bool flag);
    Q_INVOKABLE void showHideCollectionGroup(const QString& groupId, bool flag);

    Q_INVOKABLE void loadSettings();
    Q_INVOKABLE void saveSettings();
    Q_INVOKABLE void clearSettings();
    Q_INVOKABLE void revert();

    Q_INVOKABLE int compareTokens(const QString& lhsSymbol, const QString& rhsSymbol) const;
    Q_INVOKABLE bool filterAcceptsSymbol(const QString& symbol) const;

protected:
    void classBegin() override;
    void componentComplete() override;

signals:
    void sourceModelChanged();
    void dirtyChanged();
    void arrangeByCommunityChanged();
    void arrangeByCollectionChanged();
    void settingsKeyChanged();
    void settingsDirtyChanged(bool dirty);

    void tokenHidden(const QString& symbol, const QString& name);
    void tokenShown(const QString& symbol, const QString& name);
    void communityTokenGroupHidden(const QString& communityName);
    void communityTokenGroupShown(const QString& communityName);
    void collectionTokenGroupHidden(const QString& communityName);
    void collectionTokenGroupShown(const QString& communityName);

    void hiddenCommunityGroupsChanged();
    void hiddenCollectionGroupsChanged();

    void revisionChanged();

private:
    QAbstractItemModel* m_sourceModel{nullptr};
    QAbstractItemModel* sourceModel() const { return m_sourceModel; }
    void setSourceModel(QAbstractItemModel* newSourceModel);
    void parseSourceModel();

    void addItem(int index);

    ManageTokensModel* m_regularTokensModel{nullptr};
    QAbstractItemModel* regularTokensModel() const { return m_regularTokensModel; }

    ManageTokensModel* m_collectionGroupsModel{nullptr};
    QAbstractItemModel* collectionGroupsModel() const { return m_collectionGroupsModel; }

    ManageTokensModel* m_communityTokensModel{nullptr};
    QAbstractItemModel* communityTokensModel() const { return m_communityTokensModel; }

    ManageTokensModel* m_communityTokenGroupsModel{nullptr};
    QAbstractItemModel* communityTokenGroupsModel() const { return m_communityTokenGroupsModel; }

    ManageTokensModel* m_hiddenTokensModel{nullptr};
    QAbstractItemModel* hiddenTokensModel() const { return m_hiddenTokensModel; }

    ManageTokensModel* m_hiddenCommunityTokenGroupsModel{nullptr};
    QAbstractItemModel* hiddenCommunityTokenGroupsModel() const { return m_hiddenCommunityTokenGroupsModel; }

    ManageTokensModel* m_hiddenCollectionGroupsModel{nullptr};
    QAbstractItemModel* hiddenCollectionGroupsModel() const { return m_hiddenCollectionGroupsModel; }

    bool dirty() const;

    bool m_arrangeByCommunity{false};
    bool arrangeByCommunity() const;
    void setArrangeByCommunity(bool newArrangeByCommunity);

    bool m_arrangeByCollection{false};
    bool arrangeByCollection() const;
    void setArrangeByCollection(bool newArrangeByCollection);

    QStringList m_communityIds;
    void reloadCommunityIds();
    void rebuildCommunityTokenGroupsModel();
    void rebuildHiddenCommunityTokenGroupsModel();
    void rebuildCollectionGroupsModel();
    void rebuildHiddenCollectionGroupsModel();

    const std::array<ManageTokensModel*, 7> m_allModels {m_regularTokensModel, m_collectionGroupsModel, m_communityTokensModel, m_communityTokenGroupsModel,
                                                        m_hiddenTokensModel, m_hiddenCommunityTokenGroupsModel, m_hiddenCollectionGroupsModel};

    QString m_settingsKey;
    QString settingsKey() const;
    QString settingsGroupName() const;
    void setSettingsKey(const QString& newSettingsKey);
    QSettings m_settings;
    SerializedTokenData m_settingsData; // symbol -> {sortOrder, visible, groupId}
    bool hasSettings() const;
    void loadSettingsData(bool withGroup = false);

    bool m_settingsDirty{false};
    bool settingsDirty() const { return m_settingsDirty; }
    void setSettingsDirty(bool dirty);

    int m_revision{0};
    int revision() const { return m_revision; }
    void incRevision();

    bool m_modelConnectionsInitialized{false};

    // explicitely mass-hidden community asset/collectible groups
    QSet<QString> m_hiddenCommunityGroups;
    QStringList hiddenCommunityGroups() const;

    QSet<QString> m_hiddenCollectionGroups;
    QStringList hiddenCollectionGroups() const;
};
