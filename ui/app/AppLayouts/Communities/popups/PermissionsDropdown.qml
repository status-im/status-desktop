import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.panels 1.0

import AppLayouts.Communities.controls 1.0


StatusDropdown {
    id: root

    property int mode: PermissionsDropdown.Mode.Add
    property int initialPermissionType: PermissionTypes.Type.None

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

    contentItem: ColumnLayout {
        spacing: 0

        CustomSeparator {
            Layout.fillWidth: true
            Layout.preferredHeight: d.sectionHeight

            text: qsTr("Community")
        }

        CustomPermissionListItem {
            permissionType: PermissionTypes.Type.Admin
            enabled: root.enableAdminPermission

            Layout.fillWidth: true
        }

        CustomPermissionListItem {
            permissionType: PermissionTypes.Type.Member

            Layout.fillWidth: true
        }

        CustomSeparator {
            Layout.fillWidth: true
            Layout.preferredHeight: d.sectionHeight

            text: qsTr("Channels")
        }

        CustomPermissionListItem {
            permissionType: PermissionTypes.Type.ViewAndPost

            Layout.fillWidth: true
        }

        CustomPermissionListItem {
            permissionType: PermissionTypes.Type.Read

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

            onClicked: root.done(group.checkedButton.item.permissionType)
        }
    }
}
