import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

import shared.panels

import AppLayouts.Communities.controls


StatusDropdown {
    id: root

    property int mode: PermissionsDropdown.Mode.Add
    property int initialPermissionType: PermissionTypes.Type.None
    property bool allowCommunityOptions: true

    property bool enableAdminPermission: true

    enum Mode {
        Add, Update
    }

    signal done(int permissionType)

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

        component CustomSeparator: Item {
            property alias text: baseText.text

            StatusBaseText {
                id: baseText

                anchors.margins: d.extraMarginForText
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                color: Theme.palette.baseColor1
                font.pixelSize: d.sectionFontSize
                elide: Text.ElideRight
            }
        }

        component CustomPermissionListItem: PermissionListItem {
            required property int permissionType
            required property string description

            title: PermissionTypes.getName(permissionType)
            description: PermissionTypes.getDescription(permissionType)
            asset.name: PermissionTypes.getIcon(permissionType)
            checked: d.initialPermissionType === permissionType

            buttonGroup: group
        }
    }

    ButtonGroup {
        id: group
    }

    ColumnLayout {
        spacing: 0
        anchors.fill: parent

        CustomSeparator {
            Layout.fillWidth: true
            Layout.preferredHeight: d.sectionHeight
            visible: root.allowCommunityOptions
            text: qsTr("Community")
        }

        CustomPermissionListItem {
            permissionType: PermissionTypes.Type.Admin
            enabled: root.enableAdminPermission
            visible: root.allowCommunityOptions

            Layout.fillWidth: true
            objectName: "becomeAdmin"
        }

        CustomPermissionListItem {
            permissionType: PermissionTypes.Type.Member

            visible: root.allowCommunityOptions
            Layout.fillWidth: true
            objectName: "becomeMember"
        }

        CustomSeparator {
            Layout.fillWidth: true
            Layout.preferredHeight: d.sectionHeight

            text: qsTr("Channels")
        }

        CustomPermissionListItem {
            permissionType: PermissionTypes.Type.ViewAndPost

            Layout.fillWidth: true
            objectName: "viewAndPost"
        }

        CustomPermissionListItem {
            permissionType: PermissionTypes.Type.Read

            Layout.fillWidth: true
            objectName: "viewOnly"
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
            objectName: "addButton"

            text: root.mode === PermissionsDropdown.Mode.Add ? qsTr("Add") : qsTr("Update")
            enabled: !!group.checkedButton

            onClicked: root.done(group.checkedButton.item.permissionType)
        }
    }
}
