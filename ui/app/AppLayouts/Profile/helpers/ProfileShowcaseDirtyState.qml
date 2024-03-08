import QtQml 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

import utils 1.0

/**
  * Building block for managing temporary state in the "Profile Showcase"
  * functionality. Provides combining raw source model (like e.g. communities
  * model or accounts model) with lean showcase model (providing info regarding
  * visibility and position), managing dirty state (visibility, position) and
  * providing two output models - one containing visible items sorted by
  * position, second one containing hidden items.
  */
QObject {
    id: root

    property alias sourceModel: joined.leftModel
    property alias showcaseModel: joined.rightModel

    /**
      * True if the showcase model is in single model mode, i.e. the showcase
      * model is part of the source model. False if the showcase model is a
      * separate model.
      */
    property bool singleModelMode: !joined.rightModel

    /**
      * Model holding elements from 'sourceModel' intended to be visible in the
      * showcase, sorted by 'position' role. Includes roles from both input models.
      */
    readonly property alias visibleModel: visible

    /**
      * Model holding elements from 'sourceModel' intended to be hidden, no
      * sorting applied. Includes roles from both input models.
      */
    readonly property alias hiddenModel: hidden

    /**
      * Returns dirty state of the showcase model.
      */
    readonly property bool dirty: writable.dirty || !visibleModel.synced

    /**
      * It sets up a searcher filter on top of both the visible and hidden models.
      */
    property FastExpressionFilter searcherFilter

    function revert() {
        visible.syncOrder()
        writable.revert()
    }

    function currentState(roleNames = []) {
        if (visible.synced) {
            return writable.currentState(roleNames)
        }
        return writable.currentState(roleNames)
    }

    function setVisibility(key, visibility) {
        writable.setVisibility(key, visibility)
    }

    function changePosition(from, to) {
        visible.move(from, to)

        // Sync writable with movable new positions:
        const newOrder = visible.order()
        let writableIndexes = []

        for (var i = 0; i < newOrder.length; i++) {
            writableIndexes.push(visibleSFPM.mapToSource(newOrder[i]))
        }

        for (var i = 0; i < newOrder.length; i++) {
            writable.set(writableIndexes[i], { "showcasePosition": i})
        }
    }

    function append(obj) {
        writable.append(obj)
    }

    function remove(index) {
        const writableIndex = d.visibleIndexToWritable(index)
        writable.remove(writableIndex)
    }

    function update(index, obj) {
        const writableIndex = d.visibleIndexToWritable(index)
        writable.set(writableIndex, obj)
    }

    // internals, debug purpose only
    readonly property alias writable_: writable
    readonly property alias joined_: joined

    component HiddenFilter: AnyOf {
        UndefinedFilter {
            roleName: "showcaseVisibility"
        }

        ValueFilter {
            roleName: "showcaseVisibility"
            value: Constants.ShowcaseVisibility.NoOne
        }
    }

    LeftJoinModel {
        id: joined

        joinRole: "showcaseKey"
    }

    VisibilityAndPositionDirtyStateModel {
        id: writable

        sourceModel: root.singleModelMode ? root.sourceModel : joined
        visibilityHidden: Constants.ShowcaseVisibility.NoOne
    }

    SortFilterProxyModel {
        id: visibleSFPM

        sourceModel: writable
        delayed: true

        filters: HiddenFilter { inverted: true }
        sorters: RoleSorter { roleName: "showcasePosition" }
    }

    SortFilterProxyModel {
        id: searcherVisibleSFPM

        sourceModel: visibleSFPM
        delayed: true
        filters: root.searcherFilter
    }

    MovableModel {
        id: visible

        sourceModel: searcherVisibleSFPM
    }

    SortFilterProxyModel {
        id: searcherHiddenSFPM

        sourceModel: writable
        delayed: true
        filters: root.searcherFilter
    }

    SortFilterProxyModel {
        id: hidden

        sourceModel: searcherHiddenSFPM
        delayed: true

        filters: HiddenFilter {}
    }

    QtObject {
        id: d

        function visibleIndexToWritable(index) {
            const newOrder = visible.order()
            const sfpmIndex = newOrder[index]

            return visibleSFPM.mapToSource(sfpmIndex)
        }
    }
}
