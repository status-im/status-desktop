import QtQuick 2.15
import QtQml 2.15
import QtQuick.Window 2.15

//Component used to update the nested listview size and determine the active scrolling area
//The scrolling area can be either the nested listview, or the parent Flickable

QtObject {
    id: root
    required property ListView target
    required property FlickableAnchoringListviews anchorIn

    readonly property alias virtualY: d.breakpoint.virtualY
    readonly property alias enable: d.breakpoint.enabled

    property int lockAt: d.lockAt

    enum ContentLock {
        None,
        Top,
        Bottom
    }

    onTargetChanged: {
        if(!target)
            root.anchorIn.removeAnchor(root)
    }

    onLockAtChanged: {
        if(d.lockAt === lockAt)
            return

        d.lockAt = lockAt
    }

    Component.onCompleted: {
        if(!!target)
            root.anchorIn.addAnchor(root)
    }
    Component.onDestruction: root.anchorIn.removeAnchor(root)

    readonly property QtObject d: QtObject {
        id: d

        property int lockAt: NestedListViewAnchor.Top

        readonly property NestedListViewScrollBreakpoint breakpoint: NestedListViewScrollBreakpoint {
            id: breakpoint
            target: root.target
            parentFlickable: root.anchorIn
            enabled: root.target.contentHeight > root.anchorIn.height && root.target.visible

            onHit: root.anchorIn.anchor(root)
            onMiss: root.anchorIn.releaseAnchor(root)
        }

        //This is just for model reset while the target is in the upper part of the screen
        readonly property ScrollBreakpoint modelResetBrekpoint: ScrollBreakpoint {
            target: root.target
            enabled: breakpoint.enabled && root.anchorIn.contentY - root.anchorIn.originY > root.virtualY + 2 && root.target.count > 0
            checkOnEnabled: true
            condition: () => root.target.contentY === 0
            onHit: d.lockAt = NestedListViewAnchor.Bottom
        }

        //This is just for model reset while the target is in the upper part of the screen
        readonly property ScrollBreakpoint layoutResetBreakpoint: ScrollBreakpoint {
            target: root.target
            enabled: breakpoint.enabled && root.anchorIn.contentY - root.anchorIn.originY < root.virtualY - 2 && root.target.count > 0
            checkOnEnabled: true
            condition: () => root.target.contentY - root.target.originY !== 0
            onHit: d.lockAt = NestedListViewAnchor.Top
        }

        readonly property ScrollBreakpoint lockAtTop: ScrollBreakpoint {
            target: root.target
            enabled: breakpoint.enabled && d.lockAt === NestedListViewAnchor.Top
            condition: () => root.target.contentY - root.target.originY + root.target.height !== root.target.contentHeight
            onHit: Qt.callLater(() => root.target.contentY = 0)
        }

        readonly property ScrollBreakpoint lockAtBottom: ScrollBreakpoint {
            target: root.target
            enabled: breakpoint.enabled && d.lockAt === NestedListViewAnchor.Bottom
            condition: () => root.target.contentY - root.target.originY + root.target.height !== root.target.contentHeight
            onHit: Qt.callLater(() => root.target.contentY = root.target.contentHeight * root.target.contentHeight)
        }

        readonly property Binding targetHeightBinding: Binding {
            target: root.target
            property: "implicitHeight"
            value: Math.max(0, Math.min(root.anchorIn.height, root.target.contentHeight))
            restoreMode: Binding.RestoreNone
        }

        readonly property Binding targetWidthBinding: Binding {
            target: root.target
            property: "implicitWidth"
            value: root.anchorIn.width
            restoreMode: Binding.RestoreNone
        }

        //Biding on internal events
        readonly property Binding lockAtBinding: Binding {
            target: root
            property: "lockAt"
            value: d.lockAt
            delayed: true
        }
    }
}
