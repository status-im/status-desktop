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

    function currentState() {
        return writable.currentState()
    }

    function setVisibility(key, visibility) {
        writable.setVisibility(key, visibility)
    }

    function changePosition(key, to) {
        writable.changePosition(key, to)
    }

    // internals, debug purpose only
    readonly property alias writable_: writable
    readonly property alias joined_: joined

    component HiddenFilter: AnyOf {
        UndefinedFilter {
            roleName: "visibility"
        }

        ValueFilter {
            roleName: "visibility"
            value: Constants.ShowcaseVisibility.NoOne
        }
    }

    LeftJoinModel {
        id: joined

        joinRole: "key"
    }

    VisibilityAndPositionDirtyStateModel {
        id: writable

        sourceModel: joined
        visibilityHidden: Constants.ShowcaseVisibility.NoOne
    }

    SortFilterProxyModel {
        id: visible

        sourceModel: writable
        delayed: true

        filters: HiddenFilter { inverted: true }
        sorters: RoleSorter { roleName: "position" }
    }

    SortFilterProxyModel {
        id: hidden

        sourceModel: writable
        delayed: true

        filters: HiddenFilter {}
    }
}
