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

    function currentState() {
        if (visible.synced) {
            return writable.currentState()
        }
        return writable.currentState()
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

        for (var j = 0; j < newOrder.length; j++) {
            writable.set(writableIndexes[j], { "showcasePosition": j})
        }
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

        sourceModel: joined
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
}
