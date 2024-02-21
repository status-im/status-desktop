#include "modeltestutils.h"

#include <QDebug>

namespace {

bool isSame(const QAbstractItemModel& model1, const QAbstractItemModel& model2,
            bool recursive, bool printWarning)
{
    auto count1 = model1.rowCount();
    auto count2 = model2.rowCount();

    auto roleNames1 = model1.roleNames();
    auto roleNames2 = model2.roleNames();

    if (count1 != count2) {
        qWarning() << "Count mismatch:" << count1 << "/" << count2;
        return false;
    }

    if (roleNames1 != roleNames2) {
        qWarning() << "Role names mismatch:" << roleNames1 << "/" << roleNames2;
        return false;
    }

    auto roles = roleNames1.keys();

    for (auto role : roles) {
        for (int i = 0; i < count1; i++) {
            QVariant data1 = model1.data(model1.index(i, 0), role);
            QVariant data2 = model2.data(model2.index(i, 0), role);

            if (recursive && data1.canConvert<QAbstractItemModel*>()
                    && data2.canConvert<QAbstractItemModel*>()) {
                auto submodel1 = data1.value<QAbstractItemModel*>();
                auto submodel2 = data2.value<QAbstractItemModel*>();

                if (!isSame(*submodel1, *submodel2, true)) {
                    if (printWarning)
                        qWarning() << "submodels are not the same, index:"
                                   << i << roleNames1[role];
                    return false;
                }
            } else if (data1 != data2) {
                if (printWarning)
                    qWarning()
                            << QString("Mismatch at row %1, role '%2'. Model 1: %3, model 2: %4")
                               .arg(QString::number(i), QString(roleNames1[role]),
                                    data1.toString(), data2.toString());
                return false;
            }
        }
    }

    return true;
}

} // unnamed namespace

bool isSame(const QAbstractItemModel& model1, const QAbstractItemModel& model2,
            bool recursive)
{
    return isSame(model1, model2, recursive, true);
}

bool isSame(const QAbstractItemModel* model1, const QAbstractItemModel* model2,
            bool recursive)
{
    return isSame(*model1, *model2, recursive);
}

bool isNotSame(const QAbstractItemModel& model1, const QAbstractItemModel& model2,
            bool recursive)
{
    return !isSame(model1, model2, recursive, false);
}

bool isNotSame(const QAbstractItemModel* model1, const QAbstractItemModel* model2,
            bool recursive)
{
    return isNotSame(*model1, *model2, recursive);
}

