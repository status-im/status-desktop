import QtQuick 2.3
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.14

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1

Control{
    id: root

    property var holdingsListModel
    property var channelsListModel

    property int permissionType: PermissionTypes.Type.None
    property bool isPrivate: false
    property bool showButtons: true

    signal editClicked
    signal duplicateClicked
    signal removeClicked

    QtObject {
        id: d
        readonly property int flowRowHeight: 32
        readonly property int commonMargin: 16
        readonly property int designRadius: 16
        readonly property int itemTextPixelSize: 17
        readonly property int tagTextPixelSize: 15
        readonly property int buttonTextPixelSize: 12
        readonly property int buttonDiameter: 36
        readonly property int buttonTextSpacing: 6
    }
    background: Rectangle {
        color: "transparent"
        border.color: Theme.palette.baseColor2
        border.width: 1
        radius: d.designRadius
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            id: header
            color: Theme.palette.baseColor2
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            radius: d.designRadius

            RowLayout {
                anchors.fill: parent
                spacing: 8

                StatusIcon {
                    Layout.leftMargin: 19
                    icon: "checkmark"
                    Layout.preferredWidth: 11
                    Layout.preferredHeight: 8
                    color: Theme.palette.directColor1
                }

                StatusBaseText {
                    Layout.fillWidth: true
                    text: qsTr("Active")
                    font.pixelSize: d.tagTextPixelSize
                }

                StatusIcon {
                    Layout.rightMargin: 10
                    visible: root.isPrivate
                    icon: "hide"
                    color: Theme.palette.baseColor1
                }
            }
        }

        Flow {
            id: content
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 8
            Layout.rightMargin: d.commonMargin
            Layout.leftMargin: d.commonMargin
            Layout.bottomMargin: 20
            spacing: 6

            StatusBaseText {
                font.pixelSize: d.itemTextPixelSize
                height: d.flowRowHeight
                text: holdingsRepeater.count > 0 ? qsTr("Anyone who holds")
                                                 : qsTr("Anyone")
                verticalAlignment: Text.AlignVCenter
            }

            Repeater {
                id: holdingsRepeater

                model: root.holdingsListModel

                StatusListItemTag {
                    height: d.flowRowHeight
                    width: (implicitWidth > content.width) ? content.width : implicitWidth
                    leftPadding: 2
                    title: model.text
                    asset.name: model.imageSource
                    asset.isImage: !model.isIcon
                    asset.bgColor: "transparent"
                    asset.color: asset.isImage ? "transparent" : titleText.color
                    asset.height: 28
                    asset.width: asset.height
                    asset.bgHeight: asset.height
                    asset.bgWidth: asset.height
                    closeButtonVisible: false
                    titleText.color: Theme.palette.primaryColor1
                    titleText.font.pixelSize: d.tagTextPixelSize
                }
            }

            StatusBaseText {
                height: d.flowRowHeight
                font.pixelSize: d.itemTextPixelSize
                text: qsTr("is allowed to")
                verticalAlignment: Text.AlignVCenter
            }

            StatusListItemTag {
                height: d.flowRowHeight
                title: PermissionTypes.getName(root.permissionType)
                asset.name: PermissionTypes.getIcon(root.permissionType)
                asset.isImage: false
                asset.bgColor: "transparent"
                closeButtonVisible: false
                titleText.color: Theme.palette.primaryColor1
                titleText.font.pixelSize: d.tagTextPixelSize
            }

            StatusBaseText {
                height: d.flowRowHeight
                font.pixelSize: d.itemTextPixelSize
                text: qsTr("in")
                verticalAlignment: Text.AlignVCenter
            }

            Repeater {
                model: root.channelsListModel

                StatusListItemTag {
                    readonly property bool isLetterIdenticon: !model.imageSource

                    asset.isLetterIdenticon: isLetterIdenticon
                    asset.emoji: model.emoji ? model.emoji : ""
                    asset.color: model.color ? model.color : ""
                    asset.width: isLetterIdenticon ? 20 : 28
                    asset.height: asset.width

                    leftPadding: isLetterIdenticon ? 6 : 2

                    height: d.flowRowHeight
                    width: (implicitWidth > content.width)
                           ? content.width : implicitWidth

                    title: model.text
                    asset.name: model.imageSource ? model.imageSource : ""
                    asset.isImage: true
                    asset.bgColor: "transparent"
                    closeButtonVisible: false
                    titleText.color: Theme.palette.primaryColor1
                    titleText.font.pixelSize: d.tagTextPixelSize
                }
            }
        }

        RowLayout {
            id: footer
            visible: root.showButtons
            spacing: 85
            Layout.fillWidth: true
            Layout.bottomMargin: d.commonMargin
            Layout.alignment: Qt.AlignHCenter

            ColumnLayout {
                spacing: d.buttonTextSpacing
                StatusRoundButton {
                    Layout.alignment: Qt.AlignHCenter
                    icon.name: "edit_pencil"
                    Layout.preferredHeight: d.buttonDiameter
                    Layout.preferredWidth: Layout.preferredHeight
                    type: StatusRoundButton.Type.Primary
                    onClicked: root.editClicked()
                }
                StatusBaseText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Edit")
                    color: Theme.palette.primaryColor1
                    font.pixelSize: d.buttonTextPixelSize
                }
            }

            ColumnLayout {
                spacing: d.buttonTextSpacing
                StatusRoundButton {
                    Layout.alignment: Qt.AlignHCenter
                    icon.name: "copy"
                    Layout.preferredHeight: d.buttonDiameter
                    Layout.preferredWidth: Layout.preferredHeight
                    type: StatusRoundButton.Type.Primary
                    onClicked: root.duplicateClicked()
                }
                StatusBaseText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Duplicate")
                    color: Theme.palette.primaryColor1
                    font.pixelSize: d.buttonTextPixelSize
                }
            }

            ColumnLayout {
                spacing: d.buttonTextSpacing
                StatusRoundButton {
                    Layout.alignment: Qt.AlignHCenter
                    icon.name: "delete"
                    Layout.preferredHeight: d.buttonDiameter
                    Layout.preferredWidth: Layout.preferredHeight
                    type: StatusRoundButton.Type.Quaternary
                    onClicked: root.removeClicked()
                }
                StatusBaseText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Delete")
                    color: Theme.palette.dangerColor1
                    font.pixelSize: d.buttonTextPixelSize
                }
            }
        }
    }
}
