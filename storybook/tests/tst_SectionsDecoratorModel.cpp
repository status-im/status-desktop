#include <QSignalSpy>
#include <QTest>

#include <QAbstractListModel>
#include <QSortFilterProxyModel>

#include <sectionsdecoratormodel.h>

namespace {

class TestSourceModel : public QAbstractListModel {

public:
    explicit TestSourceModel(QStringList sections)
        : m_sections(std::move(sections))
    {
    }

    static constexpr int TitleRole = Qt::UserRole + 1;
    static constexpr int SectionRole = Qt::UserRole + 2;

    int rowCount(const QModelIndex &parent) const override {
        return m_sections.size();
    }

    QVariant data(const QModelIndex &index, int role) const override {
        if (!index.isValid())
            return {};

        if (role == TitleRole) {
            return QString("title %1").arg(index.row());
        }

        return m_sections.at(index.row());
    }

    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roles;
        roles.insert(TitleRole, "title");
        roles.insert(SectionRole, "section");
        return roles;
    }

    QStringList m_sections;
};

} // unnamed namespace

class TestSectionsDecoratorModel: public QObject
{
    Q_OBJECT

private slots:
    void emptyModelTest() {
        SectionsDecoratorModel model;

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames().count(), 3);
        QVERIFY(model.roleNames().contains(SectionsDecoratorModel::IsSectionRole));
        QVERIFY(model.roleNames().contains(SectionsDecoratorModel::IsFoldedRole));
        QVERIFY(model.roleNames().contains(SectionsDecoratorModel::SubitemsCountRole));
    }

    void emptySourceTest() {
        TestSourceModel src(QStringList{});
        SectionsDecoratorModel model;
        model.setSourceModel(&src);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames().count(), 5);
        QVERIFY(model.roleNames().contains(SectionsDecoratorModel::IsSectionRole));
        QVERIFY(model.roleNames().contains(SectionsDecoratorModel::IsFoldedRole));
        QVERIFY(model.roleNames().contains(SectionsDecoratorModel::SubitemsCountRole));
        QVERIFY(model.roleNames().contains(TestSourceModel::TitleRole));
        QVERIFY(model.roleNames().contains(TestSourceModel::SectionRole));
    }

    void changingSourceModelHasNoEffectTest() {
        TestSourceModel src1(QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"});
        TestSourceModel src2(QStringList{});

        SectionsDecoratorModel model;

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames().count(), 3);

        model.setSourceModel(nullptr);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames().count(), 3);

        model.setSourceModel(&src1);

        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(model.roleNames().count(), 5);

        model.setSourceModel(&src2);

        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(model.roleNames().count(), 5);

        model.setSourceModel(nullptr);

        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(model.roleNames().count(), 5);
    }

    void initialUnfoldedStateTest() {
        TestSourceModel src(QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"});
        SectionsDecoratorModel model;
        model.setSourceModel(&src);

        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(model.roleNames().count(), 5);

        QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("title 0"));
        QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("title 1"));
        QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("title 2"));
        QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("title 3"));
        QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("title 4"));
        QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole).toString(), QString("title 5"));

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 3);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 2);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 1);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
    }

    void foldingFromTopToBottomTest() {
        TestSourceModel src(QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"});
        SectionsDecoratorModel model;
        model.setSourceModel(&src);

        model.flipFolding(0);

        QCOMPARE(model.rowCount(), 6);
        QCOMPARE(model.roleNames().count(), 5);

        QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("title 3"));
        QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("title 4"));
        QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("title 5"));

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 3);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 2);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 1);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);

        model.flipFolding(1);
        QCOMPARE(model.rowCount(), 4);

        QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("title 5"));

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), true);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 3);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 2);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 1);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);

        model.flipFolding(2);

        QCOMPARE(model.rowCount(), 3);

        QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole), QVariant{});

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), true);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), true);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 3);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 2);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 1);
    }

    void foldingFromBottomToTopTest() {
        TestSourceModel src(QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"});
        SectionsDecoratorModel model;
        model.setSourceModel(&src);
        model.flipFolding(7);

        QCOMPARE(model.rowCount(), 8);
        QCOMPARE(model.roleNames().count(), 5);

        QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("title 0"));
        QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("title 1"));
        QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("title 2"));
        QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("title 3"));
        QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("title 4"));
        QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole), QVariant{});

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), true);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 3);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 2);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 1);

        model.flipFolding(4);

        QCOMPARE(model.rowCount(), 6);
        QCOMPARE(model.roleNames().count(), 5);

        QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("title 0"));
        QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("title 1"));
        QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("title 2"));
        QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole), QVariant{});

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), true);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), true);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 3);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 2);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 1);

        model.flipFolding(0);

        QCOMPARE(model.rowCount(), 3);
        QCOMPARE(model.roleNames().count(), 5);

        QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole), QVariant{});

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), true);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), true);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 3);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 2);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 1);
    }

    void flipFoldingForNonSectionHasNoEffecttest() {

        TestSourceModel src(QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"});
        SectionsDecoratorModel model;
        model.setSourceModel(&src);

        QCOMPARE(model.rowCount(), 9);

        QSignalSpy modelResetSpy(&model, &SectionsDecoratorModel::modelReset);
        QSignalSpy rowsInsertedSpy(&model, &SectionsDecoratorModel::rowsInserted);
        QSignalSpy rowsRemovedSpy(&model, &SectionsDecoratorModel::rowsRemoved);

        model.flipFolding(9);
        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
        QCOMPARE(rowsRemovedSpy.count(), 0);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        model.flipFolding(1000);
        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
        QCOMPARE(rowsRemovedSpy.count(), 0);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        model.flipFolding(-1);
        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
        QCOMPARE(rowsRemovedSpy.count(), 0);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        model.flipFolding(-1000);
        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
        QCOMPARE(rowsRemovedSpy.count(), 0);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        model.flipFolding(1);
        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
        QCOMPARE(rowsRemovedSpy.count(), 0);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        model.flipFolding(2);
        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
        QCOMPARE(rowsRemovedSpy.count(), 0);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        model.flipFolding(3);
        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
        QCOMPARE(rowsRemovedSpy.count(), 0);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        model.flipFolding(1);
        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
        QCOMPARE(rowsRemovedSpy.count(), 0);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        model.flipFolding(2);
        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
        QCOMPARE(rowsRemovedSpy.count(), 0);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        model.flipFolding(3);
        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
        QCOMPARE(rowsRemovedSpy.count(), 0);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        model.flipFolding(8);
        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(modelResetSpy.count(), 0);
        QCOMPARE(rowsInsertedSpy.count(), 0);
        QCOMPARE(rowsRemovedSpy.count(), 0);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
    }

    void unfoldingTest() {
        TestSourceModel src(QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"});
        SectionsDecoratorModel model;
        model.setSourceModel(&src);

        model.flipFolding(0);
        model.flipFolding(1);
        model.flipFolding(2);

        model.flipFolding(2);
        model.flipFolding(1);
        model.flipFolding(0);

        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(model.roleNames().count(), 5);

        QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("title 0"));
        QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("title 1"));
        QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("title 2"));
        QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("title 3"));
        QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("title 4"));
        QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole).toString(), QString("title 5"));

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 3);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 2);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 1);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);

        model.flipFolding(0);
        model.flipFolding(1);
        model.flipFolding(2);

        model.flipFolding(0);
        model.flipFolding(4);
        model.flipFolding(7);

        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(model.roleNames().count(), 5);

        QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("title 0"));
        QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("title 1"));
        QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("title 2"));
        QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("title 3"));
        QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("title 4"));
        QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole).toString(), QString("title 5"));

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 3);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 2);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 1);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
    }

    void basicFilteringTest() {
        TestSourceModel src(QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"});

        QSortFilterProxyModel proxy;
        proxy.setSourceModel(&src);

        SectionsDecoratorModel model;
        model.setSourceModel(&proxy);

        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(model.roleNames().count(), 5);

        QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("title 0"));
        QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("title 1"));
        QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("title 2"));
        QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("title 3"));
        QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("title 4"));
        QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole).toString(), QString("title 5"));

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(6, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 3);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(2, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(3, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(4, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 2);
        QCOMPARE(model.data(model.index(5, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
        QCOMPARE(model.data(model.index(7, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 1);
        QCOMPARE(model.data(model.index(8, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
    }

    void filteringTest() {
        TestSourceModel src(QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"});

        QSortFilterProxyModel proxy;
        proxy.setSourceModel(&src);

        SectionsDecoratorModel model;
        model.setSourceModel(&proxy);

        QSignalSpy spy(&model, &SectionsDecoratorModel::modelReset);

        proxy.setFilterRole(TestSourceModel::TitleRole);
        proxy.setFilterWildcard("*1");

        QVERIFY(spy.count() > 1);

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.roleNames().count(), 5);

        QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("title 1"));

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 1);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
    }
};

// TODO: signals emission testing using QSignalSpy

QTEST_MAIN(TestSectionsDecoratorModel)
#include "tst_SectionsDecoratorModel.moc"
