#pragma once

#include <QAbstractItemModel>
#include <QSignalSpy>

class ModelSignalsSpy
{
public:
    explicit ModelSignalsSpy(QAbstractItemModel* model);

    const QSignalSpy columnsAboutToBeInsertedSpy;
    const QSignalSpy columnsAboutToBeMovedSpy;
    const QSignalSpy columnsAboutToBeRemovedSpy;
    const QSignalSpy columnsInsertedSpy;
    const QSignalSpy columnsMovedSpy;
    const QSignalSpy columnsRemovedSpy;
    const QSignalSpy dataChangedSpy;
    const QSignalSpy headerDataChangedSpy;
    const QSignalSpy layoutAboutToBeChangedSpy;
    const QSignalSpy layoutChangedSpy;
    const QSignalSpy modelAboutToBeResetSpy;
    const QSignalSpy modelResetSpy;
    const QSignalSpy rowsAboutToBeInsertedSpy;
    const QSignalSpy rowsAboutToBeMovedSpy;
    const QSignalSpy rowsAboutToBeRemovedSpy;
    const QSignalSpy rowsInsertedSpy;
    const QSignalSpy rowsMovedSpy;
    const QSignalSpy rowsRemovedSpy;

    int count() const;
    void printDebugSummary() const;
};
