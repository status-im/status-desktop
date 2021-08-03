import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "../../imports"


Column {
    id: root
    spacing: 8
    property alias gifList: repeater
    property var gifWidth: 0
    property var gifSelected: function () {}
    property var toggleFavorite: function () {}

    Repeater {
        id: repeater

        delegate: Rectangle {
            height: animation.status != Image.Ready ? loader.height : animation.height
            width: root.gifWidth
            color: Style.current.background
            border.color: Style.current.border

            Rectangle {
                id: loader
                height: 100
                width: root.gifWidth
                visible: animation.status != Image.Ready
                radius: Style.current.radius
                rotation: 90
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: "#E6EEF2" }
                }
            }

            StatusIconButton {
                id: starButton
                icon.name: "star-icon"
                iconColor: {
                    if (model.isFavorite) {
                        return Style.current.yellow
                    }
                    return Style.current.secondaryText
                }
                hoveredIconColor: {
                    if (iconColor === Style.current.yellow) {
                        return Style.current.secondaryText
                    }
                    return Style.current.yellow
                }
                highlightedBackgroundOpacity: 0
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: 24
                height: 24
                z: 1
                padding: 10
                onClicked: {
                    root.toggleFavorite(model)
                    if (starButton.iconColor === Style.current.yellow) {
                        starButton.iconColor = Style.current.secondaryText
                    } else {
                        starButton.iconColor = Style.current.yellow
                    }
                }
            }

            AnimatedImage {
                id: animation
                visible: animation.status == Image.Ready
                source: model.tinyUrl
                width: root.gifWidth
                fillMode: Image.PreserveAspectFit
                z: 0
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: animation.width
                        height: animation.height
                        radius: Style.current.radius
                        color: Style.current.background
                        border.color: Style.current.border
                    }
                }
            }

            MouseArea {
                id: mouseArea
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onClicked: function (event) {
                    root.gifSelected(event, model.url)
                    chatsModel.gif.addToRecents(model.id)
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:440;width:360}
}
##^##*/
