#pragma once

#include <QIdentityProxyModel>
#include <QQmlParserStatus>

struct ShellItemData;

class ShellProxyModel : public QIdentityProxyModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)

    Q_PROPERTY(QString profileId READ profileId WRITE setProfileId NOTIFY profileIdChanged REQUIRED FINAL)

public:
    enum ExtraRoles {
        TimestampRole = Qt::UserRole + 1,
        PinnedRole
    };
    Q_ENUM(ExtraRoles)

    explicit ShellProxyModel(QObject* parent = nullptr);
    ~ShellProxyModel() override;

    Q_INVOKABLE void clear();

    QVariant data(const QModelIndex& index, int role) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    void setSourceModel(QAbstractItemModel* sourceModel) override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void profileIdChanged();

protected:
    void classBegin() override;
    void componentComplete() override;

protected slots:
    void resetInternalData();

private:
    void initRoles();
    void updateRoleNames();

    void save();
    void load();

    QHash<int, QByteArray> m_roleNames;
    int m_keyRoleValue{-1};
    QHash<QString, ShellItemData> m_data; // key -> {timestamp, pinned, ...}

    QString profileId() const;
    void setProfileId(const QString &newProfileId);
    QString m_profileId;

    QString settingsGroup() const;
};
