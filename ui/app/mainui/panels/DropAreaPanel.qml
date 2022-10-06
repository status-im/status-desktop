import QtQuick 2.14
import utils 1.0

DropArea {
    id: root

    property bool enabled: false
    property alias droppedUrls: rptDraggedPreviews.model
    property int activeChatType

    signal droppedOnValidScreen(var drop)

    function cleanup() {
        rptDraggedPreviews.model = []
    }

    Component.onCompleted: {
        Global.dragArea = this;
    }

    onDropped: (drop) => {
                if (enabled) {
                    droppedOnValidScreen(drop)
                } else {
                    drop.accepted = false
                }
                cleanup()
            }
    onEntered: {
        if (!enabled || !!drag.source) {
            drag.accepted = false
            return
        }

        // needed because drag.urls is not a normal js array
        rptDraggedPreviews.model = drag.urls.filter(img => Utils.hasDragNDropImageExtension(img))
    }
    onPositionChanged: {
        rptDraggedPreviews.x = drag.x
        rptDraggedPreviews.y = drag.y
    }

    onExited: cleanup()

    Loader {
        active: root.containsDrag
        width: active ? parent.width : 0
        height: active ? parent.height : 0
        sourceComponent: Rectangle {
            id: dropRectangle
            color: Style.current.background
            opacity: 0.8
        }
    }

    Repeater {
        id: rptDraggedPreviews
        Image {
            source: modelData
            width: 80
            height: 80
            sourceSize.width: 160
            sourceSize.height: 160
            fillMode: Image.PreserveAspectFit
            x: index * 10 + rptDraggedPreviews.x
            y: index * 10 + rptDraggedPreviews.y
            z: 1
        }
    }
}
