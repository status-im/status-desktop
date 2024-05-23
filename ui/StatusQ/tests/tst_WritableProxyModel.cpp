#include <QAbstractItemModelTester>
#include <QAbstractListModel>
#include <QSignalSpy>
#include <QTest>

#include "StatusQ/snapshotmodel.h"
#include "StatusQ/writableproxymodel.h"

#include <TestHelpers/modeltestutils.h>
#include <TestHelpers/persistentindexestester.h>

namespace
{

class TestSourceModel : public QAbstractListModel
{

public:
    explicit TestSourceModel(QList<QPair<QString, QVariantList>> data)
        : m_data(std::move(data))
    {
        m_roles.reserve(m_data.size());

        for (auto i = 0; i < m_data.size(); i++)
            m_roles.insert(i, m_data.at(i).first.toUtf8());
    }

    int rowCount(const QModelIndex& parent) const override
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

    bool setData(const QModelIndex& index, const QVariant& value, int role = Qt::EditRole) override
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

    bool moveRows(const QModelIndex& sourceParent, int sourceRow, int count, const QModelIndex& destinationParent, int destinationChild) override
    {
        if (sourceParent.isValid() || destinationParent.isValid())
            return false;

        if (sourceRow < 0 || sourceRow + count > m_data.at(0).second.size())
            return false;

        if (destinationChild < 0 || destinationChild > m_data.at(0).second.size())
            return false;

        if (sourceRow == destinationChild)
            return true;

        if(!beginMoveRows(sourceParent, sourceRow, sourceRow + count - 1, destinationParent, destinationChild))
            return false;

        if (destinationChild > sourceRow) {
            destinationChild -= 1;
        }

        for (int i = 0; i < count; i++) {
            for (int j = 0; j < m_data.size(); j++) {
                auto& roleVariantList = m_data[j].second;
                roleVariantList.move(sourceRow + count - 1, destinationChild);
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

    void insertRows(int index, const QList<QPair<QString, QVariantList>>& data)
    {
        if (data.isEmpty() || data.at(0).second.isEmpty())
            return;

        Q_ASSERT(data.size() == m_data.size());

        beginInsertRows(QModelIndex{}, index, index + data.at(0).second.size() - 1);

        for (int i = 0; i < data.size(); i++) {
            auto& roleVariantList = m_data[i].second;
            for (int j = 0; j < data.at(i).second.size(); j++)
                roleVariantList.insert(index + j, data.at(i).second.at(j));
        }

        endInsertRows();
    }

    void remove(int index, int count = 1)
    {
        beginRemoveRows(QModelIndex{}, index, index + count - 1);

        for (int i = 0; i < m_data.size(); i++) {
            auto& roleVariantList = m_data[i].second;
            assert(index < roleVariantList.size());
            roleVariantList.erase(roleVariantList.begin() + index, roleVariantList.begin() + index + count);
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

        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(0, 0), 1), "community_1");
        QCOMPARE(model.data(model.index(1, 0), 1), "community_2");
        QCOMPARE(model.data(model.index(0, 1), 0), {});
        QCOMPARE(model.data(model.index(1, 1), 0), {});
        QCOMPARE(model.data(model.index(0, 1), 1), {});
        QCOMPARE(model.data(model.index(1, 1), 1), {});
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
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1");

        QSignalSpy dataChangedSpy(&model, &WritableProxyModel::dataChanged);

        sourceModel.setData(model.index(0, 0), "Token 1.1", 0);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(dataChangedSpy.count(), 1);

        QCOMPARE(dataChangedSpy.first().at(0), model.index(0, 0));
        QCOMPARE(dataChangedSpy.first().at(1), model.index(0, 0));
        QCOMPARE(dataChangedSpy.first().at(2).value<QVector<int>>(), { 0 });

        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1.1");
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
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1.1");
        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), "Token 1");
        QCOMPARE(dataChangedSpy.count(), 1);
        QCOMPARE(dataChangedSpy.first().at(0), model.index(0, 0));
        QCOMPARE(dataChangedSpy.first().at(1), model.index(0, 0));
        QCOMPARE(dataChangedSpy.first().at(2).value<QVector<int>>(), { 0 });

        model.setData(model.index(1, 0), "Token 2.1", 0);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 2.1");
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), "Token 2");
        QCOMPARE(dataChangedSpy.count(), 2);
        QCOMPARE(dataChangedSpy.last().at(0), model.index(1, 0));
        QCOMPARE(dataChangedSpy.last().at(1), model.index(1, 0));
        QCOMPARE(dataChangedSpy.last().at(2).value<QVector<int>>(), { 0 });

        model.setData(model.index(0, 0), "community_1.1", 1);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(0, 0), 1), "community_1.1");
        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 1), "community_1");
        QCOMPARE(dataChangedSpy.count(), 3);
        QCOMPARE(dataChangedSpy.last().at(0), model.index(0, 0));
        QCOMPARE(dataChangedSpy.last().at(1), model.index(0, 0));
        QCOMPARE(dataChangedSpy.last().at(2).value<QVector<int>>(), { 1 });

        model.setData(model.index(1, 0), "community_2.1", 1);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(1, 0), 1), "community_2.1");
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 1), "community_2");
        QCOMPARE(dataChangedSpy.count(), 4);
        QCOMPARE(dataChangedSpy.last().at(0), model.index(1, 0));
        QCOMPARE(dataChangedSpy.last().at(1), model.index(1, 0));
        QCOMPARE(dataChangedSpy.last().at(2).value<QVector<int>>(), { 1 });

        model.setItemData(model.index(0, 0), { { 0, "Token 1.2" }, { 1, "community_1.2" } });

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1.2");
        QCOMPARE(model.data(model.index(0, 0), 1), "community_1.2");
        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), "Token 1");
        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 1), "community_1");
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
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1");
        model.removeRows(0, 2);

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.dirty(), true);
        QCOMPARE(rowRemovedSpy.count(), 1);
        QCOMPARE(rowRemovedSpy.last().at(1), 0);
        QCOMPARE(rowRemovedSpy.last().at(2), 1);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 3");

        model.removeRows(0, 1);

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.dirty(), true);
        QCOMPARE(rowRemovedSpy.count(), 2);
        QCOMPARE(rowRemovedSpy.last().at(1), 0);
        QCOMPARE(rowRemovedSpy.last().at(2), 0);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 4");
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
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1");

        model.insertRows(0, 1);

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.dirty(), true);
        QCOMPARE(rowInsertedSpy.count(), 1);
        QCOMPARE(rowInsertedSpy.first().at(1), 0);
        QCOMPARE(rowInsertedSpy.first().at(2), 0);
        QCOMPARE(model.data(model.index(0, 0), 0), {});

        model.setData(model.index(0, 0), "Token 0", 0);

        QCOMPARE(model.data(model.index(-1, 0), 1), {});
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 0");
        QCOMPARE(model.data(model.index(0, 0), 1), {});
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 1");
        QCOMPARE(model.data(model.index(1, 0), 1), "community_1");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(2, 0), 1), "community_2");
        QCOMPARE(model.data(model.index(3, 0), 0), {});

        model.setData(model.index(0, 0), "community_0", 1);

        QCOMPARE(model.data(model.index(-1, 0), 1), {});
        QCOMPARE(model.data(model.index(0, 0), 1), "community_0");
        QCOMPARE(model.data(model.index(1, 0), 1), "community_1");
        QCOMPARE(model.data(model.index(2, 0), 1), "community_2");
        QCOMPARE(model.data(model.index(3, 0), 1), {});

        model.insert(0, {{ "title", "Token -1"}, {"communityId", "community_-1" }});

        QCOMPARE(model.rowCount(), 4);
        QCOMPARE(model.data(model.index(-1, 0), 1), {});
        QCOMPARE(model.data(model.index(0, 0), 0), "Token -1");
        QCOMPARE(model.data(model.index(0, 0), 1), "community_-1");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 0");
        QCOMPARE(model.data(model.index(1, 0), 1), "community_0");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 1");
        QCOMPARE(model.data(model.index(2, 0), 1), "community_1");
        QCOMPARE(model.data(model.index(3, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(3, 0), 1), "community_2");
        QCOMPARE(model.data(model.index(4, 0), 0), {});

        QCOMPARE(model.dirty(), true);
        QCOMPARE(rowInsertedSpy.count(), 2);
        QCOMPARE(rowInsertedSpy.last().at(1), 0);
        QCOMPARE(rowInsertedSpy.last().at(2), 0);

        model.insert(4, {{ "title", "Token -4"}, {"communityId", "community_-4" }});

        QCOMPARE(model.rowCount(), 5);
        QCOMPARE(model.data(model.index(-1, 0), 1), {});
        QCOMPARE(model.data(model.index(0, 0), 0), "Token -1");
        QCOMPARE(model.data(model.index(0, 0), 1), "community_-1");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 0");
        QCOMPARE(model.data(model.index(1, 0), 1), "community_0");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 1");
        QCOMPARE(model.data(model.index(2, 0), 1), "community_1");
        QCOMPARE(model.data(model.index(3, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(3, 0), 1), "community_2");
        QCOMPARE(model.data(model.index(4, 0), 0), "Token -4");
        QCOMPARE(model.data(model.index(4, 0), 1), "community_-4");

        QCOMPARE(model.dirty(), true);
        QCOMPARE(rowInsertedSpy.count(), 3);
        QCOMPARE(rowInsertedSpy.last().at(1), 4);
        QCOMPARE(rowInsertedSpy.last().at(2), 4);

        model.insert(6, {{ "title", "Token -5"}, {"communityId", "community_-5" }});

        QCOMPARE(model.rowCount(), 5);
        QCOMPARE(model.dirty(), true);
        QCOMPARE(rowInsertedSpy.count(), 3);
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

        sourceModel.setData(sourceModel.index(0, 0), "Token 1.1", 0);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 2);

        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1.1");
        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), "Token 1.1");
        QCOMPARE(dataChangedSpy.count(), 1);
        QCOMPARE(dataChangedSpy.first().at(0), model.index(0, 0));
        QCOMPARE(dataChangedSpy.first().at(1), model.index(0, 0));

        model.setData(model.index(0, 0), "Token 1.2", 0);
        
        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1.2");
        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), "Token 1.1");
        QCOMPARE(dataChangedSpy.count(), 2);

        sourceModel.setData(sourceModel.index(0, 0), "Token 1.3", 0);

        //updated role does not change on source model change
        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1.2");
        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), "Token 1.3");
        QCOMPARE(dataChangedSpy.count(), 2);

        sourceModel.setData(sourceModel.index(0, 0), "community_1.1", 1);
        
        //other roles can change
        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(0, 0), 1), "community_1.1");
        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 1), "community_1.1");
        QCOMPARE(dataChangedSpy.count(), 3);

        // source model matches proxy model
        sourceModel.setData(sourceModel.index(0, 0), "Token 1.2", 0);
        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1.2");
        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), "Token 1.2");
        QCOMPARE(dataChangedSpy.count(), 3);
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
        QSignalSpy rowsRemovedSpy(&model, &WritableProxyModel::rowsRemoved);

        model.removeRows(0, 1);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 1);
        QCOMPARE(rowsRemovedSpy.count(), 1);

        sourceModel.setData(sourceModel.index(0, 0), "Token 1.2", 0);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 2");
        QCOMPARE(dataChangedSpy.count(), 0);
        QCOMPARE(rowsRemovedSpy.count(), 1);

        // source model matches proxy
        sourceModel.remove(0);
        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 1);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 2");
        QCOMPARE(dataChangedSpy.count(), 0);
        QCOMPARE(rowsRemovedSpy.count(), 1);
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

        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1.1");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(0, 0), 1), "community_1");
        QCOMPARE(model.data(model.index(1, 0), 1), "community_2");

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
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1.1");
        QCOMPARE(model.data(model.index(1, 0), 0), {});
        QCOMPARE(model.data(model.index(0, 0), 1), "community_1");
        QCOMPARE(model.data(model.index(1, 0), 1), {});

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

        QSignalSpy rowsRemovedSpy(&model, &WritableProxyModel::rowsRemoved);
        QSignalSpy modelResetSpy(&model, &WritableProxyModel::modelReset);
        QSignalSpy dataChangedSpy(&model, &WritableProxyModel::dataChanged);
        QSignalSpy rowsInsertedSpy(&model, &WritableProxyModel::rowsInserted);

        model.setData(model.index(1, 0), "Token 2.1", 0);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 2.1");
        QCOMPARE(model.data(model.index(0, 0), 1), "community_1");
        QCOMPARE(model.data(model.index(1, 0), 1), "community_2");

        QCOMPARE(rowsRemovedSpy.count(), 0);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(dataChangedSpy.count(), 1);
        QCOMPARE(rowsInsertedSpy.count(), 0);

        sourceModel.reset({
           { "title", { "Token 3", "Token 4" }},
           { "communityId", { "community_3", "community_4" }}
        });

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 3);

        QCOMPARE(rowsRemovedSpy.count(), 0);
        QCOMPARE(modelResetSpy.count(), 1);
        QCOMPARE(dataChangedSpy.count(), 1);
        QCOMPARE(rowsInsertedSpy.count(), 0);

        QCOMPARE(model.data(model.index(0, 0), 0), "Token 2.1");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 3");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 4");
        QCOMPARE(model.data(model.index(3, 0), 1), {});

        QCOMPARE(model.data(model.index(0, 0), 1), "community_2");
        QCOMPARE(model.data(model.index(1, 0), 1), "community_3");
        QCOMPARE(model.data(model.index(2, 0), 1), "community_4");
        QCOMPARE(model.data(model.index(3, 0), 1), {});

        sourceModel.reset({});

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 1);

        QCOMPARE(model.data(model.index(0, 0), 0), "Token 2.1");
        QCOMPARE(model.data(model.index(0, 0), 1), "community_2");

        QCOMPARE(rowsRemovedSpy.count(), 0);
        QCOMPARE(modelResetSpy.count(), 2);
        QCOMPARE(dataChangedSpy.count(), 1);
        QCOMPARE(rowsInsertedSpy.count(), 0);


        sourceModel.reset({
           { "id", { "community_5", "community_6" }},
           { "name", { "Token 5", "Token 6" }}
        });

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 3);

        QCOMPARE(model.data(model.index(0, 0), 0), "Token 2.1");
        QCOMPARE(model.data(model.index(1, 0), 0), "community_5");
        QCOMPARE(model.data(model.index(2, 0), 0), "community_6");
        QCOMPARE(model.data(model.index(3, 0), 1), {});
    }

    void updaedDataIsNotKeptAfterSourceRemove()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2", "Token3" }},
           { "communityId", { "community_1", "community_2", "community_3" }}});

        model.setSourceModel(&sourceModel);
        model.setProperty("syncedRemovals", true);

        QSignalSpy rowsRemovedSpy(&model, &WritableProxyModel::rowsRemoved);
        QSignalSpy modelResetSpy(&model, &WritableProxyModel::modelReset);
        QSignalSpy dataChangedSpy(&model, &WritableProxyModel::dataChanged);
        QSignalSpy rowsInsertedSpy(&model, &WritableProxyModel::rowsInserted);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.syncedRemovals(), true);

        model.setData(model.index(0, 0), "Token 1.1", 0);
        
        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 3);

        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1.1");
        QCOMPARE(dataChangedSpy.count(), 1);

        sourceModel.remove(0);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 2");

        QCOMPARE(rowsRemovedSpy.count(), 1);
        QCOMPARE(rowsRemovedSpy.first().at(1), 0);
        QCOMPARE(rowsRemovedSpy.first().at(2), 0);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);

        model.setData(model.index(0, 0), "Token 2.1", 0);

        QCOMPARE(model.dirty(), true);

        QCOMPARE(model.data(model.index(0, 0), 0), "Token 2.1");

        sourceModel.reset({
           { "title", { "Token 3", "Token 4" }},
           { "communityId", { "community_3", "community_4" }}
        });

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 2);

        QCOMPARE(rowsRemovedSpy.count(), 1);
        QCOMPARE(modelResetSpy.count(), 1);
        QCOMPARE(dataChangedSpy.count(), 2);
        QCOMPARE(rowsInsertedSpy.count(), 0);
    }

    void dataIsAccessibleAfterSourceModelMove()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        // register types to avoid warnings regarding signal params
        qRegisterMetaType<QList<QPersistentModelIndex>>();
        qRegisterMetaType<QAbstractItemModel::LayoutChangeHint>();

        QSignalSpy rowsRemovedSpy(&model, &WritableProxyModel::rowsRemoved);
        QSignalSpy modelResetSpy(&model, &WritableProxyModel::modelReset);
        QSignalSpy dataChangedSpy(&model, &WritableProxyModel::dataChanged);
        QSignalSpy rowsInsertedSpy(&model, &WritableProxyModel::rowsInserted);

        QSignalSpy layoutChangedSpy(&model, &WritableProxyModel::layoutChanged);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2" }},
           { "communityId", { "community_1", "community_2" }}
        });
        model.setSourceModel(&sourceModel);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(rowsRemovedSpy.count(), 0);
        QCOMPARE(modelResetSpy.count(), 1);
        QCOMPARE(dataChangedSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
        QCOMPARE(layoutChangedSpy.count(), 0);

        model.setData(model.index(0, 0), "Token 1.1", 0);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 2);
        
        QCOMPARE(rowsRemovedSpy.count(), 0);
        QCOMPARE(modelResetSpy.count(), 1);
        QCOMPARE(dataChangedSpy.count(), 1);
        QCOMPARE(rowsInsertedSpy.count(), 0);
        QCOMPARE(layoutChangedSpy.count(), 0);

        PersistentIndexesTester indexesTester(&model);

        {
            SnapshotModel snapshot(model);

            QObject context;
            connect(&model, &WritableProxyModel::layoutAboutToBeChanged, &context,
                    [&snapshot, &model] {
                QVERIFY(isSame(snapshot, model));
            });

            sourceModel.moveRows({}, 1, 1, {}, 0);
        }

        QVERIFY(indexesTester.compare());

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 2);

        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), "Token 2");
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), "Token 1");

        QCOMPARE(model.data(model.index(0, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 1.1");

        QCOMPARE(rowsRemovedSpy.count(), 0);
        QCOMPARE(modelResetSpy.count(), 1);
        QCOMPARE(dataChangedSpy.count(), 1);
        QCOMPARE(rowsInsertedSpy.count(), 0);
        QCOMPARE(layoutChangedSpy.count(), 1);
    }

    void dataIsAccessibleAfterSourceModelMove2()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2", "Token 3", "Token 4" }},
           { "communityId", { "community_1", "community_2", "community_3", "community_4" }}
        });
        model.setSourceModel(&sourceModel);

        model.setData(model.index(0, 0), "Token 1.1", 0);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1.1");

        model.insert(2);
        model.setData(model.index(2, 0), "Token 5.1", 0);
        model.setData(model.index(2, 0), "community_5.1", 1);

        PersistentIndexesTester indexesTester(&model);
        bool success = sourceModel.moveRows({}, 1, 2, {}, 0);

        QVERIFY(success);
        QVERIFY(indexesTester.compare());

        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), "Token 2");
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), "Token 3");
        QCOMPARE(sourceModel.data(sourceModel.index(2, 0), 0), "Token 1");
        QCOMPARE(sourceModel.data(sourceModel.index(3, 0), 0), "Token 4");

        QCOMPARE(model.data(model.index(0, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 3");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 5.1");
        QCOMPARE(model.data(model.index(3, 0), 0), "Token 1.1");
        QCOMPARE(model.data(model.index(4, 0), 0), "Token 4");


        QCOMPARE(model.rowCount(), 5);
        QCOMPARE(model.dirty(), true);
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
        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.data(model.index(2, 0), 0), {});
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1");

        PersistentIndexesTester indexesTester(&model);
        PersistentIndexesTester sourceIndexesTester(&sourceModel);

        QVERIFY(sourceModel.moveRows({}, 2, 1, {}, 0));
        QVERIFY(sourceIndexesTester.compare());
        QVERIFY(indexesTester.compare());
        QCOMPARE(model.rowCount(), 2);

        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), "Token 3");
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), "Token 1");
        QCOMPARE(sourceModel.data(sourceModel.index(2, 0), 0), "Token 2");

        QCOMPARE(model.data(model.index(2, 0), 0), {});
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1");

        QVERIFY(sourceModel.moveRows({}, 1, 1, {}, 0));
        QVERIFY(sourceIndexesTester.compare());
        QVERIFY(indexesTester.compare());
        QCOMPARE(model.rowCount(), 2);

        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), "Token 1");
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), "Token 3");
        QCOMPARE(sourceModel.data(sourceModel.index(2, 0), 0), "Token 2");

        QCOMPARE(model.data(model.index(2, 0), 0), {});
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1");

        indexesTester.storeIndexesAndData();
        sourceIndexesTester.storeIndexesAndData();
        QVERIFY(sourceModel.moveRows({}, 0, 1, {}, 3));
        QVERIFY(sourceIndexesTester.compare());
        QVERIFY(indexesTester.compare());
        QCOMPARE(model.rowCount(), 2);

       QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), "Token 3");
       QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), "Token 2");
       QCOMPARE(sourceModel.data(sourceModel.index(2, 0), 0), "Token 1");

       QCOMPARE(model.data(model.index(2, 0), 0), {});
       QCOMPARE(model.data(model.index(1, 0), 0), "Token 1");
       QCOMPARE(model.data(model.index(0, 0), 0), "Token 2");
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
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 0");
        //QCOMPARE(model.data(model.index(1, 0), 0), QVariant("Token 1")); -> removed
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 3");
        QCOMPARE(model.data(model.index(3, 0), 0), "Token 4");

        sourceModel.moveRows({}, 2, 1, {}, 0);

        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), "Token 3");
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), "Token 1");
        QCOMPARE(sourceModel.data(sourceModel.index(2, 0), 0), "Token 2");

        QCOMPARE(model.data(model.index(0, 0), 0), "Token 0");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 3");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(3, 0), 0), "Token 4");

        sourceModel.moveRows({}, 1, 1, {}, 0);

        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), "Token 1");
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), "Token 3");
        QCOMPARE(sourceModel.data(sourceModel.index(2, 0), 0), "Token 2");

        QCOMPARE(model.data(model.index(0, 0), 0), "Token 0");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 3");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(3, 0), 0), "Token 4");

        sourceModel.moveRows({}, 2, 1, {}, 0);

        QCOMPARE(sourceModel.data(sourceModel.index(0, 0), 0), "Token 2");
        QCOMPARE(sourceModel.data(sourceModel.index(1, 0), 0), "Token 1");
        QCOMPARE(sourceModel.data(sourceModel.index(2, 0), 0), "Token 3");

        QCOMPARE(model.data(model.index(0, 0), 0), "Token 0");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 3");
        QCOMPARE(model.data(model.index(3, 0), 0), "Token 4");
        QCOMPARE(model.data(model.index(4, 0), 0), {});

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

        QCOMPARE(model.data(model.index(0, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 1");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 3");
        QCOMPARE(model.data(model.index(3, 0), 0), {});
    }

    void proxyAndSourceInserts()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "title", { "Token 1", "Token 2", "Token 3", "Token 4"}},
           { "communityId", { "community_1", "community_2", "community_3", "community_4"}}
        });
        model.setSourceModel(&sourceModel);

        model.insertRows(4, 1);
        model.setData(model.index(4, 0), "Token inserted 1", 0);
        model.setData(model.index(4, 0), "community_inserted_1", 1);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 5);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 3");
        QCOMPARE(model.data(model.index(3, 0), 0), "Token 4");
        QCOMPARE(model.data(model.index(4, 0), 0), "Token inserted 1");

        sourceModel.insert(1, {"Token 0", "community_0"});

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 6);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 0");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(3, 0), 0), "Token 3");
        QCOMPARE(model.data(model.index(4, 0), 0), "Token 4");
        QCOMPARE(model.data(model.index(5, 0), 0), "Token inserted 1");

        model.insertRows(6, 1);
        model.setData(model.index(6, 0), "Token inserted 2", 0);
        model.setData(model.index(6, 0), "community_inserted_2", 1);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 7);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 0");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(3, 0), 0), "Token 3");
        QCOMPARE(model.data(model.index(4, 0), 0), "Token 4");
        QCOMPARE(model.data(model.index(5, 0), 0), "Token inserted 1");
        QCOMPARE(model.data(model.index(6, 0), 0), "Token inserted 2");

        // Insert out of bounds
        model.insertRows(8, 1);
        model.setData(model.index(8, 0), "Token inserted 3", 0);
        model.setData(model.index(8, 0), "community_inserted_3", 1);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 7);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 0");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(3, 0), 0), "Token 3");
        QCOMPARE(model.data(model.index(4, 0), 0), "Token 4");
        QCOMPARE(model.data(model.index(5, 0), 0), "Token inserted 1");
        QCOMPARE(model.data(model.index(6, 0), 0), "Token inserted 2");

        model.insertRows(-1, 1);
        model.setData(model.index(-1, 0), "Token inserted 4", 0);
        model.setData(model.index(-1, 0), "community_inserted_4", 1);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 7);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 0");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(3, 0), 0), "Token 3");
        QCOMPARE(model.data(model.index(4, 0), 0), "Token 4");
        QCOMPARE(model.data(model.index(5, 0), 0), "Token inserted 1");
        QCOMPARE(model.data(model.index(6, 0), 0), "Token inserted 2");

        // source model matches proxy model
        sourceModel.insertRows(5, {
           { "title", { "Token inserted 1", "Token inserted 2"}},
           { "communityId", { "community_inserted_1", "community_inserted_2"}}
        });

        QCOMPARE(sourceModel.data(sourceModel.index(4, 0), 0), "Token 4");
        QCOMPARE(sourceModel.data(sourceModel.index(5, 0), 0), "Token inserted 1");
        QCOMPARE(sourceModel.data(sourceModel.index(5, 0), 1), "community_inserted_1");
        QCOMPARE(sourceModel.data(sourceModel.index(6, 0), 0), "Token inserted 2");
        QCOMPARE(sourceModel.data(sourceModel.index(6, 0), 1), "community_inserted_2");
         
        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 7);

        sourceModel.insertRows(2, {
           { "title", { "Token 0.1", "Token 0.2"}},
           { "communityId", { "community_0.1", "community_0.2"}}
        });

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(model.data(model.index(0, 0), 0), "Token 1");
        QCOMPARE(model.data(model.index(1, 0), 0), "Token 0");
        QCOMPARE(model.data(model.index(2, 0), 0), "Token 0.1");
        QCOMPARE(model.data(model.index(2, 0), 1), "community_0.1");
        QCOMPARE(model.data(model.index(3, 0), 0), "Token 0.2");
        QCOMPARE(model.data(model.index(3, 0), 1), "community_0.2");
        QCOMPARE(model.data(model.index(4, 0), 0), "Token 2");
        QCOMPARE(model.data(model.index(5, 0), 0), "Token 3");
        QCOMPARE(model.data(model.index(6, 0), 0), "Token 4");
        QCOMPARE(model.data(model.index(7, 0), 0), "Token inserted 1");
        QCOMPARE(model.data(model.index(8, 0), 0), "Token inserted 2");
    }

    void sourceModelRemovesAll()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "id", { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}},
           { "title", { "Token 1", "Token 2", "Token 3", "Token 4", "Token 5", "Token 6", "Token 7", "Token 8", "Token 9", "Token 10" }},
           { "communityId", { "community_1", "community_2", "community_3", "community_4", "community_5", "community_6", "community_7", "community_8", "community_9", "community_10" }}
        });
        model.setSourceModel(&sourceModel);

        QSignalSpy rowsRemovedSpy(&model, &WritableProxyModel::rowsRemoved);
        QSignalSpy modelResetSpy(&model, &WritableProxyModel::modelReset);
        QSignalSpy dataChangedSpy(&model, &WritableProxyModel::dataChanged);
        QSignalSpy rowsInsertedSpy(&model, &WritableProxyModel::rowsInserted);

        sourceModel.remove(0, 10);

        QCOMPARE(sourceModel.rowCount({}), 0);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 0);

        QCOMPARE(rowsRemovedSpy.count(), 1);
        QCOMPARE(rowsRemovedSpy.first().at(1), 0);
        QCOMPARE(rowsRemovedSpy.first().at(2), 9);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(dataChangedSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
    }

    void proxyInsertButSourceRemovesAll()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "id", { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}},
           { "title", { "Token 1", "Token 2", "Token 3", "Token 4", "Token 5", "Token 6", "Token 7", "Token 8", "Token 9", "Token 10" }},
           { "communityId", { "community_1", "community_2", "community_3", "community_4", "community_5", "community_6", "community_7", "community_8", "community_9", "community_10" }}
        });
        model.setSourceModel(&sourceModel);

        QSignalSpy rowsRemovedSpy(&model, &WritableProxyModel::rowsRemoved);
        QSignalSpy modelResetSpy(&model, &WritableProxyModel::modelReset);
        QSignalSpy dataChangedSpy(&model, &WritableProxyModel::dataChanged);
        QSignalSpy rowsInsertedSpy(&model, &WritableProxyModel::rowsInserted);

        model.insertRows(10, 1);
        model.setData(model.index(10, 0), "0", 0);
        model.setData(model.index(10, 0), "Token 0", 1);
        model.setData(model.index(10, 0), "community_0", 2);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 11);

        QCOMPARE(rowsRemovedSpy.count(), 0);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(dataChangedSpy.count(), 3);
        QCOMPARE(rowsInsertedSpy.count(), 1);


        sourceModel.remove(0, 10);
        QCOMPARE(model.data(model.index(0, 0), 0), "0");
        QCOMPARE(model.data(model.index(0, 0), 1), "Token 0");
        QCOMPARE(model.data(model.index(0, 0), 2), "community_0");

        QCOMPARE(sourceModel.rowCount({}), 0);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 1);

        QCOMPARE(rowsRemovedSpy.count(), 1);
        QCOMPARE(rowsRemovedSpy.first().at(1), 0);
        QCOMPARE(rowsRemovedSpy.first().at(2), 9);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(dataChangedSpy.count(), 3);
        QCOMPARE(rowsInsertedSpy.count(), 1);

        model.revert();

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 0);

        QCOMPARE(rowsRemovedSpy.count(), 1);
        QCOMPARE(modelResetSpy.count(), 1);
        QCOMPARE(dataChangedSpy.count(), 3);
        QCOMPARE(rowsInsertedSpy.count(), 1);
    }

    void proxyUpdateButSourceRemovesAll()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "id", { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}},
           { "title", { "Token 1", "Token 2", "Token 3", "Token 4", "Token 5", "Token 6", "Token 7", "Token 8", "Token 9", "Token 10" }},
           { "communityId", { "community_1", "community_2", "community_3", "community_4", "community_5", "community_6", "community_7", "community_8", "community_9", "community_10" }}
        });
        model.setSourceModel(&sourceModel);

        QSignalSpy rowsRemovedSpy(&model, &WritableProxyModel::rowsRemoved);
        QSignalSpy modelResetSpy(&model, &WritableProxyModel::modelReset);
        QSignalSpy dataChangedSpy(&model, &WritableProxyModel::dataChanged);
        QSignalSpy rowsInsertedSpy(&model, &WritableProxyModel::rowsInserted);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 10);

        model.setData(model.index(9, 0), "0", 0);
        model.setData(model.index(9, 0), "Token 0", 1);
        model.setData(model.index(9, 0), "community_0", 2);

        QCOMPARE(model.data(model.index(9, 0), 0), "0");
        QCOMPARE(model.data(model.index(9, 0), 1), "Token 0");
        QCOMPARE(model.data(model.index(9, 0), 2), "community_0");
        QCOMPARE(model.data(model.index(8, 0), 0), "9");
        QCOMPARE(model.data(model.index(8, 0), 1), "Token 9");
        QCOMPARE(model.data(model.index(8, 0), 2), "community_9");

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 10);

        QCOMPARE(rowsRemovedSpy.count(), 0);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(dataChangedSpy.count(), 3);
        QCOMPARE(rowsInsertedSpy.count(), 0);

        sourceModel.remove(0, 10);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 1);
        QCOMPARE(sourceModel.rowCount({}), 0);


        QCOMPARE(model.data(model.index(0, 0), 0), "0");
        QCOMPARE(model.data(model.index(0, 0), 1), "Token 0");
        QCOMPARE(model.data(model.index(0, 0), 2), "community_0");

        QCOMPARE(rowsRemovedSpy.count(), 1);
        QCOMPARE(rowsRemovedSpy.first().at(1), 0);
        QCOMPARE(rowsRemovedSpy.first().at(2), 8);
    }

    void proxyRemoveButSourceRemovesAll()
    {
        WritableProxyModel model;
        QAbstractItemModelTester tester(&model);

        TestSourceModel sourceModel({
           { "id", { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}},
           { "title", { "Token 1", "Token 2", "Token 3", "Token 4", "Token 5", "Token 6", "Token 7", "Token 8", "Token 9", "Token 10" }},
           { "communityId", { "community_1", "community_2", "community_3", "community_4", "community_5", "community_6", "community_7", "community_8", "community_9", "community_10" }}
        });
        model.setSourceModel(&sourceModel);

        QSignalSpy rowsRemovedSpy(&model, &WritableProxyModel::rowsRemoved);
        QSignalSpy modelResetSpy(&model, &WritableProxyModel::modelReset);
        QSignalSpy dataChangedSpy(&model, &WritableProxyModel::dataChanged);
        QSignalSpy rowsInsertedSpy(&model, &WritableProxyModel::rowsInserted);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 10);

        //remove last
        model.removeRows(9, 1);

        QCOMPARE(model.dirty(), true);
        QCOMPARE(model.rowCount(), 9);

        QCOMPARE(rowsRemovedSpy.count(), 1);
        QCOMPARE(rowsRemovedSpy.first().at(1), 9);
        QCOMPARE(rowsRemovedSpy.first().at(2), 9);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(dataChangedSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);

        sourceModel.remove(0, 10);

        QCOMPARE(model.dirty(), false);
        QCOMPARE(model.rowCount(), 0);

        QCOMPARE(rowsRemovedSpy.count(), 2);
        QCOMPARE(rowsRemovedSpy.last().at(1), 0);
        QCOMPARE(rowsRemovedSpy.last().at(2), 8);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(dataChangedSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
    }

    void proxyOperationsAfterSourceDelete()
    {
        WritableProxyModel *model = new WritableProxyModel;
        QAbstractItemModelTester tester(model);

        TestSourceModel* sourceModel = new TestSourceModel({
           { "id", { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}},
           { "title", { "Token 1", "Token 2", "Token 3", "Token 4", "Token 5", "Token 6", "Token 7", "Token 8", "Token 9", "Token 10" }},
           { "communityId", { "community_1", "community_2", "community_3", "community_4", "community_5", "community_6", "community_7", "community_8", "community_9", "community_10" }}
        });

        model->setSourceModel(sourceModel);

        QSignalSpy rowsRemovedSpy(model, &WritableProxyModel::rowsRemoved);
        QSignalSpy modelResetSpy(model, &WritableProxyModel::modelReset);
        QSignalSpy dataChangedSpy(model, &WritableProxyModel::dataChanged);
        QSignalSpy rowsInsertedSpy(model, &WritableProxyModel::rowsInserted);

        QCOMPARE(model->dirty(), false);
        QCOMPARE(model->rowCount(), 10);


        QCOMPARE(model->setData(model->index(9, 0), "0", 0), true);
        QCOMPARE(model->setData(model->index(9, 0), "Token 0", 1), true);
        QCOMPARE(model->setData(model->index(9, 0), "community_0", 2), true);

        QCOMPARE(model->data(model->index(9, 0), 0), "0");
        QCOMPARE(model->data(model->index(9, 0), 1), "Token 0");
        QCOMPARE(model->data(model->index(9, 0), 2), "community_0");
        QCOMPARE(model->data(model->index(8, 0), 0), "9");
        QCOMPARE(model->data(model->index(8, 0), 1), "Token 9");
        QCOMPARE(model->data(model->index(8, 0), 2), "community_9");

        QCOMPARE(model->dirty(), true);
        QCOMPARE(model->rowCount(), 10);

        QCOMPARE(rowsRemovedSpy.count(), 0);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(dataChangedSpy.count(), 3);
        QCOMPARE(rowsInsertedSpy.count(), 0);

        QCOMPARE(model->insertRows(10, 1), true);
        QCOMPARE(model->setData(model->index(10, 0), "0.1", 0), true);
        QCOMPARE(model->setData(model->index(10, 0), "Token 0.1", 1), true);
        QCOMPARE(model->setData(model->index(10, 0), "community_0.1", 2), true);

        QCOMPARE(model->dirty(), true);
        QCOMPARE(model->rowCount(), 11);

        QCOMPARE(rowsRemovedSpy.count(), 0);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(dataChangedSpy.count(), 6);
        QCOMPARE(rowsInsertedSpy.count(), 1);

        delete sourceModel;

        QCOMPARE(model->dirty(), true);
        QCOMPARE(model->rowCount(), 0);

        QCOMPARE(rowsRemovedSpy.count(), 0);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(dataChangedSpy.count(), 6);
        QCOMPARE(rowsInsertedSpy.count(), 1);

        QCOMPARE(model->data(model->index(0, 0), 0), {});
        QCOMPARE(model->data(model->index(0, 0), 1), {});
        QCOMPARE(model->data(model->index(0, 0), 2), {});

        QCOMPARE(model->setData(model->index(0, 0), "0.2", 0), false);
        QCOMPARE(model->setData(model->index(0, 0), "Token 0.2", 1), false);
        QCOMPARE(model->setData(model->index(0, 0), "community_0.2", 2), false);

        QCOMPARE(model->dirty(), true);
        QCOMPARE(model->rowCount(), 0);
        QCOMPARE(model->data(model->index(0, 0), 0), {});
        QCOMPARE(model->data(model->index(0, 0), 1), {});
        QCOMPARE(model->data(model->index(0, 0), 2), {});

        QCOMPARE(rowsRemovedSpy.count(), 0);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(dataChangedSpy.count(), 6);
        QCOMPARE(rowsInsertedSpy.count(), 1);

        QCOMPARE(model->insertRows(0, 1), false);
        QCOMPARE(model->setData(model->index(0, 0), "0.2", 0), false);
        QCOMPARE(model->setData(model->index(0, 0), "Token 0.2", 1), false);
        QCOMPARE(model->setData(model->index(0, 0), "community_0.2", 2), false);

        QCOMPARE(model->dirty(), true);
        QCOMPARE(model->rowCount(), 0);
        QCOMPARE(model->data(model->index(0, 0), 0), {});
        QCOMPARE(model->data(model->index(0, 0), 1), {});
        QCOMPARE(model->data(model->index(0, 0), 2), {});

        delete model;
    }
};

QTEST_MAIN(TestWritableProxyModel)
#include "tst_WritableProxyModel.moc"
