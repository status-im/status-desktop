import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1

//StatusLazyScrollView is the decorator for the FlickableAnchoringListviews
//It adds the scrollbar

StatusScrollView {
    id: root

    implicitWidth: contentWidth
    implicitHeight: contentHeight

    contentItem: FlickableAnchoringListviews {
        id: flickableAnchor
        //anchors.fill: parent
    }

     ScrollBar.vertical.visible: false //hide the default scrollbar
     StatusScrollBar {
        property bool externalUpdate: false
        parent: root
        x: root.mirrored ? 1 : root.width - width - 1
        y: root.topPadding
        height: root.availableHeight
        size: root.availableHeight / flickableAnchor.virtualContentHeight

        //TODO: fix the virtualContentYPosition. It's jumpy and sometimes unreliable
        position: {
            externalUpdate = true
            return flickableAnchor.virtualContentYPosition / flickableAnchor.virtualContentHeight
        }

        onPositionChanged: {
            if(externalUpdate) {
                externalUpdate = false
                return
            }

            flickableAnchor.virtualContentYPosition = position * flickableAnchor.virtualContentHeight
        }
        //TODO: fix the inteactive scrolling!!
        interactive: true
        policy: root.availableHeight < flickableAnchor.virtualContentHeight ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
        visible: true
        opacity: 1
    }
}
