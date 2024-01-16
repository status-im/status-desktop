#include "modelsignalsspy.h"

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
