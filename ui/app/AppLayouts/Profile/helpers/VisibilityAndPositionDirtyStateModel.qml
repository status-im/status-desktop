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
     *     key: <string or integer>
     *     position: <integer>
     *     visibility: <integer>
     *   }
     * ]
     *
     * The entries with visibility 0 (hidden) are not included in the list.
     */
    function currentState() {
        const visible = d.getVisibleEntries()
        const minPos = Math.min(...visible.map(e => e.position))

        return visible.map(e => { e.position -= minPos; return e })
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
        if (visibility === visibilityHidden
                || oldVisibility !== visibilityHidden) {
            set(sourceIdx, { visibility: visibility })
            return
        }

        // unhiding
        const positions = d.getVisibleEntries().map(e => e.position)
        const position = Math.max(-1, ...positions) + 1
        set(sourceIdx, { visibility, position })
    }

    readonly property QtObject d_: QtObject {
        id: d

        function indexByKey(key) {
            return ModelUtils.indexOf(root, "key", key)
        }

        function getVisibleEntries() {
            const roles = ["key", "position", "visibility"]
            const keysAndPos = ModelUtils.modelToArray(root, roles)

            return keysAndPos.filter(p => p.visibility
                                     && p.visibility !== root.visibilityHidden)
        }

        function getVisibility(idx) {
            return ModelUtils.get(root, idx, "visibility")
                    || root.visibilityHidden
        }
    }
}
