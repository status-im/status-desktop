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

    objectName: "communityPermissionItem"

    property var holdingsListModel
    property var channelsListModel

    property int permissionType: PermissionTypes.Type.None
    property int permissionState: PermissionTypes.State.Approved
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
        readonly property int headerIconleftMargin: 20
        readonly property bool isActiveState: root.permissionState === PermissionTypes.State.Approved
        readonly property bool isDeletingState: root.permissionState === PermissionTypes.State.RemovalPending

        function getStateText(state) {
            if(state === PermissionTypes.State.Approved)
                return qsTr("Active")

            if(state === PermissionTypes.State.AdditionPending)
                return qsTr("Pending, will become active once owner node comes online")

            if(state === PermissionTypes.State.RemovalPending)
                return qsTr("Deletion pending, will be deleted once owner node comes online")

            if(state === PermissionTypes.State.UpdatePending)
                return qsTr("Pending updates will be applied when owner node comes online")
        }
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
                    Layout.leftMargin: d.headerIconleftMargin

                    visible: d.isActiveState
                    icon: "checkmark"
                    Layout.preferredWidth: 11
                    Layout.preferredHeight: 8
                    color: Theme.palette.directColor1
                }

                StatusDotsLoadingIndicator {
                    Layout.leftMargin: d.headerIconleftMargin

                    visible: !d.isActiveState
                }

                StatusBaseText {
                    Layout.fillWidth: true
                    text: d.getStateText(root.permissionState)
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
                    objectName: "whoHoldsStatusListItem"
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

            ListModel {
                id: tokenOwnerModel

                ListElement { permissionType: PermissionTypes.Type.Owner }
                ListElement { permissionType: PermissionTypes.Type.TokenMaster }
                ListElement { permissionType: PermissionTypes.Type.Admin }
            }

            ListModel {
                id: tokenMasterModel
                ListElement { permissionType: PermissionTypes.Type.TokenMaster }
                ListElement { permissionType: PermissionTypes.Type.Admin }
            }

            ListModel {
                id: regularRoleModel
                ListElement { permissionType: PermissionTypes.Type.None }
            }

            Repeater {
                id: rolesRepeater

                model: {
                    if (root.permissionType === PermissionTypes.Type.Owner)
                        return tokenOwnerModel
                    if (root.permissionType === PermissionTypes.Type.TokenMaster)
                        return tokenMasterModel
                    return regularRoleModel
                }

                Flow {
                    spacing: 6

                    StatusListItemTag {
                        objectName: "isAllowedStatusListItem"
                        height: d.flowRowHeight
                        title: PermissionTypes.getName(model.permissionType === PermissionTypes.Type.None
                                                       ? root.permissionType : model.permissionType)
                        asset.name: PermissionTypes.getIcon(root.permissionType)
                        asset.isImage: false
                        asset.bgColor: "transparent"
                        closeButtonVisible: false
                        titleText.color: Theme.palette.primaryColor1
                        titleText.font.pixelSize: d.tagTextPixelSize
                    }

                    StatusBaseText {
                        height: d.flowRowHeight
                        visible: model.index < rolesRepeater.model.count  - 1
                        font.pixelSize: d.itemTextPixelSize
                        text: qsTr("and")
                        verticalAlignment: Text.AlignVCenter

                    }
                }
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
                    objectName: "inCommunityStatusListItem"
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

                    // FIXME: implement undo operation first
                    enabled: d.isActiveState
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

                    // FIXME: implement undo operation first
                    enabled: d.isActiveState
                }
                StatusBaseText {
                    Layout.alignment: Qt.AlignHCenter
                    text: /*d.isDeletingState*/false ? qsTr("Undo delete") : qsTr("Delete")
                    color: Theme.palette.dangerColor1
                    font.pixelSize: d.buttonTextPixelSize
                }
            }
        }
    }
}
