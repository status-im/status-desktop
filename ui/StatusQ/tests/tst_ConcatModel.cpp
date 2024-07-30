#include <QIdentityProxyModel>
#include <QJsonArray>
#include <QJsonObject>
#include <QQmlEngine>
#include <QSignalSpy>
#include <QTest>

#include <memory>
#include <set>

#include <StatusQ/concatmodel.h>
#include <TestHelpers/listmodelwrapper.h>
#include <TestHelpers/modelsignalsspy.h>
#include <TestHelpers/persistentindexestester.h>
#include <TestHelpers/testmodel.h>

#include <qqmlsortfilterproxymodel.h>
#include <filters/valuefilter.h>

namespace {
// Workaround for https://bugreports.qt.io/browse/QTBUG-57971 (ListModel doesn't
// emit modelReset when role names are initially set, therefore QIdentityProxyModel
// doesn't update role names appropriately)
class IdentityModel : public QIdentityProxyModel {
public:
    QHash<int,QByteArray>  roleNames() const override {
        if (sourceModel())
            return sourceModel()->roleNames();
        return {};
    }
};

} // unnamed namespace

class TestConcatModel: public QObject
{
    Q_OBJECT

    int roleForName(const QHash<int, QByteArray>& roles, const QByteArray& name) const
    {
        auto keys = roles.keys(name);

        if (keys.empty())
            return -1;

        return keys.first();
    }

private slots:
    void initializationTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "balance", 11 }, { "name", "n1" }},
            QJsonObject {{ "key", 2},{ "balance", 12 }, { "name", "n2" }},
            QJsonObject {{ "key", 3},{ "balance", 13}, { "name", "n3" }},
        });

        ListModelWrapper sourceModel2(engine, QJsonArray {});

        ListModelWrapper sourceModel3(engine, QJsonArray {
            QJsonObject {{ "balance", 14 }, { "name", "n4" }, { "color", "red"}},
            QJsonObject {{ "balance", 15 }, { "name", "n5" }, { "color", "green"}},
            QJsonObject {{ "balance", 16 }, { "name", "n6" }, { "color", "blue"}},
            QJsonObject {{ "balance", 17 }, { "name", "n7" }, { "color", "pink"}},
        });

        ListModelWrapper sourceModel4(engine, QJsonArray {});

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1;
        source1.setModel(sourceModel1);

        SourceModel source2;
        source2.setModel(sourceModel2);

        SourceModel source3;
        source3.setModel(sourceModel3);

        SourceModel source4;
        source4.setModel(sourceModel4);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);
        sources.append(&sources, &source4);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        auto roles = model.roleNames();

        QCOMPARE(model.rowCount(), 7);
        QCOMPARE(roles.size(), 5);

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 1);
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 2);
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "key")), 3);
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "key")), {});
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "key")), {});
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "key")), {});
        QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "key")), {});

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "balance")), 11);
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "balance")), 12);
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "balance")), 13);
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "balance")), 14);
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "balance")), 15);
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "balance")), 16);
        QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "balance")), 17);

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "name")), "n1");
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "name")), "n2");
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "name")), "n3");
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "name")), "n4");
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "name")), "n5");
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "name")), "n6");
        QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "name")), "n7");

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "color")), {});
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "color")), {});
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "color")), {});
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "color")), "red");
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "color")), "green");
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "color")), "blue");
        QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "color")), "pink");

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "whichModel")), "");

        // out of bounds
        QCOMPARE(model.index(-1, 0).isValid(), false);
        QCOMPARE(model.index(7, 0).isValid(), false);

        auto roleKeys = roles.keys();
        auto roleOutOfRange = *std::max_element(roleKeys.begin(),
                                                roleKeys.end()) + 1;
        QCOMPARE(model.data(model.index(0, 0), roleOutOfRange), {});

        // getting source model and source model row
        QCOMPARE(model.sourceModel(0), sourceModel1);
        QCOMPARE(model.sourceModel(1), sourceModel1);
        QCOMPARE(model.sourceModel(2), sourceModel1);
        QCOMPARE(model.sourceModel(3), sourceModel3);
        QCOMPARE(model.sourceModel(4), sourceModel3);
        QCOMPARE(model.sourceModel(5), sourceModel3);
        QCOMPARE(model.sourceModel(6), sourceModel3);
        QCOMPARE(model.sourceModel(7), nullptr);
        QCOMPARE(model.sourceModel(-1), nullptr);

        QCOMPARE(model.sourceModelRow(0), 0);
        QCOMPARE(model.sourceModelRow(1), 1);
        QCOMPARE(model.sourceModelRow(2), 2);
        QCOMPARE(model.sourceModelRow(3), 0);
        QCOMPARE(model.sourceModelRow(4), 1);
        QCOMPARE(model.sourceModelRow(5), 2);
        QCOMPARE(model.sourceModelRow(6), 3);
        QCOMPARE(model.sourceModelRow(7), -1);
        QCOMPARE(model.sourceModelRow(-1), -1);

        // getting row by source model source model row
        QCOMPARE(model.fromSourceRow(nullptr, 0), -1);

        QCOMPARE(model.fromSourceRow(sourceModel1, 0), 0);
        QCOMPARE(model.fromSourceRow(sourceModel1, 1), 1);
        QCOMPARE(model.fromSourceRow(sourceModel1, 2), 2);
        QCOMPARE(model.fromSourceRow(sourceModel1, 3), -1);
        QCOMPARE(model.fromSourceRow(sourceModel1, -1), -1);
        QCOMPARE(model.fromSourceRow(sourceModel2, 0), -1);
        QCOMPARE(model.fromSourceRow(sourceModel3, 0), 3);
        QCOMPARE(model.fromSourceRow(sourceModel3, 1), 4);
        QCOMPARE(model.fromSourceRow(sourceModel3, 2), 5);
        QCOMPARE(model.fromSourceRow(sourceModel3, 3), 6);
        QCOMPARE(model.fromSourceRow(sourceModel3, 4), -1);
    }

    void settingPropagateResetTest()
    {
        ConcatModel model;
        QSignalSpy spy(&model, &ConcatModel::propagateResetsChanged);

        QCOMPARE(model.propagateResets(), false);
        model.setPropagateResets(false);
        QCOMPARE(spy.count(), 0);

        model.setPropagateResets(true);
        QCOMPARE(spy.count(), 1);
        model.setPropagateResets(true);
        QCOMPARE(spy.count(), 1);

        model.setPropagateResets(false);
        QCOMPARE(spy.count(), 2);
    }

    void dataChangeTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "balance", 11 }, { "name", "n1" }},
            QJsonObject {{ "key", 2},{ "balance", 12 }, { "name", "n2" }},
            QJsonObject {{ "key", 3},{ "balance", 13}, { "name", "n3" }},
        });

        ListModelWrapper sourceModel2(engine, QJsonArray {});

        ListModelWrapper sourceModel3(engine, QJsonArray {
            QJsonObject {{ "balance", 14 }, { "name", "n4" }, { "color", "red"}},
            QJsonObject {{ "balance", 15 }, { "name", "n5" }, { "color", "green"}},
            QJsonObject {{ "balance", 16 }, { "name", "n6" }, { "color", "blue"}},
            QJsonObject {{ "balance", 17 }, { "name", "n7" }, { "color", "pink"}},
        });

        ListModelWrapper sourceModel4(engine, QJsonArray {});

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1;
        source1.setModel(sourceModel1);

        SourceModel source2;
        source2.setModel(sourceModel2);

        SourceModel source3;
        source3.setModel(sourceModel3);

        SourceModel source4;
        source4.setModel(sourceModel4);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);
        sources.append(&sources, &source4);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        auto roles = model.roleNames();

        // first non-empty source model modifications
        {
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            sourceModel1.setProperty(0, "key", 21);
            QCOMPARE(dataChangedSpy.count(), 1);
            QCOMPARE(dataChangedSpy.at(0).at(0), model.index(0, 0));
            QCOMPARE(dataChangedSpy.at(0).at(1), model.index(0, 0));
            QCOMPARE(dataChangedSpy.at(0).at(2).value<QVector<int>>(),
                     { roleForName(roles, "key") });

            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 21);
        }
        {
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            sourceModel1.setProperty(1, "balance", 22);
            QCOMPARE(dataChangedSpy.count(), 1);
            QCOMPARE(dataChangedSpy.at(0).at(0), model.index(1, 0));
            QCOMPARE(dataChangedSpy.at(0).at(1), model.index(1, 0));
            QCOMPARE(dataChangedSpy.at(0).at(2).value<QVector<int>>(),
                     { roleForName(roles, "balance") });

            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "balance")), 22);
        }
        {
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            sourceModel1.setProperty(2, "name", "n13");
            QCOMPARE(dataChangedSpy.count(), 1);
            QCOMPARE(dataChangedSpy.at(0).at(0), model.index(2, 0));
            QCOMPARE(dataChangedSpy.at(0).at(1), model.index(2, 0));
            QCOMPARE(dataChangedSpy.at(0).at(2).value<QVector<int>>(),
                     { roleForName(roles, "name") });

            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "name")), "n13");
        }

        // second non-empty source model modifications
        {
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            sourceModel3.setProperty(0, "balance", 24);
            QCOMPARE(dataChangedSpy.count(), 1);
            QCOMPARE(dataChangedSpy.at(0).at(0), model.index(3, 0));
            QCOMPARE(dataChangedSpy.at(0).at(1), model.index(3, 0));
            QCOMPARE(dataChangedSpy.at(0).at(2).value<QVector<int>>(),
                     { roleForName(roles, "balance") });

            QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "balance")), 24);
        }
        {
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            sourceModel3.setProperty(1, "name", "n25");
            QCOMPARE(dataChangedSpy.count(), 1);
            QCOMPARE(dataChangedSpy.at(0).at(0), model.index(4, 0));
            QCOMPARE(dataChangedSpy.at(0).at(1), model.index(4, 0));
            QCOMPARE(dataChangedSpy.at(0).at(2).value<QVector<int>>(),
                     { roleForName(roles, "name") });

            QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "name")), "n25");
        }
        {
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            sourceModel3.setProperty(2, "color", "orange");
            QCOMPARE(dataChangedSpy.count(), 1);
            QCOMPARE(dataChangedSpy.at(0).at(0), model.index(5, 0));
            QCOMPARE(dataChangedSpy.at(0).at(1), model.index(5, 0));
            QCOMPARE(dataChangedSpy.at(0).at(2).value<QVector<int>>(),
                     { roleForName(roles, "color") });

            QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "color")), "orange");
        }

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 21);
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 2);
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "key")), 3);
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "key")), {});
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "key")), {});
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "key")), {});
        QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "key")), {});

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "balance")), 11);
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "balance")), 22);
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "balance")), 13);
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "balance")), 24);
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "balance")), 15);
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "balance")), 16);
        QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "balance")), 17);

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "name")), "n1");
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "name")), "n2");
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "name")), "n13");
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "name")), "n4");
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "name")), "n25");
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "name")), "n6");
        QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "name")), "n7");

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "color")), {});
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "color")), {});
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "color")), {});
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "color")), "red");
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "color")), "green");
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "color")), "orange");
        QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "color")), "pink");

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "whichModel")), "");
    }

    void dataChangeOnNotTrackedRoleTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "balance", 11 }, { "name", "n1" }},
            QJsonObject {{ "key", 2},{ "balance", 12 }, { "name", "n2" }},
            QJsonObject {{ "key", 3},{ "balance", 13}, { "name", "n3" }},
        });

        ListModelWrapper sourceModel2(engine, QJsonArray {});

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2;
        source1.setModel(sourceModel1);
        source2.setModel(sourceModel2);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        QCOMPARE(model.rowCount(), 3);

        sourceModel2.append(QJsonArray {
            QJsonObject {{ "someRole", 1}}, QJsonObject {{ "someRole", 2}},
            QJsonObject {{ "someRole", 3}}, QJsonObject {{ "someRole", 4}}
        });

        QCOMPARE(model.rowCount(), 7);

        QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
        sourceModel2.setProperty(0, "someRole", 42);
        QCOMPARE(dataChangedSpy.count(), 0);
    }

    void dataInsertionTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "balance", 11 }, { "name", "n1" }},
            QJsonObject {{ "key", 2},{ "balance", 12 }, { "name", "n2" }},
            QJsonObject {{ "key", 3},{ "balance", 13}, { "name", "n3" }},
        });

        ListModelWrapper sourceModel2(engine, QJsonArray {});

        ListModelWrapper sourceModel3(engine, QJsonArray {
            QJsonObject {{ "balance", 14 }, { "name", "n4" }, { "color", "red"}},
            QJsonObject {{ "balance", 15 }, { "name", "n5" }, { "color", "green"}},
            QJsonObject {{ "balance", 16 }, { "name", "n6" }, { "color", "blue"}},
            QJsonObject {{ "balance", 17 }, { "name", "n7" }, { "color", "pink"}},
        });

        ListModelWrapper sourceModel4(engine, QJsonArray {});

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1;
        source1.setModel(sourceModel1);

        SourceModel source2;
        source2.setModel(sourceModel2);

        SourceModel source3;
        source3.setModel(sourceModel3);

        SourceModel source4;
        source4.setModel(sourceModel4);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);
        sources.append(&sources, &source4);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        auto roles = model.roleNames();

        // inserting into first model
        {
            QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

            sourceModel1.insert(0, QJsonObject {
                { "key", 200}, { "balance", 300 }, { "name", "n200" }
            });

            QCOMPARE(rowsInsertedSpy.count(), 1);
            QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsInsertedSpy.at(0).at(1), 0);
            QCOMPARE(rowsInsertedSpy.at(0).at(2), 0);

            QCOMPARE(model.rowCount(), 8);

            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 200);
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "balance")), 300);
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "name")), "n200");
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "color")), {});
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "whichModel")), "");
        }
        {
            QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

            sourceModel1.insert(2, QJsonObject {{ "key", 201}, { "balance", 301 }, { "name", "n201" }});

            QCOMPARE(rowsInsertedSpy.count(), 1);
            QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsInsertedSpy.at(0).at(1), 2);
            QCOMPARE(rowsInsertedSpy.at(0).at(2), 2);

            QCOMPARE(model.rowCount(), 9);

            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "key")), 201);
            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "balance")), 301);
            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "name")), "n201");
            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "color")), {});
            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "whichModel")), "");
        }

        // inserting into second, empty model
        {
            QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

            sourceModel2.insert(0, QJsonObject {{ "key", 202}, { "balance", 302 }, { "name", "n202" }});

            QCOMPARE(rowsInsertedSpy.count(), 1);
            QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsInsertedSpy.at(0).at(1), 5);
            QCOMPARE(rowsInsertedSpy.at(0).at(2), 5);

            QCOMPARE(model.rowCount(), 10);

            QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "key")), 202);
            QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "balance")), 302);
            QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "name")), "n202");
            QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "color")), {});
            QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "whichModel")), "");
        }

        // inserting into third
        {
            QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

            sourceModel3.insert(2, QJsonObject {
                { "balance", 303 }, { "name", "n203" }, { "color", "brown" }
            });

            QCOMPARE(rowsInsertedSpy.count(), 1);
            QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsInsertedSpy.at(0).at(1), 8);
            QCOMPARE(rowsInsertedSpy.at(0).at(2), 8);

            QCOMPARE(model.rowCount(), 11);

            QCOMPARE(model.data(model.index(8, 0), roleForName(roles, "key")), {});
            QCOMPARE(model.data(model.index(8, 0), roleForName(roles, "balance")), 303);
            QCOMPARE(model.data(model.index(8, 0), roleForName(roles, "name")), "n203");
            QCOMPARE(model.data(model.index(8, 0), roleForName(roles, "color")), "brown");
            QCOMPARE(model.data(model.index(8, 0), roleForName(roles, "whichModel")), "");
        }

        // inserting into forth, empty model
        {
            QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

            sourceModel4.insert(0, QJsonObject {
                { "key", 204 }, { "balance", 304 }, { "name", "n204" }, { "color", "black" }
            });

            QCOMPARE(rowsInsertedSpy.count(), 1);
            QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsInsertedSpy.at(0).at(1), 11);
            QCOMPARE(rowsInsertedSpy.at(0).at(2), 11);

            QCOMPARE(model.rowCount(), 12);

            QCOMPARE(model.data(model.index(11, 0), roleForName(roles, "key")), 204);
            QCOMPARE(model.data(model.index(11, 0), roleForName(roles, "balance")), 304);
            QCOMPARE(model.data(model.index(11, 0), roleForName(roles, "name")), "n204");
            QCOMPARE(model.data(model.index(11, 0), roleForName(roles, "color")), "black");
            QCOMPARE(model.data(model.index(11, 0), roleForName(roles, "whichModel")), "");
        }

        // inserting multiple items (first model)
        {
            QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

            sourceModel1.append(QJsonArray {
                QJsonObject {{ "key", 205}, { "balance", 305 }, { "name", "n205" }},
                QJsonObject {{ "key", 206},{ "balance", 306 }, { "name", "n206" }}
            });

            QCOMPARE(rowsInsertedSpy.count(), 1);
            QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsInsertedSpy.at(0).at(1), 5);
            QCOMPARE(rowsInsertedSpy.at(0).at(2), 6);

            QCOMPARE(model.rowCount(), 14);

            QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "key")), 205);
            QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "balance")), 305);
            QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "name")), "n205");
            QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "color")), {});
            QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "whichModel")), "");

            QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "key")), 206);
            QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "balance")), 306);
            QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "name")), "n206");
            QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "color")), {});
            QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "whichModel")), "");
        }
    }

    void dataInsertionToEmptyModelTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine);
        ListModelWrapper sourceModel2(engine);

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1;
        source1.setModel(sourceModel1);

        SourceModel source2;
        source2.setModel(sourceModel2);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        QCOMPARE(model.roleNames(), {});

        {
            QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

            sourceModel1.append(QJsonArray {
                QJsonObject {{ "key", 1}, { "balance", 11 }, { "name", "n1" }},
                QJsonObject {{ "key", 2},{ "balance", 12 }, { "name", "n2" }}
            });

            QCOMPARE(rowsInsertedSpy.count(), 1);
            QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsInsertedSpy.at(0).at(1), 0);
            QCOMPARE(rowsInsertedSpy.at(0).at(2), 1);

            QCOMPARE(model.rowCount(), 2);

            auto roles = model.roleNames();
            QCOMPARE(roles.size(), 4);

            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 1);
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "balance")), 11);
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "name")), "n1");
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "whichModel")), "");

            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 2);
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "balance")), 12);
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "name")), "n2");
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "whichModel")), "");
        }
        {
            QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

            sourceModel2.append(QJsonArray {
                QJsonObject {{ "key", 3}, { "color", "red" }},
                QJsonObject {{ "key", 4}, { "color", "blue" }}
            });

            QCOMPARE(rowsInsertedSpy.count(), 1);
            QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsInsertedSpy.at(0).at(1), 2);
            QCOMPARE(rowsInsertedSpy.at(0).at(2), 3);

            QCOMPARE(model.rowCount(), 4);

            auto roles = model.roleNames();
            QCOMPARE(roles.size(), 4);

            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 1);
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "balance")), 11);
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "name")), "n1");
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "whichModel")), "");

            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 2);
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "balance")), 12);
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "name")), "n2");
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "whichModel")), "");

            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "key")), 3);
            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "balance")), {});
            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "name")), {});
            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "whichModel")), "");

            QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "key")), 4);
            QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "balance")), {});
            QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "name")), {});
            QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "whichModel")), "");
        }
    }

    void deferredNonEmptyModelSettingTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "color", "red" }},
            QJsonObject {{ "key", 2}, { "color", "blue" }}
        });
        ListModelWrapper sourceModel2(engine, QJsonArray {
            QJsonObject {{ "key", 3}, { "color", "orange" }},
            QJsonObject {{ "key", 4}, { "color", "green" }}
        });

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2;
        sources.append(&sources, &source1);
        sources.append(&sources, &source2);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});

        {
            QSignalSpy rowsAboutToBeInsertedSpy(
                        &model, &ConcatModel::rowsAboutToBeInserted);
            QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

            // checking validity inside rowsAboutToBeInserted signal
            {
                QObject context;
                connect(&model, &ConcatModel::rowsAboutToBeInserted, &context,
                        [&model] { QCOMPARE(model.rowCount(), 0); });

                source1.setModel(sourceModel1);
            }

            QCOMPARE(rowsAboutToBeInsertedSpy.count(), 1);
            QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(1), 0);
            QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(2), 1);

            QCOMPARE(rowsInsertedSpy.count(), 1);
            QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsInsertedSpy.at(0).at(1), 0);
            QCOMPARE(rowsInsertedSpy.at(0).at(2), 1);

            QCOMPARE(model.roleNames().size(), 3);
            QCOMPARE(model.rowCount(), 2);

            // check if connections are established correctly
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            sourceModel1.setProperty(1, "color", "white");

            QCOMPARE(dataChangedSpy.count(), 1);
            QCOMPARE(dataChangedSpy.at(0).at(0), model.index(1, 0));
            QCOMPARE(dataChangedSpy.at(0).at(1), model.index(1, 0));
        }
        {
            QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

            {
                QObject context;
                connect(&model, &ConcatModel::rowsAboutToBeInserted, &context,
                        [&model] { QCOMPARE(model.rowCount(), 2); });

                source2.setModel(sourceModel2);
            }

            QCOMPARE(rowsInsertedSpy.count(), 1);
            QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsInsertedSpy.at(0).at(1), 2);
            QCOMPARE(rowsInsertedSpy.at(0).at(2), 3);

            QCOMPARE(model.roleNames().size(), 3);
            QCOMPARE(model.rowCount(), 4);

            // check if connections are established correctly
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            sourceModel2.setProperty(1, "color", "black");

            QCOMPARE(dataChangedSpy.count(), 1);
            QCOMPARE(dataChangedSpy.at(0).at(0), model.index(3, 0));
            QCOMPARE(dataChangedSpy.at(0).at(1), model.index(3, 0));
        }
    }

    void deferredEmptyModelSettingTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine);
        ListModelWrapper sourceModel2(engine);

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2;

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        source1.setModel(sourceModel1);
        source2.setModel(sourceModel2);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});

        {
            QSignalSpy rowsAboutToBeInsertedSpy(
                        &model, &ConcatModel::rowsAboutToBeInserted);
            QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

            // checking validity inside rowsAboutToBeInserted signal
            {
                QObject context;
                connect(&model, &ConcatModel::rowsAboutToBeInserted, &context,
                        [&model] { QCOMPARE(model.rowCount(), 0); });

                sourceModel2.append(QJsonArray {
                    QJsonObject {{ "key", 1}, { "color", "red" }},
                    QJsonObject {{ "key", 2}, { "color", "blue" }}
                });
            }

            QCOMPARE(rowsAboutToBeInsertedSpy.count(), 1);
            QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(1), 0);
            QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(2), 1);

            QCOMPARE(rowsInsertedSpy.count(), 1);
            QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsInsertedSpy.at(0).at(1), 0);
            QCOMPARE(rowsInsertedSpy.at(0).at(2), 1);

            QCOMPARE(model.roleNames().size(), 3);
            QCOMPARE(model.rowCount(), 2);

            // check if connections are established correctly
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            sourceModel2.setProperty(1, "color", "white");

            QCOMPARE(dataChangedSpy.count(), 1);
            QCOMPARE(dataChangedSpy.at(0).at(0), model.index(1, 0));
            QCOMPARE(dataChangedSpy.at(0).at(1), model.index(1, 0));
        }
        {
            QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

            {
                QObject context;
                connect(&model, &ConcatModel::rowsAboutToBeInserted, &context,
                        [&model] { QCOMPARE(model.rowCount(), 2); });

                sourceModel1.append(QJsonArray {
                    QJsonObject {{ "key", 3}, { "color", "green" }, { "value", 42}},
                    QJsonObject {{ "key", 4}, { "color", "white" }, { "value", 43}}
                });
            }

            QCOMPARE(rowsInsertedSpy.count(), 1);
            QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsInsertedSpy.at(0).at(1), 0);
            QCOMPARE(rowsInsertedSpy.at(0).at(2), 1);

            QCOMPARE(model.roleNames().size(), 3);
            QCOMPARE(model.rowCount(), 4);

            // check if connections are established correctly
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            sourceModel2.setProperty(1, "color", "black");

            QCOMPARE(dataChangedSpy.count(), 1);
            QCOMPARE(dataChangedSpy.at(0).at(0), model.index(3, 0));
            QCOMPARE(dataChangedSpy.at(0).at(1), model.index(3, 0));
        }
    }

    void settingModelsWithDifferentRolesTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "color", "red" }, { "key", 1}},
            QJsonObject {{ "color", "blue" }, { "key", 2}}
        });
        ListModelWrapper sourceModel2(engine, QJsonArray {
            QJsonObject {{ "key", 3}},
            QJsonObject {{ "key", 4}}
        });
        ListModelWrapper sourceModel3(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "color", "red" }, { "value", 42}},
            QJsonObject {{ "key", 2}, { "color", "blue" }, { "value", 42}}
        });

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2, source3;

        source1.setModel(sourceModel1);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.roleNames().count(), 3);

        {
            QSignalSpy rowsAboutToBeInsertedSpy(
                        &model, &ConcatModel::rowsAboutToBeInserted);
            QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

            // checking validity inside rowsAboutToBeInserted signal
            {
                QObject context;
                connect(&model, &ConcatModel::rowsAboutToBeInserted, &context,
                        [&model] { QCOMPARE(model.rowCount(), 2); });

                source2.setModel(sourceModel2);
            }

            QCOMPARE(rowsAboutToBeInsertedSpy.count(), 1);
            QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(1), 2);
            QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(2), 3);

            QCOMPARE(rowsInsertedSpy.count(), 1);
            QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsInsertedSpy.at(0).at(1), 2);
            QCOMPARE(rowsInsertedSpy.at(0).at(2), 3);

            QCOMPARE(model.roleNames().size(), 3);
            QCOMPARE(model.rowCount(), 4);

            // check if connections are established correctly
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            sourceModel1.setProperty(1, "color", "white");

            QCOMPARE(dataChangedSpy.count(), 1);
            QCOMPARE(dataChangedSpy.at(0).at(0), model.index(1, 0));
            QCOMPARE(dataChangedSpy.at(0).at(1), model.index(1, 0));
        }

        {
            QSignalSpy rowsAboutToBeInsertedSpy(
                        &model, &ConcatModel::rowsAboutToBeInserted);
            QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

            // checking validity inside rowsAboutToBeInserted signal
            {
                QObject context;
                connect(&model, &ConcatModel::rowsAboutToBeInserted, &context,
                        [&model] { QCOMPARE(model.rowCount(), 4); });

                source3.setModel(sourceModel3);
            }

            QCOMPARE(rowsAboutToBeInsertedSpy.count(), 1);
            QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(1), 4);
            QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(2), 5);

            QCOMPARE(rowsInsertedSpy.count(), 1);
            QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsInsertedSpy.at(0).at(1), 4);
            QCOMPARE(rowsInsertedSpy.at(0).at(2), 5);

            QCOMPARE(model.roleNames().size(), 3);
            QCOMPARE(model.rowCount(), 6);

            // check if connections are established correctly
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            sourceModel3.setProperty(0, "color", "white");

            QCOMPARE(dataChangedSpy.count(), 1);
            QCOMPARE(dataChangedSpy.at(0).at(0), model.index(4, 0));
            QCOMPARE(dataChangedSpy.at(0).at(1), model.index(4, 0));
        }
    }

    void unsettingModelsTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "color", "red" }},
            QJsonObject {{ "key", 2}, { "color", "blue" }}
        });
        ListModelWrapper sourceModel2(engine, QJsonArray {
            QJsonObject {{ "key", 3}},
            QJsonObject {{ "key", 4}}
        });
        ListModelWrapper sourceModel3(engine, QJsonArray {
            QJsonObject {{ "key", 5}, { "color", "red" }, { "value", 42}},
            QJsonObject {{ "key", 6}, { "color", "green" }, { "value", 43}}
        });

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2, source3;

        source1.setModel(sourceModel1);
        source2.setModel(sourceModel2);
        source3.setModel(sourceModel3);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        QCOMPARE(model.rowCount(), 6);
        QCOMPARE(model.roleNames().count(), 4);

        {
            QSignalSpy rowsAboutToBeRemovedSpy(&model, &ConcatModel::rowsAboutToBeRemoved);
            QSignalSpy rowsRemovedSpy(&model, &ConcatModel::rowsRemoved);

            // checking validity inside rowsAboutToBeRemoved signal
            {
                QObject context;
                connect(&model, &ConcatModel::rowsAboutToBeRemoved, &context,
                        [&model] { QCOMPARE(model.rowCount(), 6); });

                source1.setModel(nullptr);
            }

            QCOMPARE(model.rowCount(), 4);

            QCOMPARE(rowsAboutToBeRemovedSpy.count(), 1);
            QCOMPARE(rowsRemovedSpy.count(), 1);

            QCOMPARE(rowsAboutToBeRemovedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsAboutToBeRemovedSpy.at(0).at(1), 0);
            QCOMPARE(rowsAboutToBeRemovedSpy.at(0).at(2), 1);

            QCOMPARE(rowsRemovedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsRemovedSpy.at(0).at(1), 0);
            QCOMPARE(rowsRemovedSpy.at(0).at(2), 1);
        }
        {
            QSignalSpy rowsAboutToBeRemovedSpy(&model, &ConcatModel::rowsAboutToBeRemoved);
            QSignalSpy rowsRemovedSpy(&model, &ConcatModel::rowsRemoved);

            // checking validity inside rowsAboutToBeRemoved signal
            {
                QObject context;
                connect(&model, &ConcatModel::rowsAboutToBeRemoved, &context,
                        [&model] { QCOMPARE(model.rowCount(), 4); });

                source3.setModel(nullptr);
            }

            QCOMPARE(rowsAboutToBeRemovedSpy.count(), 1);
            QCOMPARE(rowsRemovedSpy.count(), 1);

            QCOMPARE(rowsAboutToBeRemovedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsAboutToBeRemovedSpy.at(0).at(1), 2);
            QCOMPARE(rowsAboutToBeRemovedSpy.at(0).at(2), 3);

            QCOMPARE(rowsRemovedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsRemovedSpy.at(0).at(1), 2);
            QCOMPARE(rowsRemovedSpy.at(0).at(2), 3);
        }
        {
            QSignalSpy rowsAboutToBeRemovedSpy(&model, &ConcatModel::rowsAboutToBeRemoved);
            QSignalSpy rowsRemovedSpy(&model, &ConcatModel::rowsRemoved);

            // checking validity inside rowsAboutToBeRemoved signal
            {
                QObject context;
                connect(&model, &ConcatModel::rowsAboutToBeRemoved, &context,
                        [&model] { QCOMPARE(model.rowCount(), 2); });

                source2.setModel(nullptr);
            }

            QCOMPARE(rowsAboutToBeRemovedSpy.count(), 1);
            QCOMPARE(rowsRemovedSpy.count(), 1);

            QCOMPARE(rowsAboutToBeRemovedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsAboutToBeRemovedSpy.at(0).at(1), 0);
            QCOMPARE(rowsAboutToBeRemovedSpy.at(0).at(2), 1);

            QCOMPARE(rowsRemovedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(rowsRemovedSpy.at(0).at(1), 0);
            QCOMPARE(rowsRemovedSpy.at(0).at(2), 1);
        }
        {
            QSignalSpy rowsAboutToBeRemovedSpy(&model, &ConcatModel::rowsAboutToBeRemoved);
            QSignalSpy rowsRemovedSpy(&model, &ConcatModel::rowsRemoved);

            source2.setModel(nullptr);

            QCOMPARE(rowsAboutToBeRemovedSpy.count(), 0);
            QCOMPARE(rowsRemovedSpy.count(), 0);
        }

        // check if signals are disconnected properly
        {
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            sourceModel1.setProperty(0, "key", 11);
            sourceModel2.setProperty(0, "key", 12);
            sourceModel3.setProperty(0, "key", 13);

            QCOMPARE(dataChangedSpy.count(), 0);
        }
    }

    void replacingModelsTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "color", "red" }},
            QJsonObject {{ "key", 2}, { "color", "blue" }}
        });
        ListModelWrapper sourceModel2(engine, QJsonArray {
            QJsonObject {{ "key", 3}},
            QJsonObject {{ "key", 4}}
        });
        ListModelWrapper sourceModel3(engine, QJsonArray {
            QJsonObject {{ "key", 5}, { "color", "red" }, { "value", 42}},
            QJsonObject {{ "key", 6}, { "color", "green" }, { "value", 43}}
        });
        ListModelWrapper sourceModel4(engine, QJsonArray {
            QJsonObject {{ "color", "orange" }, { "value", 44}, { "key", 7}},
            QJsonObject {{ "color", "green" }, { "value", 45}, { "key", 8}},
            QJsonObject {{ "color", "brown" }, { "value", 46}, { "key", 9}}
        });

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2, source3;

        source1.setModel(sourceModel1);
        source2.setModel(sourceModel2);
        source3.setModel(sourceModel3);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        QCOMPARE(model.rowCount(), 6);
        QCOMPARE(model.roleNames().count(), 4);

        QSignalSpy rowsAboutToBeRemovedSpy(&model, &ConcatModel::rowsAboutToBeRemoved);
        QSignalSpy rowsRemovedSpy(&model, &ConcatModel::rowsRemoved);

        QSignalSpy rowsAboutToBeInsertedSpy(
                    &model, &ConcatModel::rowsAboutToBeInserted);
        QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

        // checking validity inside rowsAboutToBeRemoved signal
        {
            QObject context;
            connect(&model, &ConcatModel::rowsAboutToBeRemoved, &context,
                    [&model] { QCOMPARE(model.rowCount(), 6); });

            connect(&model, &ConcatModel::rowsRemoved, &context,
                    [&model] { QCOMPARE(model.rowCount(), 4); });

            connect(&model, &ConcatModel::rowsAboutToBeInserted, &context,
                    [&model] { QCOMPARE(model.rowCount(), 4); });

            source2.setModel(sourceModel4);
        }

        QCOMPARE(model.rowCount(), 7);

        QCOMPARE(rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(rowsRemovedSpy.count(), 1);

        QCOMPARE(rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(rowsInsertedSpy.count(), 1);

        QCOMPARE(rowsAboutToBeRemovedSpy.at(0).at(0), QModelIndex{});
        QCOMPARE(rowsAboutToBeRemovedSpy.at(0).at(1), 2);
        QCOMPARE(rowsAboutToBeRemovedSpy.at(0).at(2), 3);

        QCOMPARE(rowsRemovedSpy.at(0).at(0), QModelIndex{});
        QCOMPARE(rowsRemovedSpy.at(0).at(1), 2);
        QCOMPARE(rowsRemovedSpy.at(0).at(2), 3);

        QCOMPARE(rowsAboutToBeInsertedSpy.count(), 1);
        QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(0), QModelIndex{});
        QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(1), 2);
        QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(2), 4);

        QCOMPARE(rowsInsertedSpy.count(), 1);
        QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
        QCOMPARE(rowsInsertedSpy.at(0).at(1), 2);
        QCOMPARE(rowsInsertedSpy.at(0).at(2), 4);

        // check if previous model is disconnected
        QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
        sourceModel2.setProperty(0, "key", 234);

        QCOMPARE(dataChangedSpy.count(), 0);

        // content validation
        auto roles = model.roleNames();

        QCOMPARE(roles.count(), 4);

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 1);
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 2);
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "key")), 7);
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "key")), 8);
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "key")), 9);
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "key")), 5);
        QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "key")), 6);

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "color")), "red");
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "color")), "blue");
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "color")), "orange");
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "color")), "green");
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "color")), "brown");
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "color")), "red");
        QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "color")), "green");

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "value")), {});
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "value")), {});
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "value")), 44);
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "value")), 45);
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "value")), 46);
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "value")), 42);
        QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "value")), 43);
    }

    void deletingModelsTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "color", "red" }},
            QJsonObject {{ "key", 2}, { "color", "blue" }}
        });
        auto sourceModel2 = std::make_unique<ListModelWrapper>(engine, QJsonArray {
            QJsonObject {{ "key", 3}},
            QJsonObject {{ "key", 4}}
        });
        ListModelWrapper sourceModel3(engine, QJsonArray {
            QJsonObject {{ "key", 5}, { "color", "red" }, { "value", 42}},
            QJsonObject {{ "key", 6}, { "color", "green" }, { "value", 43}}
        });

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2, source3;

        source1.setModel(sourceModel1);
        source2.setModel(*sourceModel2);
        source3.setModel(sourceModel3);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        auto roles = model.roleNames();

        QCOMPARE(model.rowCount(), 6);
        QCOMPARE(roles.count(), 4);

        QSignalSpy rowsAboutToBeRemovedSpy(&model, &ConcatModel::rowsAboutToBeRemoved);
        QSignalSpy rowsRemovedSpy(&model, &ConcatModel::rowsRemoved);

        sourceModel2.reset();

        QCOMPARE(model.rowCount(), 6);

        QCOMPARE(rowsAboutToBeRemovedSpy.count(), 0);
        QCOMPARE(rowsRemovedSpy.count(), 0);

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 1);
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 2);
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "key")), {});
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "key")), {});
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "key")), 5);
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "key")), 6);

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "whichModel")), "");
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "whichModel")), "");
    }

    void removalTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "color", "red" }},
            QJsonObject {{ "key", 2}, { "color", "blue" }}
        });
        ListModelWrapper sourceModel2(engine, QJsonArray {
            QJsonObject {{ "key", 3}},
            QJsonObject {{ "key", 4}},
            QJsonObject {{ "key", 5}}
        });
        ListModelWrapper sourceModel3(engine, QJsonArray {
            QJsonObject {{ "key", 6}, { "color", "red" }, { "value", 42}},
            QJsonObject {{ "key", 7}, { "color", "green" }, { "value", 43}}
        });

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2, source3;

        source1.setModel(sourceModel1);
        source2.setModel(sourceModel2);
        source3.setModel(sourceModel3);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        auto roles = model.roleNames();

        QCOMPARE(model.rowCount(), 7);
        QCOMPARE(roles.count(), 4);

        QSignalSpy rowsAboutToBeRemovedSpy(&model, &ConcatModel::rowsAboutToBeRemoved);
        QSignalSpy rowsRemovedSpy(&model, &ConcatModel::rowsRemoved);

        // checking validity inside rowsAboutToBeRemoved signal
        {
            QObject context;
            connect(&model, &ConcatModel::rowsAboutToBeRemoved, &context,
                    [this, &model, &roles] {
                QCOMPARE(model.rowCount(), 7);
                QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "key")), 4);
            });

            sourceModel2.remove(1, 2);
        }

        QCOMPARE(model.rowCount(), 5);

        QCOMPARE(rowsAboutToBeRemovedSpy.count(), 1);
        QCOMPARE(rowsRemovedSpy.count(), 1);

        QCOMPARE(rowsAboutToBeRemovedSpy.at(0).at(0), QModelIndex{});
        QCOMPARE(rowsAboutToBeRemovedSpy.at(0).at(1), 3);
        QCOMPARE(rowsAboutToBeRemovedSpy.at(0).at(2), 4);

        QCOMPARE(rowsRemovedSpy.at(0).at(0), QModelIndex{});
        QCOMPARE(rowsRemovedSpy.at(0).at(1), 3);
        QCOMPARE(rowsRemovedSpy.at(0).at(2), 4);

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 1);
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 2);
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "key")), 3);
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "key")), 6);
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "key")), 7);
    }

    void moveTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "color", "red" }},
            QJsonObject {{ "key", 2}, { "color", "blue" }}
        });
        ListModelWrapper sourceModel2(engine, QJsonArray {
            QJsonObject {{ "key", 3}},
            QJsonObject {{ "key", 4}},
            QJsonObject {{ "key", 5}}
        });
        ListModelWrapper sourceModel3(engine, QJsonArray {
            QJsonObject {{ "key", 6}, { "color", "red" }, { "value", 42}},
            QJsonObject {{ "key", 7}, { "color", "green" }, { "value", 43}}
        });

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2, source3;

        source1.setModel(sourceModel1);
        source2.setModel(sourceModel2);
        source3.setModel(sourceModel3);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        auto roles = model.roleNames();

        QCOMPARE(model.rowCount(), 7);
        QCOMPARE(roles.count(), 4);

        QSignalSpy rowsAboutToBeMovedSpy(&model, &ConcatModel::rowsAboutToBeMoved);
        QSignalSpy rowsMovedSpy(&model, &ConcatModel::rowsMoved);

        // checking validity inside rowsAboutToBeRemoved signal
        {
            QObject context;
            connect(&model, &ConcatModel::rowsAboutToBeMoved, &context,
                    [this, &model, &roles] {
                QCOMPARE(model.rowCount(), 7);
                QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "key")), 4);
            });

            sourceModel2.move(1, 0, 2);
        }

        QCOMPARE(model.rowCount(), 7);

        QCOMPARE(rowsAboutToBeMovedSpy.count(), 1);
        QCOMPARE(rowsMovedSpy.count(), 1);

        QCOMPARE(rowsAboutToBeMovedSpy.at(0).at(0), QModelIndex{});
        QCOMPARE(rowsAboutToBeMovedSpy.at(0).at(1), 3);
        QCOMPARE(rowsAboutToBeMovedSpy.at(0).at(2), 4);
        QCOMPARE(rowsAboutToBeMovedSpy.at(0).at(3), QModelIndex{});
        QCOMPARE(rowsAboutToBeMovedSpy.at(0).at(4), 2);

        QCOMPARE(rowsMovedSpy.at(0).at(0), QModelIndex{});
        QCOMPARE(rowsMovedSpy.at(0).at(1), 3);
        QCOMPARE(rowsMovedSpy.at(0).at(2), 4);
        QCOMPARE(rowsMovedSpy.at(0).at(3), QModelIndex{});
        QCOMPARE(rowsMovedSpy.at(0).at(4), 2);
    }

    void layoutChangedTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "color", "red" }},
            QJsonObject {{ "key", 2}, { "color", "blue" }}
        });
        ListModelWrapper sourceModel2(engine, QJsonArray {
            QJsonObject {{ "key", 3}},
            QJsonObject {{ "key", 4}},
            QJsonObject {{ "key", 5}}
        });

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2, source3;

        source1.setModel(sourceModel1);
        source2.setModel(sourceModel2);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        auto roles = model.roleNames();

        QCOMPARE(model.rowCount(), 5);
        QCOMPARE(roles.count(), 3);

        // register types to avoid warnings regarding signal params
        qRegisterMetaType<QList<QPersistentModelIndex>>();
        qRegisterMetaType<QAbstractItemModel::LayoutChangeHint>();

        QSignalSpy layoutAboutToBeChangedSpy(&model, &ConcatModel::layoutAboutToBeChanged);
        QSignalSpy layoutChangedSpy(&model, &ConcatModel::layoutChanged);

        emit sourceModel1.model()->layoutAboutToBeChanged();
        QCOMPARE(layoutAboutToBeChangedSpy.count(), 1);
        QCOMPARE(layoutChangedSpy.count(), 0);

        emit sourceModel1.model()->layoutChanged();
        QCOMPARE(layoutAboutToBeChangedSpy.count(), 1);
        QCOMPARE(layoutChangedSpy.count(), 1);
    }

    void modelResetWhenEmptyTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine);
        ListModelWrapper sourceModel2(engine);
        ListModelWrapper sourceModel3(engine);
        ListModelWrapper sourceModel4(engine);
        ListModelWrapper sourceModel5(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "color", "red" }},
            QJsonObject {{ "key", 2}, { "color", "blue" }}
        });

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2, source3;

        IdentityModel proxy1, proxy2, proxy3;

        proxy1.setSourceModel(sourceModel1);
        proxy2.setSourceModel(sourceModel2);
        proxy3.setSourceModel(sourceModel3);

        source1.setModel(&proxy1);
        source2.setModel(&proxy2);
        source3.setModel(&proxy3);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});

        {
            ModelSignalsSpy signalsSpy(&model);
            proxy2.setSourceModel(sourceModel4);

            QCOMPARE(signalsSpy.count(), 0);
            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});
        }
        {
            ModelSignalsSpy signalsSpy(&model);

            // checking validity inside rowsAboutToBeInserted signal
            {
                QObject context;
                connect(&model, &ConcatModel::rowsAboutToBeInserted, &context,
                        [&model] { QCOMPARE(model.rowCount(), 0); });

                proxy2.setSourceModel(sourceModel5);
            }

            QCOMPARE(signalsSpy.count(), 2);

            QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.count(), 1);
            QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(1), 0);
            QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(2), 1);

            QCOMPARE(signalsSpy.rowsInsertedSpy.count(), 1);
            QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(1), 0);
            QCOMPARE(signalsSpy.rowsInsertedSpy.at(0).at(2), 1);

            auto roles = model.roleNames();

            QCOMPARE(model.rowCount(), 2);
            QCOMPARE(roles.count(), 3);

            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 1);
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 2);
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "color")), "red");
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "color")), "blue");
        }
    }

    void modelResetWhenEmptyWithPropagateResetsTest()
    {
        QQmlEngine engine;
        ConcatModel model;
        model.setPropagateResets(true);

        ListModelWrapper sourceModel1(engine);
        ListModelWrapper sourceModel2(engine);
        ListModelWrapper sourceModel3(engine);
        ListModelWrapper sourceModel4(engine);
        ListModelWrapper sourceModel5(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "color", "red" }},
            QJsonObject {{ "key", 2}, { "color", "blue" }}
        });

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2, source3;

        IdentityModel proxy1, proxy2, proxy3;

        proxy1.setSourceModel(sourceModel1);
        proxy2.setSourceModel(sourceModel2);
        proxy3.setSourceModel(sourceModel3);

        source1.setModel(&proxy1);
        source2.setModel(&proxy2);
        source3.setModel(&proxy3);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});

        {
            ModelSignalsSpy signalsSpy(&model);
            proxy2.setSourceModel(sourceModel4);

            QCOMPARE(signalsSpy.count(), 0);
            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(model.roleNames(), {});
        }
        {
            ModelSignalsSpy signalsSpy(&model);

            // checking validity inside rowsAboutToBeInserted signal
            {
                QObject context;
                connect(&model, &ConcatModel::rowsAboutToBeInserted, &context,
                        [&model] { QCOMPARE(model.rowCount(), 0); });

                proxy2.setSourceModel(sourceModel5);
            }

            QCOMPARE(signalsSpy.count(), 2);

            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);

            auto roles = model.roleNames();

            QCOMPARE(model.rowCount(), 2);
            QCOMPARE(roles.count(), 3);

            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 1);
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 2);
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "color")), "red");
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "color")), "blue");
        }
    }

    void modelResetWhenNotEmptyTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "color", "red" }},
            QJsonObject {{ "key", 2}, { "color", "blue" }}
        });
        ListModelWrapper sourceModel2(engine, QJsonArray {
            QJsonObject {{ "key", 3}},
            QJsonObject {{ "key", 4}},
            QJsonObject {{ "key", 5}}
        });
        ListModelWrapper sourceModel3(engine);

        ListModelWrapper sourceModel4(engine);
        ListModelWrapper sourceModel5(engine, QJsonArray {
            QJsonObject {{ "color", "red" }, { "name", "a" }, { "key", 11}},
            QJsonObject {{ "color", "blue" }, { "name", "b" }, { "key", 12}},
            QJsonObject {{ "color", "pink" }, { "name", "c" }, { "key", 13}}
        });

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2, source3;

        IdentityModel proxy1, proxy2, proxy3;

        proxy1.setSourceModel(sourceModel1);
        proxy2.setSourceModel(sourceModel2);
        proxy3.setSourceModel(sourceModel3);

        source1.setModel(&proxy1);
        source2.setModel(&proxy2);
        source3.setModel(&proxy3);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        auto roles = model.roleNames();

        QCOMPARE(model.rowCount(), 5);
        QCOMPARE(roles.count(), 3);

        // reset to empty model
        {
            ModelSignalsSpy signalsSpy(&model);

            // checking validity inside rowsAboutToBeRemoved signal
            {
                QObject context;
                connect(&model, &ConcatModel::rowsAboutToBeRemoved, &context,
                        [this, &model, &roles] {
                    QCOMPARE(model.rowCount(), 5);

                    QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "key")), 4);
                    QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "color")), {});
                });

                proxy2.setSourceModel(sourceModel4);
            }

            QCOMPARE(signalsSpy.count(), 2);

            QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.count(), 1);
            QCOMPARE(signalsSpy.rowsRemovedSpy.count(), 1);
            QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(1), 2);
            QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(2), 4);

            QCOMPARE(model.rowCount(), 2);

            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 1);
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 2);
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "color")), "red");
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "color")), "blue");

            // insert some data to check if roles are re-initialized properly
            sourceModel4.append(QJsonArray {
                QJsonObject {{ "color", "purple"}, { "key", 3} },
                QJsonObject {{ "color", "green" }, { "key", 4}}
            });

            QCOMPARE(model.rowCount(), 4);

            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 1);
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 2);
            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "key")), 3);
            QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "key")), 4);
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "color")), "red");
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "color")), "blue");
            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "color")), "purple");
            QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "color")), "green");

            sourceModel4.clear();
        }
        // reset to not empty model
        {
            ModelSignalsSpy signalsSpy(&model);

            // checking validity inside rowsAboutToBeRemoved, rowsRemoved and
            // rowsAboutToBeInserted signals
            {
                QObject context;
                connect(&model, &ConcatModel::rowsAboutToBeRemoved, &context,
                        [this, &model, &roles] {
                    QCOMPARE(model.rowCount(), 2);

                    QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 1);
                    QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 2);
                    QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "color")), "red");
                    QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "color")), "blue");
                });

                connect(&model, &ConcatModel::rowsRemoved, &context,
                        [this, &model, &roles] {
                    QCOMPARE(model.rowCount(), 0);
                });

                connect(&model, &ConcatModel::rowsAboutToBeInserted, &context,
                        [this, &model, &roles] {
                    QCOMPARE(model.rowCount(), 0);
                });

                proxy1.setSourceModel(sourceModel5);
            }

            QCOMPARE(signalsSpy.count(), 4);

            QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.count(), 1);
            QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(1), 0);
            QCOMPARE(signalsSpy.rowsAboutToBeRemovedSpy.at(0).at(2), 1);

            QCOMPARE(signalsSpy.rowsRemovedSpy.count(), 1);

            QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.count(), 1);
            QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(0), QModelIndex{});
            QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(1), 0);
            QCOMPARE(signalsSpy.rowsAboutToBeInsertedSpy.at(0).at(2), 2);

            QCOMPARE(signalsSpy.rowsInsertedSpy.count(), 1);

            QCOMPARE(model.rowCount(), 3);

            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 11);
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 12);
            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "key")), 13);
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "color")), "red");
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "color")), "blue");
            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "color")), "pink");
        }
    }

    void modelResetWhenNotEmptyWithPropagateResetsTest()
    {
        QQmlEngine engine;
        ConcatModel model;
        model.setPropagateResets(true);

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "color", "red" }},
            QJsonObject {{ "key", 2}, { "color", "blue" }}
        });
        ListModelWrapper sourceModel2(engine, QJsonArray {
            QJsonObject {{ "key", 3}},
            QJsonObject {{ "key", 4}},
            QJsonObject {{ "key", 5}}
        });
        ListModelWrapper sourceModel3(engine);

        ListModelWrapper sourceModel4(engine);
        ListModelWrapper sourceModel5(engine, QJsonArray {
            QJsonObject {{ "color", "red" }, { "name", "a" }, { "key", 11}},
            QJsonObject {{ "color", "blue" }, { "name", "b" }, { "key", 12}},
            QJsonObject {{ "color", "pink" }, { "name", "c" }, { "key", 13}}
        });

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2, source3;

        IdentityModel proxy1, proxy2, proxy3;

        proxy1.setSourceModel(sourceModel1);
        proxy2.setSourceModel(sourceModel2);
        proxy3.setSourceModel(sourceModel3);

        source1.setModel(&proxy1);
        source2.setModel(&proxy2);
        source3.setModel(&proxy3);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        auto roles = model.roleNames();

        QCOMPARE(model.rowCount(), 5);
        QCOMPARE(roles.count(), 3);

        // reset to empty model
        {
            ModelSignalsSpy signalsSpy(&model);

            // checking validity inside modelAboutToBeReset signal
            {
                QObject context;
                connect(&model, &ConcatModel::modelAboutToBeReset, &context,
                        [this, &model, &roles] {
                    QCOMPARE(model.rowCount(), 5);

                    QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "key")), 4);
                    QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "color")), {});
                });

                proxy2.setSourceModel(sourceModel4);
            }

            QCOMPARE(signalsSpy.count(), 2);

            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);

            QCOMPARE(model.rowCount(), 2);

            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 1);
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 2);
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "color")), "red");
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "color")), "blue");

            // insert some data to check if roles are re-initialized properly
            sourceModel4.append(QJsonArray {
                QJsonObject {{ "color", "purple"}, { "key", 3} },
                QJsonObject {{ "color", "green" }, { "key", 4}}
            });

            QCOMPARE(model.rowCount(), 4);

            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 1);
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 2);
            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "key")), 3);
            QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "key")), 4);
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "color")), "red");
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "color")), "blue");
            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "color")), "purple");
            QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "color")), "green");

            sourceModel4.clear();
        }
        // reset to not empty model
        {
            ModelSignalsSpy signalsSpy(&model);

            // checking validity inside modelAboutToBeReset signal
            {
                QObject context;
                connect(&model, &ConcatModel::modelAboutToBeReset, &context,
                        [this, &model, &roles] {
                    QCOMPARE(model.rowCount(), 2);

                    QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 1);
                    QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 2);
                    QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "color")), "red");
                    QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "color")), "blue");
                });

                proxy1.setSourceModel(sourceModel5);
            }

            QCOMPARE(signalsSpy.count(), 2);

            QCOMPARE(signalsSpy.modelAboutToBeResetSpy.count(), 1);
            QCOMPARE(signalsSpy.modelResetSpy.count(), 1);

            QCOMPARE(model.rowCount(), 3);

            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 11);
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 12);
            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "key")), 13);
            QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "color")), "red");
            QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "color")), "blue");
            QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "color")), "pink");
        }
    }

    void sameModelUsedMultipleTimesTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "color", "red" }},
            QJsonObject {{ "key", 2}, { "color", "blue" }}
        });

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2, source3;

        source1.setModel(sourceModel);
        source2.setModel(sourceModel);
        source3.setModel(sourceModel);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        auto roles = model.roleNames();

        QCOMPARE(model.rowCount(), 6);
        QCOMPARE(roles.count(), 3);

        QSignalSpy rowsAboutToBeInsertedSpy(
                    &model, &ConcatModel::rowsAboutToBeInserted);
        QSignalSpy rowsInsertedSpy(&model, &ConcatModel::rowsInserted);

        sourceModel.insert(1, QJsonObject {{ "key", 15 }, { "color", "black" }});

        QCOMPARE(model.rowCount(), 9);

        QCOMPARE(rowsAboutToBeInsertedSpy.count(), 3);
        QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(0), QModelIndex{});
        QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(1), 1);
        QCOMPARE(rowsAboutToBeInsertedSpy.at(0).at(2), 1);
        QCOMPARE(rowsAboutToBeInsertedSpy.at(1).at(0), QModelIndex{});
        QCOMPARE(rowsAboutToBeInsertedSpy.at(1).at(1), 3);
        QCOMPARE(rowsAboutToBeInsertedSpy.at(1).at(2), 3);
        QCOMPARE(rowsAboutToBeInsertedSpy.at(2).at(0), QModelIndex{});
        QCOMPARE(rowsAboutToBeInsertedSpy.at(2).at(1), 5);
        QCOMPARE(rowsAboutToBeInsertedSpy.at(2).at(2), 5);

        QCOMPARE(rowsInsertedSpy.count(), 3);
        QCOMPARE(rowsInsertedSpy.at(0).at(0), QModelIndex{});
        QCOMPARE(rowsInsertedSpy.at(0).at(1), 5);
        QCOMPARE(rowsInsertedSpy.at(0).at(2), 5);
        QCOMPARE(rowsInsertedSpy.at(1).at(0), QModelIndex{});
        QCOMPARE(rowsInsertedSpy.at(1).at(1), 3);
        QCOMPARE(rowsInsertedSpy.at(1).at(2), 3);
        QCOMPARE(rowsInsertedSpy.at(2).at(0), QModelIndex{});
        QCOMPARE(rowsInsertedSpy.at(2).at(1), 1);
        QCOMPARE(rowsInsertedSpy.at(2).at(2), 1);

        QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
        sourceModel.setProperty(0, "key", 0);

        QCOMPARE(model.rowCount(), 9);

        QCOMPARE(dataChangedSpy.count(), 3);
        QCOMPARE(dataChangedSpy.at(0).at(0), model.index(0, 0));
        QCOMPARE(dataChangedSpy.at(0).at(1), model.index(0, 0));
        QCOMPARE(dataChangedSpy.at(0).at(2).value<QVector<int>>(),
                 { roleForName(roles, "key") });

        QCOMPARE(dataChangedSpy.at(1).at(0), model.index(3, 0));
        QCOMPARE(dataChangedSpy.at(1).at(1), model.index(3, 0));
        QCOMPARE(dataChangedSpy.at(1).at(2).value<QVector<int>>(),
                 { roleForName(roles, "key") });

        QCOMPARE(dataChangedSpy.at(2).at(0), model.index(6, 0));
        QCOMPARE(dataChangedSpy.at(2).at(1), model.index(6, 0));
        QCOMPARE(dataChangedSpy.at(2).at(2).value<QVector<int>>(),
                 { roleForName(roles, "key") });

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "key")), 0);
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "key")), 15);
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "key")), 2);
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "key")), 0);
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "key")), 15);
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "key")), 2);
        QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "key")), 0);
        QCOMPARE(model.data(model.index(7, 0), roleForName(roles, "key")), 15);
        QCOMPARE(model.data(model.index(8, 0), roleForName(roles, "key")), 2);
    }

    void expectedRolesTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "key", 1}},
            QJsonObject {{ "key", 2}},
            QJsonObject {{ "key", 3}}
        });
        ListModelWrapper sourceModel2(engine, QJsonArray {
            QJsonObject {{ "key", 4}, { "color", "red" }, { "name", "name 1"}},
            QJsonObject {{ "key", 5}, { "color", "blue" }, { "name", "name 2"}}
        });
        ListModelWrapper sourceModel3(engine, QJsonArray {
            QJsonObject {{ "key", 6}, { "color", "red" }, { "value", 42}},
            QJsonObject {{ "key", 7}, { "color", "green" }, { "value", 43}}
        });

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2, source3;
        source1.setModel(sourceModel1);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);

        model.setExpectedRoles({"key", "color", "value"});

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.componentComplete();

        auto roles = model.roleNames();

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(roles.size(), 4);

        std::set<QByteArray> roleNamesSet(roles.cbegin(), roles.cend());
        std::set<QByteArray> expectedRoleNamesSet({"key", "color", "value", "whichModel"});
        QCOMPARE(roleNamesSet, expectedRoleNamesSet);

        source2.setModel(sourceModel2);
        source3.setModel(sourceModel3);

        QCOMPARE(model.rowCount(), 7);
    }

    void markerRoleTest()
    {
        QQmlEngine engine;
        ConcatModel model;

        ListModelWrapper sourceModel1(engine, QJsonArray {
            QJsonObject {{ "key", 1}, { "balance", 11 }, { "name", "n1" }},
            QJsonObject {{ "key", 2},{ "balance", 12 }, { "name", "n2" }},
            QJsonObject {{ "key", 3},{ "balance", 13}, { "name", "n3" }},
        });

        ListModelWrapper sourceModel2(engine, QJsonArray {});

        ListModelWrapper sourceModel3(engine, QJsonArray {
            QJsonObject {{ "balance", 14 }, { "name", "n4" }, { "color", "red"}},
            QJsonObject {{ "balance", 15 }, { "name", "n5" }, { "color", "green"}},
            QJsonObject {{ "balance", 16 }, { "name", "n6" }, { "color", "blue"}},
            QJsonObject {{ "balance", 17 }, { "name", "n7" }, { "color", "pink"}},
        });

        ListModelWrapper sourceModel4(engine, QJsonArray {});

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2, source3, source4;
        source1.setModel(sourceModel1);
        source2.setModel(sourceModel2);
        source3.setModel(sourceModel3);
        source4.setModel(sourceModel4);

        source1.setMarkerRoleValue("model 1");
        source2.setMarkerRoleValue("model 2");
        source3.setMarkerRoleValue("model 3");
        source4.setMarkerRoleValue("model 4");

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);
        sources.append(&sources, &source3);
        sources.append(&sources, &source4);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames(), {});
        QCOMPARE(model.index(0, 0).isValid(), false);

        model.setMarkerRoleName("marker");

        model.componentComplete();

        QCOMPARE(model.markerRoleName(), "marker");
        QCOMPARE(source1.markerRoleValue(), "model 1");
        QCOMPARE(source2.markerRoleValue(), "model 2");
        QCOMPARE(source3.markerRoleValue(), "model 3");
        QCOMPARE(source4.markerRoleValue(), "model 4");

        QTest::ignoreMessage(QtWarningMsg,
                             "Property \"markerRoleName\" is intended to be "
                             "initialized once before roles initialization "
                             "and not modified later.");
        model.setMarkerRoleName("marker2");

        QCOMPARE(model.markerRoleName(), "marker");

        auto roles = model.roleNames();

        QCOMPARE(model.rowCount(), 7);
        QCOMPARE(roles.size(), 5);
        QVERIFY(roleForName(roles, "marker") != -1);

        QCOMPARE(model.data(model.index(0, 0), roleForName(roles, "marker")), "model 1");
        QCOMPARE(model.data(model.index(1, 0), roleForName(roles, "marker")), "model 1");
        QCOMPARE(model.data(model.index(2, 0), roleForName(roles, "marker")), "model 1");
        QCOMPARE(model.data(model.index(3, 0), roleForName(roles, "marker")), "model 3");
        QCOMPARE(model.data(model.index(4, 0), roleForName(roles, "marker")), "model 3");
        QCOMPARE(model.data(model.index(5, 0), roleForName(roles, "marker")), "model 3");
        QCOMPARE(model.data(model.index(6, 0), roleForName(roles, "marker")), "model 3");

        {
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            source1.setMarkerRoleValue("model 1_");

            QCOMPARE(dataChangedSpy.count(), 1);
            QCOMPARE(dataChangedSpy.at(0).at(0), model.index(0, 0));
            QCOMPARE(dataChangedSpy.at(0).at(1), model.index(2, 0));
            QCOMPARE(dataChangedSpy.at(0).at(2).value<QVector<int>>(),
                     { roleForName(roles, "marker") });
        }
        {
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            source2.setMarkerRoleValue("model 2_");

            QCOMPARE(dataChangedSpy.count(), 0);
        }
        {
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            source3.setMarkerRoleValue("model 3_");

            QCOMPARE(dataChangedSpy.count(), 1);
            QCOMPARE(dataChangedSpy.at(0).at(0), model.index(3, 0));
            QCOMPARE(dataChangedSpy.at(0).at(1), model.index(6, 0));
            QCOMPARE(dataChangedSpy.at(0).at(2).value<QVector<int>>(),
                     { roleForName(roles, "marker") });
        }
        {
            QSignalSpy dataChangedSpy(&model, &ConcatModel::dataChanged);
            source4.setMarkerRoleValue("model 4_");

            QCOMPARE(dataChangedSpy.count(), 0);
        }
    }

    void sortingTest() {
        QQmlEngine engine;

        auto source1 = R"([
            { "name": "D", "subname": "d1" },
            { "name": "A", "subname": "a1" },
            { "name": "B", "subname": "b1" },
            { "name": "C", "subname": "c1" },
            { "name": "B", "subname": "b2" },
            { "name": "C", "subname": "c2" }
        ])";

        auto source2 = R"([
            { "name": "A", "subname": "a1" },
            { "name": "G", "subname": "g1" },
            { "name": "F", "subname": "f1" },
            { "name": "C", "subname": "c1" }
        ])";

        ListModelWrapper sourceModel1(engine, source1);
        ListModelWrapper sourceModel2(engine, source2);

        QSortFilterProxyModel sfpm1;
        sfpm1.setSourceModel(sourceModel1);

        QSortFilterProxyModel sfpm2;
        sfpm2.setSourceModel(sourceModel2);

        ConcatModel model;

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel sm1, sm2;
        sm1.setModel(&sfpm1);
        sm2.setModel(&sfpm2);

        sources.append(&sources, &sm1);
        sources.append(&sources, &sm2);

        model.componentComplete();

        ModelSignalsSpy signalsSpy(&model);
        PersistentIndexesTester indexesTester(&model);

        sfpm1.setSortRole(1);
        sfpm1.sort(0, Qt::AscendingOrder);

        sfpm2.setSortRole(1);
        sfpm2.sort(0, Qt::DescendingOrder);

        auto roles = model.roleNames();

        QCOMPARE(model.data(model.index(0), roleForName(roles, "subname")), "a1");
        QCOMPARE(model.data(model.index(1), roleForName(roles, "subname")), "b1");
        QCOMPARE(model.data(model.index(2), roleForName(roles, "subname")), "b2");
        QCOMPARE(model.data(model.index(3), roleForName(roles, "subname")), "c1");
        QCOMPARE(model.data(model.index(4), roleForName(roles, "subname")), "c2");
        QCOMPARE(model.data(model.index(5), roleForName(roles, "subname")), "d1");
        QCOMPARE(model.data(model.index(6), roleForName(roles, "subname")), "g1");
        QCOMPARE(model.data(model.index(7), roleForName(roles, "subname")), "f1");
        QCOMPARE(model.data(model.index(8), roleForName(roles, "subname")), "c1");
        QCOMPARE(model.data(model.index(9), roleForName(roles, "subname")), "a1");

        QCOMPARE(sfpm1.roleNames().value(1), "subname");
        QVERIFY(indexesTester.compare());
    }

    void layoutChangeWithRemovalTest() {
        ConcatModel model;

        TestModel sourceModel1({
            { "name", { "name 1_1", "name 1_2", "name 1_3", "name 1_4" }}
        });

        TestModel sourceModel2({
            { "name", { "name 2_1", "name 2_2", "name 2_3" }}
        });

        QQmlListProperty<SourceModel> sources = model.sources();

        SourceModel source1, source2;
        source1.setModel(&sourceModel1);
        source2.setModel(&sourceModel2);

        sources.append(&sources, &source1);
        sources.append(&sources, &source2);

        model.componentComplete();
        QCOMPARE(model.rowCount(), 7);

        QPersistentModelIndex pmi1 = model.index(0);
        QPersistentModelIndex pmi2 = model.index(1);
        QPersistentModelIndex pmi3 = model.index(2);
        QPersistentModelIndex pmi4 = model.index(3);
        QPersistentModelIndex pmi5 = model.index(4);
        QPersistentModelIndex pmi6 = model.index(5);
        QPersistentModelIndex pmi7 = model.index(6);

        sourceModel1.removeEverySecond();
        QCOMPARE(model.rowCount(), 5);

        QCOMPARE(pmi1.isValid(), false);
        QCOMPARE(pmi2.isValid(), true);
        QCOMPARE(pmi3.isValid(), false);
        QCOMPARE(pmi4.isValid(), true);
        QCOMPARE(pmi5.isValid(), true);
        QCOMPARE(pmi6.isValid(), true);
        QCOMPARE(pmi7.isValid(), true);

        QCOMPARE(pmi2.row(), 0);
        QCOMPARE(pmi4.row(), 1);
        QCOMPARE(pmi5.row(), 2);
        QCOMPARE(pmi6.row(), 3);
        QCOMPARE(pmi7.row(), 4);

        sourceModel2.removeEverySecond();
        QCOMPARE(model.rowCount(), 3);

        auto roles = model.roleNames();

        QCOMPARE(model.data(model.index(0), roleForName(roles, "name")), "name 1_2");
        QCOMPARE(model.data(model.index(1), roleForName(roles, "name")), "name 1_4");
        QCOMPARE(model.data(model.index(2), roleForName(roles, "name")), "name 2_2");

        QCOMPARE(pmi1.isValid(), false);
        QCOMPARE(pmi2.isValid(), true);
        QCOMPARE(pmi3.isValid(), false);
        QCOMPARE(pmi4.isValid(), true);
        QCOMPARE(pmi5.isValid(), false);
        QCOMPARE(pmi6.isValid(), true);
        QCOMPARE(pmi7.isValid(), false);

        QCOMPARE(pmi2.row(), 0);
        QCOMPARE(pmi4.row(), 1);
        QCOMPARE(pmi6.row(), 2);
    }

    void sfpmTest() {
        // This test reproduces in C++ situation that happens in the following
        // QML code. The initial filtering is notified from a SFPM as
        // a layoutAboutToBeChanged/layoutChanged signals with row count change.
        // Concat model must manage properly row count update and persistent
        // indexes.
        //
        //    import QtQuick 2.15
        //    import QtQuick.Controls 2.15
        //
        //    import StatusQ 0.1
        //    import SortFilterProxyModel 0.2
        //
        //    Item {
        //        ListModel {
        //            id: src
        //            ListElement { name: "A" }
        //            ListElement { name: "D" }
        //            ListElement { name: "A" }
        //            ListElement { name: "Z" }
        //            ListElement { name: "A" }
        //        }
        //        SortFilterProxyModel {
        //            id: sfpm
        //            sourceModel: src
        //            filters: ValueFilter {
        //                roleName: "name"
        //                value: "A"
        //            }
        //        }
        //        ConcatModel {
        //            id: concat
        //            sources: SourceModel { model: sfpm }
        //        }
        //        Flow {
        //            Repeater {
        //                model: concat
        //                Button { text: model.name }
        //            }
        //        }
        //    }

        QQmlEngine engine;

        TestModel sourceModel({
            { "name", { "A", "B", "A" }},
            { "subname", { "a1", "b1", "a2" }}
        });

        qqsfpm::QQmlSortFilterProxyModel sfpm;
        ConcatModel model;

        ModelSignalsSpy signalsSpy(&sfpm);

        sfpm.classBegin();
        model.classBegin();

        qqsfpm::ValueFilter filter;
        filter.setRoleName("name");
        filter.setValue("A");
        sfpm.appendFilter(&filter);

        QList<int> layoutAboutToBeChangedSizes;
        QList<int> layoutChangedSizes;

        connect(&sfpm, &QAbstractItemModel::layoutAboutToBeChanged, this,
                [&sfpm, &layoutAboutToBeChangedSizes]() {
              layoutAboutToBeChangedSizes << sfpm.rowCount();
        });

        connect(&sfpm, &QAbstractItemModel::layoutChanged, this,
                [&sfpm, &layoutChangedSizes]() {
            layoutChangedSizes << sfpm.rowCount();
        });

        QQmlListProperty<SourceModel> sources = model.sources();
        SourceModel sm;
        sm.setModel(&sfpm);
        sources.append(&sources, &sm);
        sfpm.setSourceModel(&sourceModel);

        // The crucial part is the fact that concat model is completed before
        // SFPM. It triggers filtering reported via
        // layoutAboutToBeChanged/layoutChanged. The same behavior can be observed
        // also for two SFPMs, it's not specific to ConcatModel.
        model.componentComplete();
        sfpm.componentComplete();

        QVERIFY(layoutAboutToBeChangedSizes.size() > 0);
        QVERIFY(layoutAboutToBeChangedSizes.size()
                == layoutChangedSizes.size());

        // Checking whether the assumed circumstances have occurred. There should
        // be at least one pair of layoutAboutToBeChanged/layoutChanged where
        // on layoutAboutToBeChanged the count is smaller than in the following
        // layoutChanged.
        QList<int> diffs;

        for (auto i = 0; i < layoutAboutToBeChangedSizes.size(); i++)
            diffs << std::abs(layoutAboutToBeChangedSizes[i]
                              - layoutChangedSizes[i]);

        QVERIFY(std::accumulate(diffs.cbegin(), diffs.cend(), 0) != 0);

        QCOMPARE(model.rowCount(), 2);

        auto roles = model.roleNames();

        QCOMPARE(model.data(model.index(0), roleForName(roles, "subname")), "a1");
        QCOMPARE(model.data(model.index(1), roleForName(roles, "subname")), "a2");
    }
};

QTEST_MAIN(TestConcatModel)
#include "tst_ConcatModel.moc"
