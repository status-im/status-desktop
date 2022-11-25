#include <QSignalSpy>
#include <QTest>
#include <QTemporaryFile>
#include <QStringListModel>

#include "figmadecoratormodel.h"
#include "figmalinks.h"
#include "figmalinksmodel.h"
#include "figmalinkssource.h"

namespace {

auto constexpr sampleJson1 = R"(
{
    "Component_1": [
        "link_1", "link_2"
    ],
    "Component_2": [
        "link_3", "link_4"
    ]
}
)";

auto constexpr sampleJson2 = R"(
{
    "Component_1": [
        "link_1"
    ],
    "Component_2": [
        "link_3", "link_5"
    ]
}
)";

class TestSourceModel : public QAbstractListModel {

public:
    static constexpr auto TitleRole = 0;

    TestSourceModel(int count = 1) : m_count(count) {}

    int rowCount(const QModelIndex &parent = QModelIndex()) const override {
        return m_count;
    }

    QVariant data(const QModelIndex &index, int role) const override {
        if (!index.isValid())
            return {};

        return QString("title_%1").arg(index.row());
    }

    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roles;
        roles.insert(TitleRole, QByteArrayLiteral("title"));
        return roles;
    }

    int m_count;
};

} // unnamed namespace

class FigmaDecoratorModelTest: public QObject
{
    Q_OBJECT

private slots:
    void readingFigmaFileTest() {
        FigmaLinksSource figmaLinksSource;

        QSignalSpy spy(&figmaLinksSource, &FigmaLinksSource::figmaLinksChanged);

        QCOMPARE(figmaLinksSource.getFigmaLinks(), nullptr);

        QTemporaryFile file;
        if (file.open()) {
            QTextStream stream(&file);
            stream << sampleJson1;
        }

        figmaLinksSource.setFilePath(file.fileName());

        QVERIFY(figmaLinksSource.getFigmaLinks() != nullptr);

        const FigmaLinks *links = figmaLinksSource.getFigmaLinks();

        QCOMPARE(links->getLinksMap(), (QMap<QString, QStringList> {
                                            {{"Component_1"}, {"link_1", "link_2"}},
                                            {{"Component_2"}, {"link_3", "link_4"}}}));
        QCOMPARE(spy.count(), 1);

        QTemporaryFile file2;
        if (file2.open()) {
            QTextStream stream(&file2);
            stream << sampleJson2;
        }

        figmaLinksSource.setFilePath(file2.fileName());

        QVERIFY(figmaLinksSource.getFigmaLinks() != nullptr);

        const FigmaLinks *links2 = figmaLinksSource.getFigmaLinks();

        QCOMPARE(links2->getLinksMap(), (QMap<QString, QStringList> {
                                             {{"Component_1"}, {"link_1"}},
                                             {{"Component_2"}, {"link_3", "link_5"}}}));
        QCOMPARE(spy.count(), 2);
    }

    void readingAfterFigmaFileChangedTest() {

        FigmaLinksSource figmaLinksSource;

        QSignalSpy spy(&figmaLinksSource, &FigmaLinksSource::figmaLinksChanged);

        QCOMPARE(figmaLinksSource.getFigmaLinks(), nullptr);

        QTemporaryFile file;
        if (file.open()) {
            QTextStream stream(&file);
            stream << sampleJson1;
        }

        figmaLinksSource.setFilePath(file.fileName());

        QVERIFY(figmaLinksSource.getFigmaLinks() != nullptr);

        const FigmaLinks *links = figmaLinksSource.getFigmaLinks();

        QCOMPARE(links->getLinksMap(), (QMap<QString, QStringList> {
                                            {{"Component_1"}, {"link_1", "link_2"}},
                                            {{"Component_2"}, {"link_3", "link_4"}}}));

        QCOMPARE(spy.count(), 1);

        if (QFile f(file.fileName());
                f.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            QTextStream stream(&f);
            stream << sampleJson2;
        }

        QVERIFY(spy.wait());
        QCOMPARE(spy.count(), 2);

        const FigmaLinks *links2 = figmaLinksSource.getFigmaLinks();

        QCOMPARE(links2->getLinksMap(), (QMap<QString, QStringList> {
                                             {{"Component_1"}, {"link_1"}},
                                             {{"Component_2"}, {"link_3", "link_5"}}}));


        if (QFile f(file.fileName());
                f.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            QTextStream stream(&f);
            stream << sampleJson1;
        }

        QVERIFY(spy.wait());
        QCOMPARE(spy.count(), 3);

        const FigmaLinks *links3 = figmaLinksSource.getFigmaLinks();

        QCOMPARE(links3->getLinksMap(), (QMap<QString, QStringList> {
                                             {{"Component_1"}, {"link_1", "link_2"}},
                                             {{"Component_2"}, {"link_3", "link_4"}}}));
    }

    void emptyFigmaModelTest() {
        FigmaDecoratorModel model;
        QCOMPARE(model.rowCount(), 0);
        QVERIFY(model.roleNames().contains(FigmaDecoratorModel::FigmaRole));
        QCOMPARE(model.roleNames().value(
                     FigmaDecoratorModel::FigmaRole), QStringLiteral("figma"));
    }

    void figmaModelWithoutSourceModel() {
        FigmaLinks links({
            {{"Component_1"}, {"link_1", "link_2"}},
            {{"Component_2"}, {"link_3", "link_4"}}
        });

        FigmaDecoratorModel model;
        model.setFigmaLinks(&links);

        QCOMPARE(model.rowCount(), 0);
        QVERIFY(model.roleNames().contains(FigmaDecoratorModel::FigmaRole));
        QCOMPARE(model.roleNames().value(
                     FigmaDecoratorModel::FigmaRole), QStringLiteral("figma"));
    }

    void figmaModelWithIncompatibleSourceModel() {
        QStringListModel stringsModel({"s1", "s2"});
        FigmaDecoratorModel model;

        QTest::ignoreMessage(QtWarningMsg,
                             "The source model is missing title role!");
        model.setSourceModel(&stringsModel);

        QCOMPARE(model.rowCount(), 2);
        QVERIFY(model.roleNames().contains(FigmaDecoratorModel::FigmaRole));
        QCOMPARE(model.roleNames().value(
                     FigmaDecoratorModel::FigmaRole), QStringLiteral("figma"));

        QCOMPARE(model.data(
                     model.index(0, 0),
                     FigmaDecoratorModel::FigmaRole)
                 .value<QAbstractItemModel*>()->rowCount(), 0);
    }

    void figmaModelWithoutLinksTest() {
        TestSourceModel sourceModel;
        FigmaDecoratorModel model;

        model.setSourceModel(&sourceModel);

        QCOMPARE(model.rowCount(), 1);
        QCOMPARE(model.roleNames().count(), 2);
        QVERIFY(model.roleNames().contains(FigmaDecoratorModel::FigmaRole));
        QCOMPARE(model.roleNames().value(
                     FigmaDecoratorModel::FigmaRole), QStringLiteral("figma"));

        QCOMPARE(model.data(
                     model.index(0, 0),
                     FigmaDecoratorModel::FigmaRole)
                 .value<QAbstractItemModel*>()->rowCount(), 0);
    }

    void figmaModelTest() {
        TestSourceModel sourceModel{2};
        FigmaLinks links({
            {{"title_0"}, {"link_1", "link_2"}},
            {{"title_x"}, {"link_3", "link_4"}}
        });

        FigmaDecoratorModel model;

        QSignalSpy spy(&model, &FigmaDecoratorModel::dataChanged);

        model.setSourceModel(&sourceModel);

        QCOMPARE(spy.size(), 0);

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.roleNames().count(), 2);
        QVERIFY(model.roleNames().contains(FigmaDecoratorModel::FigmaRole));
        QVERIFY(model.roleNames().contains(TestSourceModel::TitleRole));

        QCOMPARE(model.roleNames().value(
                     FigmaDecoratorModel::FigmaRole), QStringLiteral("figma"));
        QCOMPARE(model.roleNames().value(
                     TestSourceModel::TitleRole), QStringLiteral("title"));

        QCOMPARE(model.data(model.index(0, 0),
                            TestSourceModel::TitleRole).toString(), "title_0");
        QCOMPARE(model.data(model.index(1, 0),
                            TestSourceModel::TitleRole).toString(), "title_1");

        auto figmaLinksModel1 = model.data(model.index(0, 0), FigmaDecoratorModel::FigmaRole)
                .value<QAbstractItemModel*>();

        QVERIFY(figmaLinksModel1 != nullptr);
        QCOMPARE(figmaLinksModel1->rowCount(), 0);

        auto figmaLinksModel2 = model.data(model.index(1, 0), FigmaDecoratorModel::FigmaRole)
                .value<QAbstractItemModel*>();

        QVERIFY(figmaLinksModel2 != nullptr);
        QCOMPARE(figmaLinksModel2->rowCount(), 0);

        QSignalSpy linksModelspy1(figmaLinksModel1,
                                  &QAbstractItemModel::modelReset);
        QSignalSpy linksModelspy2(figmaLinksModel2,
                                  &QAbstractItemModel::modelReset);

        model.setFigmaLinks(&links);

        QCOMPARE(spy.size(), 0);

        QCOMPARE(linksModelspy1.size(), 1);
        QCOMPARE(linksModelspy2.size(), 0);

        QCOMPARE(model.data(model.index(0, 0), FigmaDecoratorModel::FigmaRole)
                .value<QAbstractItemModel*>(), figmaLinksModel1);
        QCOMPARE(model.data(model.index(1, 0), FigmaDecoratorModel::FigmaRole)
                .value<QAbstractItemModel*>(), figmaLinksModel2);

        QCOMPARE(figmaLinksModel1->rowCount(), 2);
        QCOMPARE(figmaLinksModel2->rowCount(), 0);

        QCOMPARE(model.data(model.index(0, 0),
                            TestSourceModel::TitleRole).toString(), "title_0");
        QCOMPARE(model.data(model.index(1, 0),
                            TestSourceModel::TitleRole).toString(), "title_1");

        QCOMPARE(figmaLinksModel1->roleNames().size(), 1);
        QCOMPARE(figmaLinksModel2->roleNames().size(), 1);

        QCOMPARE(figmaLinksModel1->data(figmaLinksModel1->index(0, 0),
                                        FigmaLinksModel::LinkRole).toString(), "link_1");
        QCOMPARE(figmaLinksModel1->data(figmaLinksModel1->index(1, 0),
                                        FigmaLinksModel::LinkRole).toString(), "link_2");

        model.setFigmaLinks(nullptr);

        QCOMPARE(spy.size(), 0);
        QCOMPARE(linksModelspy1.size(), 2);
        QCOMPARE(linksModelspy2.size(), 0);

        QCOMPARE(model.data(model.index(0, 0), FigmaDecoratorModel::FigmaRole)
                .value<QAbstractItemModel*>(), figmaLinksModel1);
        QCOMPARE(model.data(model.index(1, 0), FigmaDecoratorModel::FigmaRole)
                .value<QAbstractItemModel*>(), figmaLinksModel2);

        QCOMPARE(figmaLinksModel1->rowCount(), 0);
        QCOMPARE(figmaLinksModel2->rowCount(), 0);
    }
};

QTEST_MAIN(FigmaDecoratorModelTest)
#include "tst_FigmaDecoratorModel.moc"
