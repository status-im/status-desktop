import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.14

import shared.controls 1.0
import shared.panels 1.0
import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root
    objectName: "groupChatEdit_main"

    property string activeGroupImageData
    property string activeGroupColor
    property string activeGroupName

    signal updateGroupChatDetails(string groupName, string groupColor, string groupImage)

    title: qsTr("Edit group name and image")
    width: 480
    height: 610

    QtObject {
        id: d
        readonly property int nameCharLimit: 24
    }

    onOpened: {
        groupName.input.edit.forceActiveFocus()
        groupName.text = root.activeGroupName.substring(0, d.nameCharLimit)

        colorSelectionGrid.selectedColor = activeGroupColor

        for (let i = 0; i < colorSelectionGrid.model.length; i++) {
            if(colorSelectionGrid.model[i] === root.activeGroupColor.toUpperCase())
                colorSelectionGrid.selectedColorIndex = i
        }

        imageEditor.dataImage = activeGroupImageData
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        StatusInput {
            id: groupName
            input.edit.objectName: "groupChatEdit_name"
            Layout.alignment: Qt.AlignHCenter
            label: qsTr("Name the group")
            charLimit: d.nameCharLimit
        }

        StatusBaseText {
            id: imgText
            text: qsTr("Group image")
            leftPadding: groupName.leftPadding - root.padding
            font.pixelSize: 15
        }

        EditCroppedImagePanel {
            id: imageEditor
            objectName: "groupChatEdit_image"
            Layout.preferredWidth: 128
            Layout.preferredHeight: Layout.preferredWidth / aspectRatio
            Layout.alignment: Qt.AlignHCenter

            imageFileDialogTitle: qsTr("Choose an image as logo")
            title: qsTr("Edit group name and image")
            acceptButtonText: qsTr("Use as an icon for this group chat")

            backgroundComponent:
                StatusLetterIdenticon {
                id: letter
                color: colorSelectionGrid.selectedColor
                name: root.activeGroupName
                height: 100
                width: 100
                letterSize: 64

                StatusRoundButton {
                    id: addButton

                    icon.name: "add"
                    type: StatusRoundButton.Type.Secondary

                    transform: [
                        Translate {
                            x: -addButton.width/2 - 5
                            y: -addButton.height/2 + 5
                        },
                        Rotation { angle: -addRotationTransform.angle },
                        Rotation {
                            id: addRotationTransform
                            angle: 135
                            origin.x: letter.radius
                        },
                        Translate {
                            x: letter.width - 2 * letter.radius
                            y: letter.radius
                        }
                    ]

                    onClicked: imageEditor.chooseImageToCrop()
                }
            }
        }

        StatusBaseText {
            id: colorText
            text: qsTr("Standard colours")
            leftPadding: groupName.leftPadding - root.padding
            font.pixelSize: 15
        }

        StatusColorSelectorGrid {
            id: colorSelectionGrid
            objectName: "groupChatEdit_color"
            Layout.alignment: Qt.AlignHCenter
            diameter: 40
            selectorDiameter: 16
            columns: 6
            selectedColorIndex: -1
        }

        Item {
            id: spacerItem
            height: 10
        }
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                id: saveBtn
                objectName: "groupChatEdit_save"
                text: qsTr("Save changes")
                enabled: groupName.text.trim().length > 0 &&
                         ((groupName.text != root.activeGroupName) ||
                          (root.activeGroupColor != colorSelectionGrid.selectedColor) ||
                          (String(imageEditor.source).length > 0))
                onClicked : {
                    updateGroupChatDetails(groupName.text, colorSelectionGrid.selectedColor,
                                           Utils.getImageAndCropInfoJson(imageEditor.source, imageEditor.cropRect))
                }
            }
        }
    }
}
