import QtQml

import StatusQ
import StatusQ.Core.Utils

import SortFilterProxyModel

import utils

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

    property alias sourceModel: writable.sourceModel
    /**
      * Model holding elements from 'sourceModel' intended to be visible in the
      * showcase, sorted by 'position' role. Includes roles from both input models.
      */
    readonly property alias visibleModel: visibleSFPM

    /**
      * Model holding elements from 'sourceModel' intended to be hidden, no
      * sorting applied. Includes roles from both input models.
      */
    readonly property alias hiddenModel: hidden

    /**
      * Returns dirty state of the showcase model.
      */
    readonly property bool dirty: writable.dirty

    function revert() {
        writable.revert()
    }

    function currentState(roleNames = []) {
        return writable.currentState(roleNames)
    }

    function setVisibility(key, visibility) {
        writable.setVisibility(key, visibility)
    }

    function changePosition(from, to) {
        const writableIndex = d.visibleIndexToWritable(from)
        writable.changePosition(writableIndex, to)
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

    component HiddenFilter: AnyOf {
        UndefinedFilter {
            roleName: "showcaseVisibility"
        }

        ValueFilter {
            roleName: "showcaseVisibility"
            value: Constants.ShowcaseVisibility.NoOne
        }
    }

    VisibilityAndPositionDirtyStateModel {
        id: writable

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
        id: hidden

        sourceModel: writable
        delayed: true

        filters: HiddenFilter {}
    }

    QtObject {
        id: d

        function visibleIndexToWritable(index) {
            return visibleSFPM.mapToSource(index)
        }
    }
}
