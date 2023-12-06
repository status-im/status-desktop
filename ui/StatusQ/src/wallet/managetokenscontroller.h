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
    Q_PROPERTY(bool arrangeByCommunity READ arrangeByCommunity WRITE setArrangeByCommunity NOTIFY arrangeByCommunityChanged FINAL) // TODO persist in settings

    // output properties
    Q_PROPERTY(QAbstractItemModel* regularTokensModel READ regularTokensModel CONSTANT FINAL)
    // TODO regularTokenGroupsModel for grouped (collections of) collectibles?
    Q_PROPERTY(QAbstractItemModel* communityTokensModel READ communityTokensModel CONSTANT FINAL)
    Q_PROPERTY(QAbstractItemModel* communityTokenGroupsModel READ communityTokenGroupsModel CONSTANT FINAL)
    Q_PROPERTY(QAbstractItemModel* hiddenTokensModel READ hiddenTokensModel CONSTANT FINAL)
    Q_PROPERTY(bool dirty READ dirty NOTIFY dirtyChanged FINAL)
    Q_PROPERTY(bool hasSettings READ hasSettings NOTIFY settingsDirtyChanged FINAL)
    Q_PROPERTY(bool settingsDirty READ settingsDirty NOTIFY settingsDirtyChanged FINAL)

public:
    explicit ManageTokensController(QObject* parent = nullptr);

    Q_INVOKABLE void showHideRegularToken(int row, bool flag);
    Q_INVOKABLE void showHideCommunityToken(int row, bool flag);
    Q_INVOKABLE void showHideGroup(const QString& groupId, bool flag);

    Q_INVOKABLE void loadSettings();
    Q_INVOKABLE void saveSettings(bool reuseCurrent = false);
    Q_INVOKABLE void clearSettings();
    Q_INVOKABLE void revert();

    Q_INVOKABLE void settingsHideToken(const QString& symbol);
    Q_INVOKABLE void settingsHideCommunityTokens(const QString& communityId, const QStringList& symbols);

    Q_INVOKABLE bool lessThan(const QString& lhsSymbol, const QString& rhsSymbol) const;
    Q_INVOKABLE bool filterAcceptsSymbol(const QString& symbol) const;

protected:
    void classBegin() override;
    void componentComplete() override;

signals:
    void sourceModelChanged();
    void dirtyChanged();
    void arrangeByCommunityChanged();
    void settingsKeyChanged();
    void settingsDirtyChanged(bool dirty);

private:
    QAbstractItemModel* m_sourceModel{nullptr};
    QAbstractItemModel* sourceModel() const { return m_sourceModel; }
    void setSourceModel(QAbstractItemModel* newSourceModel);
    void parseSourceModel();

    void addItem(int index);

    ManageTokensModel* m_regularTokensModel{nullptr};
    QAbstractItemModel* regularTokensModel() const { return m_regularTokensModel; }

    ManageTokensModel* m_communityTokensModel{nullptr};
    QAbstractItemModel* communityTokensModel() const { return m_communityTokensModel; }

    ManageTokensModel* m_communityTokenGroupsModel{nullptr};
    QAbstractItemModel* communityTokenGroupsModel() const { return m_communityTokenGroupsModel; }

    ManageTokensModel* m_hiddenTokensModel{nullptr};
    QAbstractItemModel* hiddenTokensModel() const { return m_hiddenTokensModel; }

    bool dirty() const;

    bool m_arrangeByCommunity{false};
    bool arrangeByCommunity() const;
    void setArrangeByCommunity(bool newArrangeByCommunity);

    QStringList m_communityIds;
    void reloadCommunityIds();
    void rebuildCommunityTokenGroupsModel();

    const std::array<ManageTokensModel*, 4> m_allModels {m_regularTokensModel, m_communityTokensModel, m_communityTokenGroupsModel, m_hiddenTokensModel};

    QString m_settingsKey;
    QString settingsKey() const;
    QString settingsGroupName() const;
    void setSettingsKey(const QString& newSettingsKey);
    QSettings m_settings;
    SerializedTokenData m_settingsData; // symbol -> {sortOrder, visible, groupId}
    bool hasSettings() const;

    bool m_settingsDirty{false};
    bool settingsDirty() const { return m_settingsDirty; }
    void setSettingsDirty(bool dirty);

    bool m_modelConnectionsInitialized{false};
};
