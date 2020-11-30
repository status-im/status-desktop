import QtQuick 2.13
import "."
import "../imports"

Item {
    property var image
    property alias selectorRectangle: selectorRectangle

    width: image.width
    height: image.height

    Rectangle {
        id: selectorRectangle
        visible: false
        x: 0
        y: 0
        border.width: 2
        border.color: Style.current.orange
        color: Style.current.transparent

        function initialSetup() {
            topLeftCorner.x = 0
            topLeftCorner.y = 0
            topRightCorner.x = image.width - topRightCorner.width
            topRightCorner.y = 0
            bottomLeftCorner.x = 0
            bottomLeftCorner.y = image.height - topRightCorner.height
            bottomRightCorner.x = image.width - topRightCorner.width
            bottomRightCorner.y = image.height - topRightCorner.height

            selectorRectangle.width = image.width
            selectorRectangle.height =  image.height
        }

        function adjustRectangleSize() {
            selectorRectangle.width = bottomRightCorner.x + bottomRightCorner.width - topLeftCorner.x
            selectorRectangle.height = bottomRightCorner.y + bottomRightCorner.height - topLeftCorner.y
            selectorRectangle.x = topLeftCorner.x
            selectorRectangle.y = topLeftCorner.y
        }

        Connections {
            target: image
            onStatusChanged: {
                if (image.status === Image.Ready) {
                    selectorRectangle.initialSetup()
                    selectorRectangle.visible = true
                }
            }
        }
    }

    // Size calculations are only done on top-left and bottom-right, because the other two corners follow them
    CropCornerRectangle {
        id: topLeftCorner
        onXChanged: {
            if (x < 0) x = 0
            if (x > topRightCorner.x - width) x = topRightCorner.x - width

            bottomLeftCorner.x = x
            selectorRectangle.adjustRectangleSize()
        }
        onYChanged: {
            if (y < 0) y = 0
            if (y > bottomRightCorner.y - height) y = bottomRightCorner.y - height

            topRightCorner.y = y
            selectorRectangle.adjustRectangleSize()
        }
    }

    CropCornerRectangle {
        id: topRightCorner
        onXChanged: {
            bottomRightCorner.x = x
        }
        onYChanged: {
            topLeftCorner.y = y
        }
    }

    CropCornerRectangle {
        id: bottomLeftCorner
        onXChanged: {
            topLeftCorner.x = x
        }
        onYChanged: {
            bottomRightCorner.y = y
        }
    }

    CropCornerRectangle {
        id: bottomRightCorner
        onXChanged: {
            if (x < topLeftCorner.x + topLeftCorner.width) x = topLeftCorner.x + topLeftCorner.width
            if (x > image.width - width) x = image.width - width
            topRightCorner.x = x
            selectorRectangle.adjustRectangleSize()
        }
        onYChanged: {
            if (y < topRightCorner.y + topRightCorner.height) y = topRightCorner.y + topRightCorner.height
            if (y > image.height - height) y = image.height - height
            bottomLeftCorner.y = y
            selectorRectangle.adjustRectangleSize()
        }
    }
}
