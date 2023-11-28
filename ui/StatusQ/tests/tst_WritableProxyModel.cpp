#include <QAbstractItemModelTester>
#include <QAbstractListModel>
#include <QTest>
#include <QSignalSpy>

#include "StatusQ/writableproxymodel.h"

namespace {

class TestSourceModel : public QAbstractListModel {

public:
    explicit TestSourceModel(QList<QPair<QString, QVariantList>> data)
        : m_data(std::move(data))
    {
        m_roles.reserve(m_data.size());

        for (auto i = 0; i < m_data.size(); i++)
            m_roles.insert(i, m_data.at(i).first.toUtf8());
    }

    int rowCount(const QModelIndex &parent) const override 
    {
        if(parent.isValid()) return 0; //no children

        if(m_data.isEmpty()) return 0;

        return m_data.first().second.size();
    }

    QVariant data(const QModelIndex& index, int role) const override
    {
        if (!index.isValid() || role < 0 || role >= m_data.size())
            return {};

        const auto row = index.row();

        if (role >= m_data.length() || row >= m_data.at(0).second.length())
            return {};

        return m_data.at(role).second.at(row);
    }

    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override
    {
        if (!index.isValid() || role < 0 || role >= m_data.size())
            return false;
        
        const auto row = index.row();

        if (role >= m_data.length() || row >= m_data.at(0).second.length())
            return false;
        
        m_data[role].second[row] = value;
        emit dataChanged(index, index, { role });
        return true;
    }

    bool moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild) override
    {
        if (sourceParent.isValid() || destinationParent.isValid())
            return false;

        if (sourceRow < 0 || sourceRow + count > m_data.at(0).second.size())
            return false;

        if (destinationChild < 0 || destinationChild > m_data.at(0).second.size())
            return false;

        if (sourceRow == destinationChild)
            return true;

        if(!beginMoveRows(sourceParent, sourceRow, sourceRow, destinationParent, destinationChild))
            return false;

        for (int i = 0; i < count; i++) {
            for (int j = 0; j < m_data.size(); j++) {
                auto& roleVariantList = m_data[j].second;
                roleVariantList.move(sourceRow, destinationChild);
            }
        }

        endMoveRows();
        return true;
    }

    void insert(int index, QVariantList row)
    {
        beginInsertRows(QModelIndex{}, index, index);

        assert(row.size() == m_data.size());

        for (int i = 0; i < m_data.size(); i++) {
            auto& roleVariantList = m_data[i].second;
            assert(index <= roleVariantList.size());
            roleVariantList.insert(index, row.at(i));
        }

        endInsertRows();
    }

    void remove(int index)
    {
        beginRemoveRows(QModelIndex{}, index, index);

        for (int i = 0; i < m_data.size(); i++) {
            auto& roleVariantList = m_data[i].second;
            assert(index < roleVariantList.size());
            roleVariantList.removeAt(index);
        }

        endRemoveRows();
    }

    QHash<int, QByteArray> roleNames() const override
    {
        return m_roles;
    }

    void reset(QList<QPair<QString, QVariantList>> data = {})
    {
        beginResetModel();
        m_data = std::move(data);
        endResetModel();
    }

private:
    QList<QPair<QString, QVariantList>> m_data;
    QHash<int, QByteArray> m_roles;
};

} // anonymous namespace

class TestWritableProxyModel : public QObject
{
    Q_OBJECT
private slots:
    void initializationTest()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({});
        model.setSourceModel(&sourceModel);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.columnCount(), 1);
        QCOMPARE(model.dirty(), false);
    }

    void basicAccessTest()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });
        model.setSourceModel(&sourceModel);

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.columnCount(), 1);
        QCOMPARE(model.dirty(), false);

        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 2"));
        QCOMPARE(model.data(model.index(0, 0), 1), QVariant("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QVariant("community_2"));
        QCOMPARE(model.data(model.index(0, 1), 0), QVariant());
        QCOMPARE(model.data(model.index(1, 1), 0), QVariant());
        QCOMPARE(model.data(model.index(0, 1), 1), QVariant());
        QCOMPARE(model.data(model.index(1, 1), 1), QVariant());
    }

    void basicSourceModelDataChange()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });
        model.setSourceModel(&sourceModel);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 1"));

        QSignalSpy dataChangedSpy(&model, &WritableProxyModel::dataChanged);

        sourceModel.setData(model.index(0, 0), "Token 1.1", 0);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(dataChangedSpy.count(), 1);

        QCOMPARE(dataChangedSpy.first().at(0), model.index(0, 0));
        QCOMPARE(dataChangedSpy.first().at(1), model.index(0, 0));
        QCOMPARE(dataChangedSpy.first().at(2).value<QVector<int>>(), { 0 });

        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 1.1"));
    }

    void basicSourceModelRemove()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });
        model.setSourceModel(&sourceModel);

        QSignalSpy rowRemovedSpy(&model, &WritableProxyModel::rowsRemoved);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 2);

        sourceModel.remove(0);
        QCOMPARE(model.rowCount(), 1);
        QCOMPARE(model.dirty(), false);
        QCOMPARE(rowRemovedSpy.count(), 1);
        QCOMPARE(rowRemovedSpy.first().at(1), 0);
        QCOMPARE(rowRemovedSpy.first().at(2), 0);
    }

    void basicSourceModelInsert()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });
        model.setSourceModel(&sourceModel);

        QSignalSpy rowInsertedSpy(&model, &WritableProxyModel::rowsInserted);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 2);

        sourceModel.insert(0, { "Token 0", "community_0" });
        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.dirty(), false);
        QCOMPARE(rowInsertedSpy.count(), 1);
        QCOMPARE(rowInsertedSpy.first().at(1), 0);
        QCOMPARE(rowInsertedSpy.first().at(2), 0);
    }

    void basicSourceModelReset()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });
        model.setSourceModel(&sourceModel);

        QSignalSpy modelResetSpy(&model, &WritableProxyModel::modelReset);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 2);

        sourceModel.reset();

        QCOMPARE(model.dirty(), false);
        QCOMPARE(modelResetSpy.count(), 1);
    }

    void basicProxyDataChange()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });
        model.setSourceModel(&sourceModel);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 1"));

        QSignalSpy dataChangedSpy(&model, &WritableProxyModel::dataChanged);

        model.setData(model.index(0, 0), "Token 1.1", 0);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 1.1"));
        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), QVariant("Token 1"));
        QCOMPARE(dataChangedSpy.count(), 1);
        QCOMPARE(dataChangedSpy.first().at(0), model.index(0, 0));
        QCOMPARE(dataChangedSpy.first().at(1), model.index(0, 0));
        QCOMPARE(dataChangedSpy.first().at(2).value<QVector<int>>(), { 0 });

        model.setData(model.index(1, 0), "Token 2.1", 0);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 2.1"));
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), QVariant("Token 2"));
        QCOMPARE(dataChangedSpy.count(), 2);
        QCOMPARE(dataChangedSpy.last().at(0), model.index(1, 0));
        QCOMPARE(dataChangedSpy.last().at(1), model.index(1, 0));
        QCOMPARE(dataChangedSpy.last().at(2).value<QVector<int>>(), { 0 });

        model.setData(model.index(0, 0), "community_1.1", 1);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(0, 0), 1), QVariant("community_1.1"));
        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 1), QVariant("community_1"));
        QCOMPARE(dataChangedSpy.count(), 3);
        QCOMPARE(dataChangedSpy.last().at(0), model.index(0, 0));
        QCOMPARE(dataChangedSpy.last().at(1), model.index(0, 0));
        QCOMPARE(dataChangedSpy.last().at(2).value<QVector<int>>(), { 1 });

        model.setData(model.index(1, 0), "community_2.1", 1);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(1, 0), 1), QVariant("community_2.1"));
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 1), QVariant("community_2"));
        QCOMPARE(dataChangedSpy.count(), 4);
        QCOMPARE(dataChangedSpy.last().at(0), model.index(1, 0));
        QCOMPARE(dataChangedSpy.last().at(1), model.index(1, 0));
        QCOMPARE(dataChangedSpy.last().at(2).value<QVector<int>>(), { 1 });    

        model.setItemData(model.index(0, 0), { { 0, "Token 1.2" }, { 1, "community_1.2" } });

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 1.2"));
        QCOMPARE(model.data(model.index(0, 0), 1), QVariant("community_1.2"));
        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), QVariant("Token 1"));
        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 1), QVariant("community_1"));    
        QCOMPARE(dataChangedSpy.count(), 6);
        QCOMPARE(dataChangedSpy.last().at(0), model.index(0, 0));
        QCOMPARE(dataChangedSpy.last().at(1), model.index(0, 0));
        QCOMPARE(dataChangedSpy.last().at(2).value<QVector<int>>(), { 1 });    
    }

    void basicProxyRemove()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2", "Token 3", "Token 4", "Toke 5"}},
           { "communityId", { "community_1", "community_2", "community_3", "community_4", "community_5" }}
        });
        model.setSourceModel(&sourceModel);

        QSignalSpy rowRemovedSpy(&model, &WritableProxyModel::rowsRemoved);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 5);
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 1"));
        model.removeRows(0, 2);

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.dirty(), true);
        QCOMPARE(rowRemovedSpy.count(), 1);
        QCOMPARE(rowRemovedSpy.last().at(1), 0);
        QCOMPARE(rowRemovedSpy.last().at(2), 1);
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 3"));

        model.removeRows(0, 1);

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.dirty(), true);
        QCOMPARE(rowRemovedSpy.count(), 2);
        QCOMPARE(rowRemovedSpy.last().at(1), 0);
        QCOMPARE(rowRemovedSpy.last().at(2), 0);
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 4"));
    }

    void basicProxyInsert()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });
        model.setSourceModel(&sourceModel);

        QSignalSpy rowInsertedSpy(&model, &WritableProxyModel::rowsInserted);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 1"));

        model.insertRows(0, 1);

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.dirty(), true);
        QCOMPARE(rowInsertedSpy.count(), 1);
        QCOMPARE(rowInsertedSpy.first().at(1), 0);
        QCOMPARE(rowInsertedSpy.first().at(2), 0);
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant());

        model.setData(model.index(0, 0), "Token 0", 0);

        QCOMPARE(model.data(model.index(-1, 0), 1), QVariant());
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 0"));
        QCOMPARE(model.data(model.index(0, 0), 1), QVariant());
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QVariant("community_1"));
        QCOMPARE(model.data(model.index(2, 0), 0), QVariant("Token 2"));
        QCOMPARE(model.data(model.index(2, 0), 1), QVariant("community_2"));
        QCOMPARE(model.data(model.index(3, 0), 0), QVariant());

        model.setData(model.index(0, 0), "community_0", 1);

        QCOMPARE(model.data(model.index(-1, 0), 1), QVariant());
        QCOMPARE(model.data(model.index(0, 0), 1), QVariant("community_0"));
        QCOMPARE(model.data(model.index(1, 0), 1), QVariant("community_1"));
        QCOMPARE(model.data(model.index(2, 0), 1), QVariant("community_2"));
        QCOMPARE(model.data(model.index(3, 0), 1), QVariant());
    }

    void updatedDataChangesInSourceModel()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });
        model.setSourceModel(&sourceModel);

        QSignalSpy dataChangedSpy(&model, &WritableProxyModel::dataChanged);

        model.setData(model.index(0, 0), "Token 1.1", 0);
        sourceModel.setData(sourceModel.index(0, 0), "Token 1.2", 0);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 1.1"));
        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), QVariant("Token 1.2"));
        QCOMPARE(dataChangedSpy.count(), 1);
        QCOMPARE(dataChangedSpy.first().at(0), model.index(0, 0));
        QCOMPARE(dataChangedSpy.first().at(1), model.index(0, 0));
        QCOMPARE(dataChangedSpy.first().at(2).value<QVector<int>>(), { 0 });
    }

    void removedDataChangesInSourceModel()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });
        model.setSourceModel(&sourceModel);

        QSignalSpy dataChangedSpy(&model, &WritableProxyModel::dataChanged);

        model.removeRows(0, 1);
        sourceModel.setData(sourceModel.index(0, 0), "Token 1.2", 0);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 2"));
        QCOMPARE(dataChangedSpy.count(), 0);
    }

    void updatedDataIsKeptAfterSourceModelRemove()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });
        model.setSourceModel(&sourceModel);

        model.setData(model.index(0, 0), "Token 1.1", 0);

        QSignalSpy rowsRemovedSpy(&model, &WritableProxyModel::rowsRemoved);
        QSignalSpy modelResetSpy(&model, &WritableProxyModel::modelReset);
        QSignalSpy dataChangedSpy(&model, &WritableProxyModel::dataChanged);
        QSignalSpy rowsInsertedSpy(&model, &WritableProxyModel::rowsInserted);

        sourceModel.remove(0);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 2);

        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 1.1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 2"));
        QCOMPARE(model.data(model.index(0, 0), 1), QVariant("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QVariant("community_2"));

        QCOMPARE(rowsRemovedSpy.count(), 0);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(dataChangedSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
    }

    void updatedDataIsKeptAfterSourceModelResetToEmpty()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });
        model.setSourceModel(&sourceModel);

        model.setData(model.index(0, 0), "Token 1.1", 0);

        QSignalSpy rowsRemovedSpy(&model, &WritableProxyModel::rowsRemoved);
        QSignalSpy modelResetSpy(&model, &WritableProxyModel::modelReset);
        QSignalSpy dataChangedSpy(&model, &WritableProxyModel::dataChanged);
        QSignalSpy rowsInsertedSpy(&model, &WritableProxyModel::rowsInserted);

        sourceModel.reset();

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 1);
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 1.1"));
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant());
        QCOMPARE(model.data(model.index(0, 0), 1), QVariant("community_1"));
        QCOMPARE(model.data(model.index(1, 0), 1), QVariant());

        QCOMPARE(rowsRemovedSpy.count(), 0);
        QCOMPARE(modelResetSpy.count(), 1);
        QCOMPARE(dataChangedSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
    }

    void updatedDataIsKeptAfterSourceModelResetToNew()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });
        model.setSourceModel(&sourceModel);

        model.setData(model.index(1, 0), "Token 2.1", 0);

        QSignalSpy rowsRemovedSpy(&model, &WritableProxyModel::rowsRemoved);
        QSignalSpy modelResetSpy(&model, &WritableProxyModel::modelReset);
        QSignalSpy dataChangedSpy(&model, &WritableProxyModel::dataChanged);
        QSignalSpy rowsInsertedSpy(&model, &WritableProxyModel::rowsInserted);

        sourceModel.reset({
           { "title", { "Token 3", "Token 4" }},
           { "communityId", { "community_3", "community_4" }}
        });

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 3"));
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 2.1"));
        QCOMPARE(model.data(model.index(2, 0), 0), QVariant("Token 4"));
        QCOMPARE(model.data(model.index(3, 0), 1), QVariant());

        QCOMPARE(model.data(model.index(0, 0), 1), QVariant("community_3"));
        QCOMPARE(model.data(model.index(1, 0), 1), QVariant("community_2"));
        QCOMPARE(model.data(model.index(2, 0), 1), QVariant("community_4"));
        QCOMPARE(model.data(model.index(3, 0), 1), QVariant());

        QCOMPARE(rowsRemovedSpy.count(), 0);
        QCOMPARE(modelResetSpy.count(), 1);
        QCOMPARE(dataChangedSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
    }

    void dataIsAccessibleAfterSourceModelMove()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });
        model.setSourceModel(&sourceModel);
    
        model.setData(model.index(0, 0), "Token 1.1", 0);
        sourceModel.moveRows({}, 1, 1, {}, 0);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), QVariant("Token 2"));
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 2"));
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 1.1"));
    }

    void proxyRemovedButSourceModelIsMovingRow()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2", "Token 3" }},
           { "communityId", { "community_1", "community_2", "community_3" }}
        });
        model.setSourceModel(&sourceModel);
    
        model.removeRows(2, 1);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(2, 0), 0), QVariant());
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 2"));
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 1"));

        sourceModel.moveRows({}, 2, 1, {}, 0);

        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), QVariant("Token 3"));
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), QVariant("Token 1"));
        QCOMPARE(sourceModel.data(sourceModel.index(2, 0), 0), QVariant("Token 2"));

        QCOMPARE(model.data(model.index(2, 0), 0), QVariant());
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 2"));
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 1"));

        sourceModel.moveRows({}, 1, 1, {}, 0);

        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), QVariant("Token 1"));
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), QVariant("Token 3"));
        QCOMPARE(sourceModel.data(sourceModel.index(2, 0), 0), QVariant("Token 2"));

        QCOMPARE(model.data(model.index(2, 0), 0), QVariant());
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 2"));
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 1"));

        sourceModel.moveRows({}, 0, 1, {}, 2);

        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), QVariant("Token 3"));
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), QVariant("Token 2"));
        QCOMPARE(sourceModel.data(sourceModel.index(2, 0), 0), QVariant("Token 1"));

        QCOMPARE(model.data(model.index(2, 0), 0), QVariant());
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 1"));
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 2"));
    }

    void proxyInsertedButSourceMovesRows()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2", "Token 3" }},
           { "communityId", { "community_1", "community_2", "community_3" }}
        });
        model.setSourceModel(&sourceModel);
    
        model.insertRows(0, 1);
        model.setData(model.index(0, 0), "Token 0", 0);
        model.setData(model.index(0, 0), "community_0", 1);

        model.insertRows(4, 1);
        model.setData(model.index(4, 0), "Token 4", 0);
        model.setData(model.index(4, 0), "community_4", 1);

        model.removeRows(1, 1);

        /*
            Token 0
            Token 1 -> removed
            Token 2 
            Token 3
            Token 4
        */

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 0"));
        //QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 1")); -> removed
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 2"));
        QCOMPARE(model.data(model.index(2, 0), 0), QVariant("Token 3"));
        QCOMPARE(model.data(model.index(3, 0), 0), QVariant("Token 4"));

        sourceModel.moveRows({}, 2, 1, {}, 0);

        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), QVariant("Token 3"));
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), QVariant("Token 1"));
        QCOMPARE(sourceModel.data(sourceModel.index(2, 0), 0), QVariant("Token 2"));

        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 0"));
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 3"));
        QCOMPARE(model.data(model.index(2, 0), 0), QVariant("Token 2"));
        QCOMPARE(model.data(model.index(3, 0), 0), QVariant("Token 4"));

        sourceModel.moveRows({}, 1, 1, {}, 0);

        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), QVariant("Token 1"));
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), QVariant("Token 3"));
        QCOMPARE(sourceModel.data(sourceModel.index(2, 0), 0), QVariant("Token 2"));

        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 0"));
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 3"));
        QCOMPARE(model.data(model.index(2, 0), 0), QVariant("Token 2"));
        QCOMPARE(model.data(model.index(3, 0), 0), QVariant("Token 4"));

        sourceModel.moveRows({}, 2, 1, {}, 0);

        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), QVariant("Token 2"));
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), QVariant("Token 1"));
        QCOMPARE(sourceModel.data(sourceModel.index(2, 0), 0), QVariant("Token 3"));

        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 0"));
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 2"));
        QCOMPARE(model.data(model.index(2, 0), 0), QVariant("Token 3"));
        QCOMPARE(model.data(model.index(3, 0), 0), QVariant("Token 4"));
        QCOMPARE(model.data(model.index(4, 0), 0), QVariant());

        auto map = model.toVariantMap();

        QCOMPARE(model.data(model.index(0, 0), 0), map.value("0").value<QVariantMap>().value("0"));
        QCOMPARE(model.data(model.index(1, 0), 0), map.value("1").value<QVariantMap>().value("0"));
        QCOMPARE(model.data(model.index(2, 0), 0), map.value("2").value<QVariantMap>().value("0"));
        QCOMPARE(model.data(model.index(3, 0), 0), map.value("3").value<QVariantMap>().value("0"));
        
        QCOMPARE(model.data(model.index(0, 0), 1), map.value("0").value<QVariantMap>().value("1"));
        QCOMPARE(model.data(model.index(1, 0), 1), map.value("1").value<QVariantMap>().value("1"));
        QCOMPARE(model.data(model.index(2, 0), 1), map.value("2").value<QVariantMap>().value("1"));
        QCOMPARE(model.data(model.index(3, 0), 1), map.value("3").value<QVariantMap>().value("1"));
        
        model.revert();

        QCOMPARE(model.data(model.index(0, 0), 0), QVariant("Token 2"));
        QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 1"));
        QCOMPARE(model.data(model.index(2, 0), 0), QVariant("Token 3"));
        QCOMPARE(model.data(model.index(3, 0), 0), QVariant());
    }
};

QTEST_MAIN(TestWritableProxyModel)
#include "tst_WritableProxyModel.moc"
