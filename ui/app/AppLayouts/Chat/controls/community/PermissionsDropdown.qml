import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.panels 1.0


StatusDropdown {
    id: root

    property int mode: PermissionsDropdown.Mode.Add
    property int initialPermissionType: PermissionTypes.Type.None

    property bool enableAdminPermission: true

    enum Mode {
        Add, Update
    }

    signal done(int permissionType, string title, string asset)

    width: d.width
    padding: d.padding

    // force keeping within the bounds of the enclosing window
    margins: 0

    onAboutToShow: {
        group.checkState = Qt.Unchecked
        d.initialPermissionTypeChanged()
    }

    QtObject {
        id: d

        // internals
        readonly property int initialPermissionType: root.initialPermissionType

        // values from design
        readonly property int padding: 8
        readonly property int width: 289
        readonly property int sectionHeight: 34
        readonly property int sectionFontSize: 12
        readonly property int extraMarginForText: 8

        readonly property int separatorTopMargin: 4
        readonly property int separatorBottomMargin: 12

        readonly property int descriptionFontSize: 13
        readonly property int descriptionLineHeight: 18

        readonly property int buttonTopMargin: 32
    }

    ButtonGroup {
        id: group
    }

    contentItem: ColumnLayout {
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: d.sectionHeight

            StatusBaseText {
                anchors.margins: d.extraMarginForText
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("Community")
                color: Theme.palette.baseColor1
                font.pixelSize: d.sectionFontSize
                elide: Text.ElideRight
            }
        }

        PermissionListItem {
            readonly property int permissionType: PermissionTypes.Type.Admin
            readonly property string description: {
                const generalInfo = qsTr("Members who meet the requirements will be allowed to create and edit permissions, token sales, airdrops and subscriptions")
                const warning = qsTr("Be careful with assigning this permission.")
                const warningExplanation = qsTr("Only the community owner can modify admin permissions")

                const warningStyled = `<font color="${Theme.palette.dangerColor1}">${warning}</font>`
                return `${generalInfo}<br><br>${warningStyled} ${warningExplanation}`
            }

            title: qsTr("Become admin")
            asset.name: "admin"
            checked: d.initialPermissionType === permissionType
            buttonGroup: group

            enabled: root.enableAdminPermission

            Layout.fillWidth: true
        }

        PermissionListItem {
            readonly property int permissionType: PermissionTypes.Type.Member
            readonly property string description:
                qsTr("Anyone who meets the requirements will be allowed to join your community")

            title: qsTr("Become member")
            asset.name: "in-contacts"
            checked: d.initialPermissionType === permissionType
            buttonGroup: group

            Layout.fillWidth: true
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: d.sectionHeight

            StatusBaseText {
                anchors.margins: d.extraMarginForText
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("Channels")
                color: Theme.palette.baseColor1
                font.pixelSize: d.sectionFontSize
                elide: Text.ElideRight
            }
        }

        PermissionListItem {
            readonly property int permissionType: PermissionTypes.Type.Moderator
            readonly property string description:
                qsTr("Members who meet the requirements will be allowed to read, write, ban members and pin messages in the selected channels")

            title: qsTr("Moderate")
            asset.name: "arbitrator"
            checked: d.initialPermissionType === permissionType
            buttonGroup: group

            Layout.fillWidth: true
        }

        PermissionListItem {
            readonly property int permissionType: PermissionTypes.Type.ViewAndPost
            readonly property string description:
                qsTr("Members who meet the requirements will be allowed to read and write in the selected channels")

            title: qsTr("View and post")
            asset.name: "edit"
            checked: d.initialPermissionType === permissionType
            buttonGroup: group

            Layout.fillWidth: true
        }

        PermissionListItem {
            readonly property int permissionType: PermissionTypes.Type.Read
            readonly property string description:
                qsTr("Members who meet the requirements will be allowed to read the selected channels")

            title: qsTr("View only")
            asset.name: "show"
            checked: d.initialPermissionType === permissionType
            buttonGroup: group

            Layout.fillWidth: true
        }

        Separator {
            visible: !!group.checkedButton

            Layout.fillWidth: true
            Layout.topMargin: d.separatorTopMargin
            Layout.bottomMargin: d.separatorBottomMargin
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: d.extraMarginForText

            visible: !!group.checkedButton
            text: group.checkedButton ? group.checkedButton.item.description : ""

            textFormat: Text.StyledText
            wrapMode: Text.Wrap
            color: Theme.palette.baseColor1
            font.pixelSize: d.descriptionFontSize
            lineHeight: d.descriptionLineHeight
            lineHeightMode: Text.FixedHeight
        }

        StatusButton {
            Layout.fillWidth: true
            Layout.topMargin: d.buttonTopMargin

            text: root.mode === PermissionsDropdown.Mode.Add ? qsTr("Add") : qsTr("Update")
            enabled: !!group.checkedButton

            onClicked: root.done(group.checkedButton.item.permissionType,
                                 group.checkedButton.item.title,
                                 group.checkedButton.item.asset.name)
        }
    }
}
