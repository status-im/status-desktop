import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import StatusQ.Controls 0.1


import utils 1.0
import shared.stores 1.0


Column {
    id: root
    spacing: 8
    property alias gifList: repeater
    property int gifWidth: 0
    property var store
    property var gifSelected: function () {}
    property var toggleFavorite: function () {}
    property string lastHoveredId
    signal gifHovered(string id)

    Repeater {
        id: repeater

        delegate: Rectangle {
            id: thumb
            property alias hovered: mouseArea.containsMouse
            onHoveredChanged: {
                if (hovered) {
                    root.gifHovered(model.id)
                }
            }

            height: animation.status != Image.Ready ? loader.height : animation.height
            width: root.gifWidth
            color: Style.current.background

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

            StatusBaseButton {
                id: starButton
                property bool favorite: RootStore.isFavorite(model.id)

                type: StatusFlatRoundButton.Type.Secondary
                textColor: hovered || favorite ? Style.current.yellow : Style.current.secondaryText
                icon.name: favorite ? "star-icon" : "star-icon-outline"
                icon.width:  (14/104) * thumb.width
                icon.height: (13/104) * thumb.width
                topPadding: (6/104) * thumb.width
                rightPadding: (6/104) * thumb.width
                bottomPadding: (6/104) * thumb.width
                leftPadding: (6/104) * thumb.width
                color: "transparent"
                visible: !loader.visible && model.id === root.lastHoveredId
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                z: 1
                onClicked: {
                    root.toggleFavorite(model)
                    favorite = !favorite
                }
                onHoveredChanged: {
                    if (hovered) {
                        root.gifHovered(model.id)
                    }
                }
                StatusToolTip {
                    id: statusToolTip
                    text: starButton.favorite ?
                        qsTr("Remove from favorites") :
                        qsTr("Add to favorites")
                    visible: starButton.hovered
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
                    opacity: model.id === root.lastHoveredId ? 0.6 : 1
                    maskSource: Rectangle {
                        width: animation.width
                        height: animation.height
                        radius: Style.current.radius
                    }
                }
            }

            MouseArea {
                id: mouseArea
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onClicked: function (event) {
                    root.store.addToRecentsGif(model.id)
                    root.gifSelected(event, model.url)
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
