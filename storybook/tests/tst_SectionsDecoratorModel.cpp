#include <QSignalSpy>
#include <QTest>

#include <QAbstractListModel>
#include <QSortFilterProxyModel>

#include <sectionsdecoratormodel.h>

namespace {

class TestSourceModel : public QAbstractListModel {

public:
    explicit TestSourceModel(QStringList categories)
        : m_categories(std::move(categories))
    {
        for (int i = 0; i < m_categories.size(); i++)
            m_titles << QString("title %1").arg(i);
    }

    explicit TestSourceModel(QStringList categories, QStringList titles)
        : m_categories(std::move(categories)), m_titles(std::move(titles))
    {
    }

    static constexpr int TitleRole = Qt::UserRole + 1;
    static constexpr int CategoryRole = Qt::UserRole + 2;

    int rowCount(const QModelIndex &parent) const override {
        return m_categories.size();
    }

    QVariant data(const QModelIndex &index, int role) const override {
        if (!index.isValid())
            return {};

        const auto row = index.row();

        if (role == TitleRole)
            return m_titles.at(row);

        return m_categories.at(row);
    }

    void insert(int index, QString category, QString title)
    {
        beginInsertRows(QModelIndex{}, index, index);
        m_categories.insert(index, category);
        m_titles.insert(index, title);
        endInsertRows();
    }

    void remove(int index)
    {
        beginRemoveRows(QModelIndex{}, index, index);
        m_categories.removeAt(index);
        m_titles.removeAt(index);
        endRemoveRows();
    }

    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roles;
        roles.insert(TitleRole, "title");
        roles.insert(CategoryRole, "category");
        return roles;
    }

    QStringList m_categories;
    QStringList m_titles;
};

} // unnamed namespace

class TestSectionsDecoratorModel: public QObject
{
    Q_OBJECT

private slots:
    void emptyModelTest() {
        SectionsDecoratorModel model;

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames().count(), 4);
        QVERIFY(model.roleNames().contains(SectionsDecoratorModel::IsSectionRole));
        QVERIFY(model.roleNames().contains(SectionsDecoratorModel::IsFoldedRole));
        QVERIFY(model.roleNames().contains(SectionsDecoratorModel::SubitemsCountRole));
    }

    void emptySourceTest() {
        TestSourceModel src(QStringList{});
        SectionsDecoratorModel model;
        model.setSourceModel(&src);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames().count(), 6);
        QVERIFY(model.roleNames().contains(SectionsDecoratorModel::IsSectionRole));
        QVERIFY(model.roleNames().contains(SectionsDecoratorModel::IsFoldedRole));
        QVERIFY(model.roleNames().contains(SectionsDecoratorModel::SubitemsCountRole));
        QVERIFY(model.roleNames().contains(TestSourceModel::TitleRole));
        QVERIFY(model.roleNames().contains(TestSourceModel::CategoryRole));
    }

    void changingSourceModelHasNoEffectTest() {
        TestSourceModel src1(QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"});
        TestSourceModel src2(QStringList{});

        SectionsDecoratorModel model;

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames().count(), 4);

        model.setSourceModel(nullptr);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.roleNames().count(), 4);

        model.setSourceModel(&src1);

        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(model.roleNames().count(), 6);

        model.setSourceModel(&src2);

        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(model.roleNames().count(), 6);

        model.setSourceModel(nullptr);

        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(model.roleNames().count(), 6);
    }

    void initialUnfoldedStateTest() {
        TestSourceModel src(QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"});
        SectionsDecoratorModel model;
        model.setSourceModel(&src);

        QCOMPARE(model.rowCount(), 9);
        QCOMPARE(model.roleNames().count(), 6);

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
        QCOMPARE(model.roleNames().count(), 6);

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
        QCOMPARE(model.roleNames().count(), 6);

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
        QCOMPARE(model.roleNames().count(), 6);

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
        QCOMPARE(model.roleNames().count(), 6);

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
        QCOMPARE(model.roleNames().count(), 6);

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
        QCOMPARE(model.roleNames().count(), 6);

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
        QCOMPARE(model.roleNames().count(), 6);

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

        proxy.setFilterRole(TestSourceModel::TitleRole);
        proxy.setFilterWildcard("*1");

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.roleNames().count(), 6);

        QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
        QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("title 1"));

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsSectionRole).toBool(), true);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsSectionRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::IsFoldedRole).toBool(), false);

        QCOMPARE(model.data(model.index(0, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 1);
        QCOMPARE(model.data(model.index(1, 0), SectionsDecoratorModel::SubitemsCountRole).toInt(), 0);
    }

    void insertionTest() {
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(0, "Section 1", "New Title");
            QCOMPARE(model.rowCount(), 10);
            QCOMPARE(insertionSpy.count(), 1);
            QCOMPARE(changeSpy.count(), 1);

            auto insertionArguments = insertionSpy.takeFirst();
            QCOMPARE(insertionArguments.at(1).toInt(), 1);
            QCOMPARE(insertionArguments.at(2).toInt(), 1);

            auto changeArguments = changeSpy.takeFirst();
            QCOMPARE(changeArguments.at(0).toModelIndex(), model.index(0, 0));
            QCOMPARE(changeArguments.at(1).toModelIndex(), model.index(0, 0));

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("New Title"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(9, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(1, "Section 1", "New Title");
            QCOMPARE(model.rowCount(), 10);
            QCOMPARE(insertionSpy.count(), 1);

            auto insertionArguments = insertionSpy.takeFirst();
            QCOMPARE(insertionArguments.at(1).toInt(), 2);
            QCOMPARE(insertionArguments.at(2).toInt(), 2);

            auto changeArguments = changeSpy.takeFirst();
            QCOMPARE(changeArguments.at(0).toModelIndex(), model.index(0, 0));
            QCOMPARE(changeArguments.at(1).toModelIndex(), model.index(0, 0));

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("New Title"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(9, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(2, "Section 1", "New Title");
            QCOMPARE(model.rowCount(), 10);
            QCOMPARE(insertionSpy.count(), 1);

            auto insertionArguments = insertionSpy.takeFirst();
            QCOMPARE(insertionArguments.at(1).toInt(), 3);
            QCOMPARE(insertionArguments.at(2).toInt(), 3);

            auto changeArguments = changeSpy.takeFirst();
            QCOMPARE(changeArguments.at(0).toModelIndex(), model.index(0, 0));
            QCOMPARE(changeArguments.at(1).toModelIndex(), model.index(0, 0));

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("New Title"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(9, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(3, "Section 1", "New Title");
            QCOMPARE(model.rowCount(), 10);
            QCOMPARE(insertionSpy.count(), 1);

            auto insertionArguments = insertionSpy.takeFirst();
            QCOMPARE(insertionArguments.at(1).toInt(), 4);
            QCOMPARE(insertionArguments.at(2).toInt(), 4);

            auto changeArguments = changeSpy.takeFirst();
            QCOMPARE(changeArguments.at(0).toModelIndex(), model.index(0, 0));
            QCOMPARE(changeArguments.at(1).toModelIndex(), model.index(0, 0));

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole).toString(), QString("New Title"));
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(9, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(3, "Section 2", "New Title");
            QCOMPARE(model.rowCount(), 10);
            QCOMPARE(insertionSpy.count(), 1);

            auto insertionArguments = insertionSpy.takeFirst();
            QCOMPARE(insertionArguments.at(1).toInt(), 5);
            QCOMPARE(insertionArguments.at(2).toInt(), 5);

            auto changeArguments = changeSpy.takeFirst();
            QCOMPARE(changeArguments.at(0).toModelIndex(), model.index(4, 0));
            QCOMPARE(changeArguments.at(1).toModelIndex(), model.index(4, 0));

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("New Title"));
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(9, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(4, "Section 2", "New Title");
            QCOMPARE(model.rowCount(), 10);
            QCOMPARE(insertionSpy.count(), 1);

            auto insertionArguments = insertionSpy.takeFirst();
            QCOMPARE(insertionArguments.at(1).toInt(), 6);
            QCOMPARE(insertionArguments.at(2).toInt(), 6);

            auto changeArguments = changeSpy.takeFirst();
            QCOMPARE(changeArguments.at(0).toModelIndex(), model.index(4, 0));
            QCOMPARE(changeArguments.at(1).toModelIndex(), model.index(4, 0));

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("New Title"));
            QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(9, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(5, "Section 3", "New Title");
            QCOMPARE(model.rowCount(), 10);
            QCOMPARE(insertionSpy.count(), 1);

            auto insertionArguments = insertionSpy.takeFirst();
            QCOMPARE(insertionArguments.at(1).toInt(), 8);
            QCOMPARE(insertionArguments.at(2).toInt(), 8);

            auto changeArguments = changeSpy.takeFirst();
            QCOMPARE(changeArguments.at(0).toModelIndex(), model.index(7, 0));
            QCOMPARE(changeArguments.at(1).toModelIndex(), model.index(7, 0));

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole).toString(), QString("New Title"));
            QCOMPARE(model.data(model.index(9, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(6, "Section 3", "New Title");
            QCOMPARE(model.rowCount(), 10);
            QCOMPARE(insertionSpy.count(), 1);

            auto insertionArguments = insertionSpy.takeFirst();
            QCOMPARE(insertionArguments.at(1).toInt(), 9);
            QCOMPARE(insertionArguments.at(2).toInt(), 9);

            auto changeArguments = changeSpy.takeFirst();
            QCOMPARE(changeArguments.at(0).toModelIndex(), model.index(7, 0));
            QCOMPARE(changeArguments.at(1).toModelIndex(), model.index(7, 0));

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
            QCOMPARE(model.data(model.index(9, 0), TestSourceModel::TitleRole).toString(), QString("New Title"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);


            model.flipFolding(0);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(0, "Section 1", "New Title");
            QCOMPARE(model.rowCount(), 6);
            QCOMPARE(insertionSpy.count(), 0);
            QCOMPARE(changeSpy.count(), 1);

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);


            model.flipFolding(0);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(1, "Section 1", "New Title");
            QCOMPARE(model.rowCount(), 6);
            QCOMPARE(insertionSpy.count(), 0);
            QCOMPARE(changeSpy.count(), 1);

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);


            model.flipFolding(0);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(3, "Section 1", "New Title");
            QCOMPARE(model.rowCount(), 6);
            QCOMPARE(insertionSpy.count(), 0);
            QCOMPARE(changeSpy.count(), 1);

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);


            model.flipFolding(0);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(3, "Section 2", "New Title");
            QCOMPARE(model.rowCount(), 7);
            QCOMPARE(insertionSpy.count(), 1);

            QCOMPARE(changeSpy.count(), 1);

            auto changeArguments = changeSpy.takeFirst();
            QCOMPARE(changeArguments.at(0).toModelIndex(), model.index(1, 0));
            QCOMPARE(changeArguments.at(1).toModelIndex(), model.index(1, 0));

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("New Title"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);


            model.flipFolding(0);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(4, "Section 2", "New Title");
            QCOMPARE(model.rowCount(), 7);
            QCOMPARE(insertionSpy.count(), 1);
            QCOMPARE(changeSpy.count(), 1);

            auto changeArguments = changeSpy.takeFirst();
            QCOMPARE(changeArguments.at(0).toModelIndex(), model.index(1, 0));
            QCOMPARE(changeArguments.at(1).toModelIndex(), model.index(1, 0));

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("New Title"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(0, "Section 0", "New Title");
            QCOMPARE(model.rowCount(), 11);
            QCOMPARE(insertionSpy.count(), 1);
            QCOMPARE(changeSpy.count(), 0);

            auto arguments = insertionSpy.takeFirst();
            QCOMPARE(arguments.at(1).toInt(), 0);
            QCOMPARE(arguments.at(2).toInt(), 1);

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("New Title"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(9, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(10, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(3, "Section 0", "New Title");
            QCOMPARE(model.rowCount(), 11);
            QCOMPARE(insertionSpy.count(), 1);
            QCOMPARE(changeSpy.count(), 0);

            auto arguments = insertionSpy.takeFirst();
            QCOMPARE(arguments.at(1).toInt(), 4);
            QCOMPARE(arguments.at(2).toInt(), 5);

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("New Title"));
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(9, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(10, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(6, "Section 0", "New Title");
            QCOMPARE(model.rowCount(), 11);
            QCOMPARE(insertionSpy.count(), 1);
            QCOMPARE(changeSpy.count(), 0);

            auto arguments = insertionSpy.takeFirst();
            QCOMPARE(arguments.at(1).toInt(), 9);
            QCOMPARE(arguments.at(2).toInt(), 10);

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
            QCOMPARE(model.data(model.index(9, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(10, 0), TestSourceModel::TitleRole).toString(), QString("New Title"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            model.flipFolding(4);

            QSignalSpy insertionSpy(&model, &SectionsDecoratorModel::rowsInserted);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.insert(6, "Section 0", "New Title");
            QCOMPARE(model.rowCount(), 9);
            QCOMPARE(insertionSpy.count(), 1);
            QCOMPARE(changeSpy.count(), 0);

            auto arguments = insertionSpy.takeFirst();
            QCOMPARE(arguments.at(1).toInt(), 7);
            QCOMPARE(arguments.at(2).toInt(), 8);

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
            QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(8, 0), TestSourceModel::TitleRole).toString(), QString("New Title"));
        }
    }

    void removalTest() {
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy removalSpy(&model, &SectionsDecoratorModel::rowsRemoved);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.remove(0);
            QCOMPARE(model.rowCount(), 8);
            QCOMPARE(removalSpy.count(), 1);
            QCOMPARE(changeSpy.count(), 1);

            auto removalArguments = removalSpy.takeFirst();
            QCOMPARE(removalArguments.at(1).toInt(), 1);
            QCOMPARE(removalArguments.at(2).toInt(), 1);

            auto changeArguments = changeSpy.takeFirst();
            QCOMPARE(changeArguments.at(0).toModelIndex(), model.index(0, 0));
            QCOMPARE(changeArguments.at(1).toModelIndex(), model.index(0, 0));

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy removalSpy(&model, &SectionsDecoratorModel::rowsRemoved);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.remove(1);
            QCOMPARE(model.rowCount(), 8);
            QCOMPARE(removalSpy.count(), 1);
            QCOMPARE(changeSpy.count(), 1);

            auto removalArguments = removalSpy.takeFirst();
            QCOMPARE(removalArguments.at(1).toInt(), 2);
            QCOMPARE(removalArguments.at(2).toInt(), 2);

            auto changeArguments = changeSpy.takeFirst();
            QCOMPARE(changeArguments.at(0).toModelIndex(), model.index(0, 0));
            QCOMPARE(changeArguments.at(1).toModelIndex(), model.index(0, 0));

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy removalSpy(&model, &SectionsDecoratorModel::rowsRemoved);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.remove(2);
            QCOMPARE(model.rowCount(), 8);
            QCOMPARE(removalSpy.count(), 1);
            QCOMPARE(changeSpy.count(), 1);

            auto removalArguments = removalSpy.takeFirst();
            QCOMPARE(removalArguments.at(1).toInt(), 3);
            QCOMPARE(removalArguments.at(2).toInt(), 3);

            auto changeArguments = changeSpy.takeFirst();
            QCOMPARE(changeArguments.at(0).toModelIndex(), model.index(0, 0));
            QCOMPARE(changeArguments.at(1).toModelIndex(), model.index(0, 0));

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(7, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy removalSpy(&model, &SectionsDecoratorModel::rowsRemoved);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.remove(5);
            QCOMPARE(model.rowCount(), 7);
            QCOMPARE(removalSpy.count(), 1);
            QCOMPARE(changeSpy.count(), 0);

            auto removalArguments = removalSpy.takeFirst();
            QCOMPARE(removalArguments.at(1).toInt(), 7);
            QCOMPARE(removalArguments.at(2).toInt(), 8);

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy removalSpy(&model, &SectionsDecoratorModel::rowsRemoved);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.remove(3);
            QCOMPARE(model.rowCount(), 6);
            QCOMPARE(removalSpy.count(), 1);
            QCOMPARE(changeSpy.count(), 0);

            auto arguments = removalSpy.takeFirst();
            QCOMPARE(arguments.at(1).toInt(), 4);
            QCOMPARE(arguments.at(2).toInt(), 5);

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
        }
        {
            TestSourceModel src(QStringList{"Section 1"}, QStringList{"Title__ 1"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);

            QSignalSpy removalSpy(&model, &SectionsDecoratorModel::rowsRemoved);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.remove(0);
            QCOMPARE(model.rowCount(), 0);
            QCOMPARE(removalSpy.count(), 1);
            QCOMPARE(changeSpy.count(), 0);

            auto arguments = removalSpy.takeFirst();
            QCOMPARE(arguments.at(1).toInt(), 0);
            QCOMPARE(arguments.at(2).toInt(), 1);
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);
            model.flipFolding(0);

            QSignalSpy removalSpy(&model, &SectionsDecoratorModel::rowsRemoved);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.remove(0);
            QCOMPARE(model.rowCount(), 6);
            QCOMPARE(removalSpy.count(), 0);
            QCOMPARE(changeSpy.count(), 1);

            auto changeArguments = changeSpy.takeFirst();
            QCOMPARE(changeArguments.at(0).toModelIndex(), model.index(0, 0));
            QCOMPARE(changeArguments.at(1).toModelIndex(), model.index(0, 0));

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 6"));
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);
            model.flipFolding(0);
            model.flipFolding(1);
            model.flipFolding(2);

            QSignalSpy removalSpy(&model, &SectionsDecoratorModel::rowsRemoved);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.remove(1);
            QCOMPARE(model.rowCount(), 3);
            QCOMPARE(removalSpy.count(), 0);
            QCOMPARE(changeSpy.count(), 1);

            auto changeArguments = changeSpy.takeFirst();
            QCOMPARE(changeArguments.at(0).toModelIndex(), model.index(0, 0));
            QCOMPARE(changeArguments.at(1).toModelIndex(), model.index(0, 0));

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole), QVariant{});
        }
        {
            TestSourceModel src(
                        QStringList{"Section 1", "Section 1", "Section 1", "Section 2", "Section 2", "Section 3"},
                        QStringList{"Title__ 1", "Title__ 2", "Title__ 3", "Title__ 4", "Title__ 5", "Title__ 6"});

            SectionsDecoratorModel model;
            model.setSourceModel(&src);
            model.flipFolding(7);

            QSignalSpy removalSpy(&model, &SectionsDecoratorModel::rowsRemoved);
            QSignalSpy changeSpy(&model, &SectionsDecoratorModel::dataChanged);

            src.remove(5);
            QCOMPARE(model.rowCount(), 7);
            QCOMPARE(removalSpy.count(), 1);
            QCOMPARE(changeSpy.count(), 0);

            auto removalArguments = removalSpy.takeFirst();
            QCOMPARE(removalArguments.at(1).toInt(), 7);
            QCOMPARE(removalArguments.at(2).toInt(), 7);

            QCOMPARE(model.data(model.index(0, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(1, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 1"));
            QCOMPARE(model.data(model.index(2, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 2"));
            QCOMPARE(model.data(model.index(3, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 3"));
            QCOMPARE(model.data(model.index(4, 0), TestSourceModel::TitleRole), QVariant{});
            QCOMPARE(model.data(model.index(5, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 4"));
            QCOMPARE(model.data(model.index(6, 0), TestSourceModel::TitleRole).toString(), QString("Title__ 5"));
        }
    }
};

// TODO: signals emission testing using QSignalSpy

QTEST_MAIN(TestSectionsDecoratorModel)
#include "tst_SectionsDecoratorModel.moc"
