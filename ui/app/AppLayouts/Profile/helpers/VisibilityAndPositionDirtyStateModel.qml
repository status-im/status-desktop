import QtQml 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

/**
  * Basic building block for storing temporary state in the "Profile Showcase"
  * functionality. Allows to store on the UI side the temporary position and
  * visibility level. Can store temporary state for Communities, Accounts,
  * Collectibles and Assets.
  */
WritableProxyModel {
    id: root

    /**
      * "Hidden" is a special type of visibility that requires special
      * treatment. When the visibility is changed from hidden to other type
      * of visibility, in addition to changing the visibility, the appropriate
      * position is also set.
      */
    property int visibilityHidden: 0

    /* Provides the list of objects representing the current state in the
     * in the following format:
     * [ {
     *     showcaseKey: <string or integer>
     *     showcasePosition: <integer>
     *     showcaseVisibility: <integer>
     *   }
     * ]
     *
     * The entries with visibility 0 (hidden) are not included in the list.
     */
    function currentState() {
        const visible = d.getVisibleEntries()
        const minPos = Math.min(...visible.map(e => e.showcasePosition))

        return visible.map(e => { e.showcasePosition -= minPos; return e })
    }

    /* Sets the visibility of the given item. If the element was hidden, it is
     * positioned last.
     */
    function setVisibility(key, visibility) {
        const sourceIdx = d.indexByKey(key)
        const oldVisibility = d.getVisibility(sourceIdx)

        if (oldVisibility === visibility)
            return

        // hiding, changing visibility level
        if (visibility === visibilityHidden) {
            set(sourceIdx, { showcaseVisibility: undefined, showcasePosition: undefined})
            return
        }

        if (oldVisibility === visibilityHidden || oldVisibility === undefined) {
            // unhiding
            const positions = d.getVisibleEntries().map(e => e.showcasePosition)
            const position = Math.max(-1, ...positions) + 1
            set(sourceIdx, { showcaseVisibility: visibility, showcasePosition: position })
            return
        }

        // changing visibility level
        set(sourceIdx, { showcaseVisibility: visibility })
    }

    syncedRemovals: true

    readonly property QtObject d_: QtObject {
        id: d

        function indexByKey(key) {
            return ModelUtils.indexOf(root, "showcaseKey", key)
        }

        function getVisibleEntries() {
            const roles = ["showcaseKey", "showcasePosition", "showcaseVisibility"]
            const keysAndPos = ModelUtils.modelToArray(root, roles)

            return keysAndPos.filter(p => p.showcaseVisibility
                                     && p.showcaseVisibility !== root.visibilityHidden)
        }

        function getVisibility(idx) {
            return ModelUtils.get(root, idx, "showcaseVisibility")
                    || root.visibilityHidden
        }
    }
}
