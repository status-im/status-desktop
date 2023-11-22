import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15



// FlickableAnchoringListviews is a flickable that can anchor nested listviews
// Anchoring listviews refers to the ability to scroll the flickable by scrolling the nested listviews and vice versa. A child listview will be anchored in the flickable
// when it is scrolled
// The main goal is to have a single scrollable area that contains all the nested listviews withoud unrolling the nested listviews
// This is achieved by using scrolling breakpoints and switching the scrolling between the flickable and the nested listviews, depending on the content position.
// The scrolling can switch between the flickable and the nested listviews.
//
// Input: 
//     NestedListViewAnchor
// Output:
//     property virtualContentHeight - The global content height. It can be different than the flickable content height if the flickable contains nested listviews
//     property virtualContentYPosition - The global content y. It can be different than the flickable content y if the flickable contains nested listviews
//
// Usage:
//     FlickableAnchoringListviews {
//         id: root
//         anchors.fill: parent              // Give it a size
//         contentWidth: childLayout.width   // Set the content width
//         contentHeight: childLayout.height // Set the content height. This height is the implicit height of the childLayout
//         ColumnLayout {
//             id: childLayout
//             ListView {
//                 id: listview1
//                  NestedListViewAnchor {
//                      target: listview1
//                      anchorIn: root
//                  }
//             }
//             ListView {
//                 id: listview2
//                  NestedListViewAnchor {
//                      target: listview2
//                      anchorIn: root
//                  }
//             }
//         }
//    }


Flickable {
    id: root

    //Output property for the global content height
    //It's the sum of the flickable content height and the nested listviews content heightd
    readonly property alias virtualContentHeight: d.virtualContentHeight

    //Input and Output property for the global content y. The global content y is the calculated contentY if the listviews would be unrolled.
    //It depends on the flickable contentY and the nested listviews contentY and originY
    //
    //Input:
    //Setting this property will scroll the flickable and/or the nested listviews depending on the destination. When the scrolling is done, this property will be updatedd with the new value
    //The new position can be different than the set destination if it is out of range
    //This can often happen when the nested listviews use delegates with dynamic height
    //
    //Output:
    //Reading this property will return the global content y. It can be used for scrollbars
    property real virtualContentYPosition: d.virtualContentYPosition

    Binding on virtualContentYPosition {
        value: d.virtualContentYPosition
        delayed: true
        restoreMode: Binding.RestoreNone
    }

    //The active scroll area is the Flickable that handles the scrolling events
    property Flickable activeScrollArea: root

    //Function that receives the NestedListViewAnchor and configures the nested listview
    function addAnchor(item) {
        d.addAnchor(item)
    }

    //Function that receives the NestedListViewAnchor and removes the nested listview
    function removeAnchor(item) {
        d.removeAnchor(item)
    }

    //Function that receives the NestedListViewAnchor and locks the nested listview for scrolling
    //Calling this will lock the nested listview for scrolling and will scroll the flickable
    //`activeScrollArea` will be updated and the Flickable will lock the contentY to the top of the `activeScrollArea`
    function anchor(item) {
        d.anchor(item)
    }

    //Function that receives the NestedListViewAnchor and releases the nested listview
    //Calling this will release the nested listview for scrolling and the `activeScrollArea` will be set to the flickable
    function releaseAnchor(item) {
        d.releaseAnchor(item)
    }


    //External scrolling handler
    //This handler is used to scroll into the new position when the virtualContentYPosition is changed
    //When the scrolling is done, `virtualContentYPosition` is updated
    onVirtualContentYPositionChanged: {

        if(Math.floor(root.virtualContentYPosition) === Math.floor(d.virtualContentYPosition) ||
            root.virtualContentYPosition < 0 ||
            root.virtualContentYPosition > d.virtualContentHeight - root.height ||
            d.internalScrolling === true) {
            return
        }

        //Just in case - guard against re-entry
        d.internalScrolling = true

        //There are two levels of scrolling:
        //1. The underlying flickable
        //2. Each of the nested listviews
        //
        //if the destination is is the range of any nested listview, lock the anchor and scroll the nested listview
        //otherwise scroll the flickable by substracting the extra content height from the destination
        let destination = root.virtualContentYPosition
        let hiddenContentBeforeDestination = 0
        let destinationOverlappingAnchor = null

        //iterate to find the anchor at the destination
        //if there is no anchor at the destination, the destination is in the flickable
        //if there is an anchor at the destination, the destination is in the nested listview
        for (var i = 0; i < d.anchors.length; i++) {
            var anchor = d.anchors[i]

            if(destination < anchor.virtualY) {
                break
            }

            let anchorBegin = anchor.virtualY
            let anchorEnd = hiddenContentBeforeDestination + anchor.virtualY + anchor.target.contentHeight

            destinationOverlappingAnchor = destination >= anchorBegin && destination <= anchorEnd

            if(destinationOverlappingAnchor) {
                //There are 2 cases when the destination is overlapping the anchor:
                //1. The destination is in the anchor and the anchor needs to be locked for scrolling
                //   In this case the destination is greated the max contentY of the nested listview
                //2. The destination is in the anchor and the flickable needs to be scrolled
                //   In this case the destination is smaller than the max contentY of the nested listview

                let destinationFlickable = destination < anchorEnd - anchor.target.height ? anchor.target : root
                //Case 1: The destination is in the anchor and the anchor is needs to be locked for scroll
                if(destinationFlickable === anchor.target) {
                    root.contentY = anchor.virtualY
                    //Try to position the nested listview at the destination
                    anchor.target.contentY = destination - hiddenContentBeforeDestination - anchor.virtualY + anchor.target.originY
                    root.activeScrollArea = anchor.target
                }

                //Case 2: The destination is in the anchor and the flickable needs to be scrolled
                //Try to position the nested listview at the end of the anchor
                else {
                    //anchor.target.positionViewAtEnd()
                    anchor.lockAt = NestedListViewAnchor.ContentLock.Bottom
                    root.contentY = destination - hiddenContentBeforeDestination - anchor.target.contentY - anchor.target.originY + root.originY
                    root.activeScrollArea = root
                }

                break
            }
            anchor.target.positionViewAtEnd()
            hiddenContentBeforeDestination += anchor.target.contentHeight - anchor.target.height
        }

        //if there is no anchor at the destination, the destination is in the flickable
        if(!destinationOverlappingAnchor) {
            root.contentY = destination - hiddenContentBeforeDestination + root.originY
        }

        d.internalScrolling = false
    }

    onContentYChanged: d.onContentYChanged()

    boundsBehavior: Flickable.StopAtBounds
    boundsMovement: Flickable.StopAtBounds

    clip: true
    
    Binding on interactive {
        //Disable the default scroll when there are nested listviews anchored in the flickable
        value: d.virtualContentHeight <= root.contentHeight
    }

    QtObject {
        id: d
        //The global content height calculated for the flickable and all the nested listviews
        property real virtualContentHeight: root.contentHeight + d.hiddenContentHeight
        //The hidden content height is the sum of the content height of the nested listviews that is not visible at any time
        //It needs to be accounted for when calculating the global content height
        property real hiddenContentHeight: 0
        //The virtual content y position is the global content y position
        property real virtualContentYPosition: 0

        //Internal scrolling flag. It's used to guard against re-entry
        property bool internalScrolling: false

        //The anchors holding the nested listviews anchored in the flickable
        property var anchors: []

        //The NestedListViewAnchor is a helper object that contains the nested listview and the virtual position of the nested listview
        //The anchor will signal when it needs to be locked for scrolling
        function addAnchor(item) {
            console.assert(item instanceof NestedListViewAnchor, "item must be a NestedListViewAnchor")
            //TODO: Use Instantiator instead of the code below and create proper Bindings
            configureNestedListView(item.target)
            d.anchors.push(item)
            d.anchors.sort((lhs, rhs) => lhs.virtualY - rhs.virtualY)
            updateHiddenContentHeight()
            item.target.contentHeightChanged.connect(d.updateHiddenContentHeight)
            item.target.contentYChanged.connect(d.onContentYChanged)
            item.target.originYChanged.connect(d.onContentYChanged)
        }

        //Removing the anchor - probably the nested listview is getting destroyed
        function removeAnchor(item) {
            console.assert(item instanceof NestedListViewAnchor, "item must be a NestedListViewAnchor")
            
            //TODO: Use Instantiator instead of the code below and create proper Bindings
            d.anchors = d.anchors.filter((element, idex, array) => {
                return element !== item
            })

            updateHiddenContentHeight()
            item.target.contentHeightChanged.disconnect(d.updateHiddenContentHeight)
            item.target.contentYChanged.disconnect(d.onContentYChanged)
            item.target.originYChanged.disconnect(d.onContentYChanged)
        }

        //Locking the anchor for scrolling
        function anchor(item) {
            console.assert(item instanceof NestedListViewAnchor, "item must be a NestedListViewAnchor")
            item.lockAt = NestedListViewAnchor.ContentLock.None
            root.cancelFlick()
            root.contentY = item.virtualY
            root.activeScrollArea = item.target
        }
        
        //Releasing the anchor for scrolling
        function releaseAnchor(item) {
            console.assert(item instanceof NestedListViewAnchor, "item must be a NestedListViewAnchor")
            item.target.cancelFlick()
            root.activeScrollArea = root
        }

        //Configuring the nested listview
        function configureNestedListView(item) {
            if(!item)
                return
            
            item.interactive = false
            item.boundsBehavior = Flickable.StopAtBounds
            item.boundsMovement = Flickable.StopAtBounds

            if(!!item.ScrollBar.vertical) {
                item.ScrollBar.vertical.visible = false
            }
        }

        //Compute the global virtual content y position by aggregating the total content y of the nested listviews
        function onContentYChanged() {
                let virtualContentY = 0
                for(var i = d.anchors.length - 1; i >= 0; i--) {
                    var anchor = d.anchors[i]
                    virtualContentY += (anchor.target.contentY - anchor.target.originY)
                }
                virtualContentY += root.contentY - root.originY
                d.virtualContentYPosition = virtualContentY
        }

        //Compute the hidden content height by aggregating the total content height of the nested listviews
        function updateHiddenContentHeight() {
            d.hiddenContentHeight = anchors.reduce((accumulator, anchor) => accumulator + anchor.target.contentHeight - anchor.target.height, 0)
        }
    }


    //Main scrolling handler
    WheelHandler {
        enabled: !root.interactive
        target: root.activeScrollArea
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        invertible: true
        onWheel: event => {
            if (!!event.angleDelta.y || !!event.angleDelta.x) {
                root.activeScrollArea.contentY += event.inverted ? -event.angleDelta.y : event.angleDelta.y
            } else {
                root.activeScrollArea.cancelFlick()
            }
        }
    }
}
