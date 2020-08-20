import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQml.Models 2.13
import "../../../../../imports"
import "../../../../../shared"

ScrollView {
    readonly property int imageSize: 164
    property string collectibleType: "cryptokitty"
    property var collectiblesModal
    property string buttonText: "View in Cryptokitties"
    property var getLink: function () {}
    property var collectibles: []

    id: root
    height: visible ? contentRow.height : 0
    width: parent.width
    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
    ScrollBar.horizontal.policy: ScrollBar.AsNeeded
    clip: true

    Row {
        id: contentRow
        bottomPadding: Style.current.padding
        spacing: Style.current.padding

        Repeater {
            model: collectibles

            Rectangle {
                radius: 16
                border.width: 1
                border.color: Style.current.border
                color: Style.current.background
                width: collectibleImage.width
                height: collectibleImage.height

                Image {
                    id: collectibleImage
                    width: root.imageSize
                    height: root.imageSize
                    source: modelData.image
                    fillMode: Image.PreserveAspectCrop
                }

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                        collectiblesModal.openModal({
                                                   name: modelData.name,
                                                   id: modelData.id,
                                                   description: modelData.description,
                                                   buttonText: root.buttonText,
                                                   link: root.getLink(modelData.id, modelData.externalUrl),
                                                   image: modelData.image
                                               })
                    }
                }
            }
        }
    }
}
