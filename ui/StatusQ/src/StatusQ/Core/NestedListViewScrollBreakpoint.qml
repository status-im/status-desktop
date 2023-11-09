import QtQuick 2.14
import QtQuick.Window 2.15

QtObject {
    id: root
    
    /*
    This component is tracking the position and scrolling of a target flickable inside a parent flickable and 
    is signalling when the target Flickable is perfectly aligned in the parent viewport and the scrolling position is synced as well so that the target can take over the scrolling.
    */

    //The target is the item that is being tracked. It is assumed that the target is a child of the parentFlickable
    required property Flickable target

    //The parentFlickable is the item that is being tracked. It is assumed that the target is a child of the parentFlickable
    required property Flickable parentFlickable

    //The enabled property is used to enable/disable the tracking
    property bool enabled: false

    //The target can take over the active scrolling
    signal hit()

    //The target needs to release the active scrolling
    signal miss()

    readonly property alias virtualY: d.virtualY


    onTargetChanged: {
        //3 levels of nesting are allowed.
        //The nesting level is limited because the child item virtual y position is calculated using bindings. This binding needs to statically declare it's dependencies.
        //The dependency in this case is also item.parent.parent.y. If the nesting level is increased, the binding needs to be updated.
        console.assert(root.target.parent === root.parentFlickable.contentItem ||
                        root.target.parent.parent === root.parentFlickable.contentItem ||
                        root.target.parent.parent.parent === root.parentFlickable.contentItem, "Anchored item must be a close child of the Flickable")
    }
    
    readonly property QtObject d: QtObject {
        id: d
        property bool hit: false

        readonly property real virtualY: {
            ///The target y position in the parentFlickable content coordinates
            //3 nesting levels are supported
            root.target.y
            root.target.parent ? root.target.parent.y : 0
            root.target.parent.parent ? root.target.parent.parent.y : 0
            root.target.parent.parent.parent ? root.target.parent.parent.parent.y : 0


            return Math.floor(root.target.mapToItem(root.parentFlickable.contentItem, 0, 0).y)
        }
        readonly property bool breakpointsReady: root.enabled && root.target.contentHeight > root.parentFlickable.height
        readonly property bool breakpointsActive: breakpointsReady && root.target.height === root.parentFlickable.height
        readonly property bool externalBreakpointsEnabled: d.breakpointsActive && !d.hit

        //Tracking the parent flickable scroll down. It's used to detect a hit
        //Will hit whe the target is perfectly aligned in the top viewport
        readonly property ScrollBreakpoint externalScrollDownBreakpoint : ScrollBreakpoint {
            id: externalScrollDownBreakpoint
            target: root.parentFlickable
            enabled: d.breakpointsActive
            condition: () => root.parentFlickable.contentY - root.parentFlickable.originY >= d.virtualY
            onHit: {
                externalScrollDownBreakpoint.enabled = false
                externalScrollDownBreakpoint.enabled = false
                d.hit = true
                internalBottomBreakpoint.enabled = d.breakpointsActive
                internalTopBreakpoint.enabled = d.breakpointsActive
            }
        }

        //Tracking the parent flickable scroll up. It's used to detect a hit
        //Will hit whe the target is perfectly aligned in the bottom viewport
        readonly property ScrollBreakpoint externalScrollUpBreakpoint: ScrollBreakpoint {
            id: externalScrollUpBreakpoint
            target: root.parentFlickable
            enabled: false
            condition: () => root.parentFlickable.contentY - root.parentFlickable.originY <= d.virtualY
            onHit: {
                externalScrollUpBreakpoint.enabled = false
                externalScrollDownBreakpoint.enabled = false
                d.hit = true
                internalBottomBreakpoint.enabled = d.breakpointsActive
                internalTopBreakpoint.enabled = d.breakpointsActive
            }
        }

        //Tracking the target scroll down. It's used to detect a miss
        //Will hit whe the target is scrolled to the bottom
        readonly property ScrollBreakpoint internalBottomBreakpoint: ScrollBreakpoint {
            id: internalBottomBreakpoint
            target: root.target
            enabled: false
            waitFor: ScrollBreakpoint {
                target: root.target
                enabled: internalBottomBreakpoint.enabled
                condition: () => Math.ceil((root.target.contentY - root.target.originY) + root.target.height) < root.target.contentHeight
            }
            condition: () => Math.ceil((root.target.contentY - root.target.originY) + root.target.height) >= root.target.contentHeight
           
            onHit: {
                d.hit = false
                internalBottomBreakpoint.enabled = false
                internalTopBreakpoint.enabled = false
                externalScrollUpBreakpoint.enabled = d.breakpointsActive
            }
        }

        //Tracking the target scroll up. It's used to detect a miss
        //Will hit whe the target is scrolled to the top
        readonly property ScrollBreakpoint internalTopBreakpoint: ScrollBreakpoint {
            id: internalTopBreakpoint
            target: root.target
            enabled: false
            condition: () => Math.floor(root.target.contentY - root.target.originY) <= 0

            onHit: {
                d.hit = false
                internalTopBreakpoint.enabled = false
                internalBottomBreakpoint.enabled = false
                externalScrollDownBreakpoint.enabled = d.breakpointsActive
            }
        }

        ///This breakpoint is used to detect if the target is about to enter the viewport from the top
        ///It is used to ensure that the target is scrolled to the bottom when it is about to enter the viewport from the bottom
        ///Needed when a listview in the middle of the page is reset to the top by a model reset
        readonly property ScrollBreakpoint aboutToEnterViewportBreakpoint: ScrollBreakpoint {
            id: aboutToEnterViewportBreakpoint
            target: root.target
            enabled: d.breakpointsActive && root.parentFlickable.contentY - root.target.originY + root.target.height === 0
            condition: () => root.parentFlickable.contentY - root.parentFlickable.originY > d.virtualY
            onHit: Qt.callLater(() => root.target.positionViewAtEnd())
        }

        onHitChanged: hit ? root.hit() : root.miss()

        onBreakpointsReadyChanged: {
            root.target.implicitHeight = breakpointsReady ? root.parentFlickable.height : root.target.contentHeight
            if(!breakpointsReady && d.hit) {
                d.hit = false
            }
        }

        onBreakpointsActiveChanged: {
            if(!d.breakpointsActive && d.hit) {
                d.hit = false
            }

            if(d.breakpointsActive) {
                externalScrollDownBreakpoint.enabled = root.parentFlickable.contentY - root.parentFlickable.originY <= d.virtualY
                externalScrollUpBreakpoint.enabled = root.parentFlickable.contentY - root.parentFlickable.originY >= d.virtualY
            }
            else {
                externalScrollDownBreakpoint.enabled = false
                externalScrollUpBreakpoint.enabled = false
                internalBottomBreakpoint.enabled = false
                internalTopBreakpoint.enabled = false
            }
        }
    }
}
