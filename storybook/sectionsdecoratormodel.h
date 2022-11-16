#pragma once

#include <QAbstractListModel>
#include <optional>

class SectionsDecoratorModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel* sourceModel READ sourceModel
               WRITE setSourceModel NOTIFY sourceModelChanged)
public:
    static constexpr int IsSectionRole = Qt::UserRole + 100;
    static constexpr int IsFoldedRole = Qt::UserRole + 101;
    static constexpr int SubitemsCountRole = Qt::UserRole + 102;

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

    std::optional<int> findSectionRole() const;
    void initialize();
    void calculateOffsets();

    QAbstractItemModel* m_sourceModel = nullptr;
    std::vector<RowMetadata> m_rowsMetadata;
    int m_sectionRole = 0;
};
