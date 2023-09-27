#pragma once

#include <QAbstractListModel>

class SectionsDecoratorModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel* sourceModel READ sourceModel
               WRITE setSourceModel NOTIFY sourceModelChanged)
public:
    enum Roles {
        SectionRole = Qt::UserRole + 100,
        IsSectionRole,
        IsFoldedRole,
        SubitemsCountRole
    };

    explicit SectionsDecoratorModel(QObject *parent = nullptr);

    void setSourceModel(QAbstractItemModel *sourceModel);
    QAbstractItemModel *sourceModel() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void flipFolding(int index);

signals:
    void sourceModelChanged();

private:
    struct RowMetadata {
        bool isSection = false;
        QString sectionName;
        bool folded = false;
        int offset = 0;
        int count = 0;
    };

    void initialize();
    void calculateOffsets();

    void onInserted(const QModelIndex &parent, int first, int last);
    void onRemoved(const QModelIndex &parent, int first, int last);

    QAbstractItemModel* m_sourceModel = nullptr;
    std::vector<RowMetadata> m_rowsMetadata;
    int m_sectionRole = 0;
};
