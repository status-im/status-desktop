#include "modelsignalsspy.h"

#include <QDebug>

namespace {

using QAIM = QAbstractItemModel;

void registerMetaTypes() {
    // register types to avoid warnings regarding signal params
    qRegisterMetaType<QList<QPersistentModelIndex>>();
    qRegisterMetaType<QAbstractItemModel::LayoutChangeHint>();
    qRegisterMetaType<Qt::Orientation>();
}

} // unnamed namespace

ModelSignalsSpy::ModelSignalsSpy(QAbstractItemModel* model)
    : columnsAboutToBeInsertedSpy((registerMetaTypes(), model),
                                  &QAIM::columnsAboutToBeInserted),
      columnsAboutToBeMovedSpy(model, &QAIM::columnsAboutToBeInserted),
      columnsAboutToBeRemovedSpy(model, &QAIM::columnsAboutToBeRemoved),
      columnsInsertedSpy(model, &QAIM::columnsInserted),
      columnsMovedSpy(model, &QAIM::columnsMoved),
      columnsRemovedSpy(model, &QAIM::columnsRemoved),
      dataChangedSpy(model, &QAIM::dataChanged),
      headerDataChangedSpy(model, &QAIM::headerDataChanged),
      layoutAboutToBeChangedSpy(model, &QAIM::layoutAboutToBeChanged),
      layoutChangedSpy(model, &QAIM::layoutChanged),
      modelAboutToBeResetSpy(model, &QAIM::modelAboutToBeReset),
      modelResetSpy(model, &QAIM::modelReset),
      rowsAboutToBeInsertedSpy(model, &QAIM::rowsAboutToBeInserted),
      rowsAboutToBeMovedSpy(model, &QAIM::rowsAboutToBeMoved),
      rowsAboutToBeRemovedSpy(model, &QAIM::rowsAboutToBeRemoved),
      rowsInsertedSpy(model, &QAIM::rowsInserted),
      rowsMovedSpy(model, &QAIM::rowsMoved),
      rowsRemovedSpy(model, &QAIM::rowsRemoved)
{
}

int ModelSignalsSpy::count() const
{
    return columnsAboutToBeInsertedSpy.count()
            + columnsAboutToBeMovedSpy.count()
            + columnsAboutToBeRemovedSpy.count()
            + columnsInsertedSpy.count()
            + columnsMovedSpy.count()
            + columnsRemovedSpy.count()
            + dataChangedSpy.count()
            + headerDataChangedSpy.count()
            + layoutAboutToBeChangedSpy.count()
            + layoutChangedSpy.count()
            + modelAboutToBeResetSpy.count()
            + modelResetSpy.count()
            + rowsAboutToBeInsertedSpy.count()
            + rowsAboutToBeMovedSpy.count()
            + rowsAboutToBeRemovedSpy.count()
            + rowsInsertedSpy.count()
            + rowsMovedSpy.count()
            + rowsRemovedSpy.count();
}

void ModelSignalsSpy::printDebugSummary() const
{
    qDebug() << "TOTAL:" << count();

    if (auto c = columnsAboutToBeInsertedSpy.count())
        qDebug() << "columnsAboutToBeInserted:" << c;
    if (auto c = columnsAboutToBeMovedSpy.count())
        qDebug() << "columnsAboutToBeMoved:" << c;
    if (auto c = columnsAboutToBeRemovedSpy.count())
        qDebug() << "columnsAboutToBeRemoved:" << c;
    if (auto c = columnsInsertedSpy.count())
        qDebug() << "columnsInserted:" << c;
    if (auto c = columnsMovedSpy.count())
        qDebug() << "columnsMoved:" << c;
    if (auto c = columnsRemovedSpy.count())
        qDebug() << "columnsRemoved:" << c;
    if (auto c = dataChangedSpy.count())
        qDebug() << "dataChanged:" << c;
    if (auto c = headerDataChangedSpy.count())
        qDebug() << "headerDataChanged:" << c;
    if (auto c = layoutAboutToBeChangedSpy.count())
        qDebug() << "layoutAboutToBeChanged:" << c;
    if (auto c = layoutChangedSpy.count())
        qDebug() << "layoutChanged:" << c;
    if (auto c = modelAboutToBeResetSpy.count())
        qDebug() << "modelAboutToBeReset:" << c;
    if (auto c = modelResetSpy.count())
        qDebug() << "modelReset:" << c;
    if (auto c = rowsAboutToBeInsertedSpy.count())
        qDebug() << "rowsAboutToBeInserted:" << c;
    if (auto c = rowsAboutToBeMovedSpy.count())
        qDebug() << "rowsAboutToBeMoved:" << c;
    if (auto c = rowsAboutToBeRemovedSpy.count())
        qDebug() << "rowsAboutToBeRemoved:" << c;
    if (auto c = rowsInsertedSpy.count())
        qDebug() << "rowsInserted:" << c;
    if (auto c = rowsMovedSpy.count())
        qDebug() << "rowsMoved:" << c;
    if (auto c = rowsRemovedSpy.count())
        qDebug() << "rowsRemoved:" << c;
}
