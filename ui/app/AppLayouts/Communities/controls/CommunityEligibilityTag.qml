import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

import AppLayouts.Communities.helpers

import utils

Rectangle {
    id: root

    required property int /*PermissionTypes.Type*/ eligibleToJoinAs
    property bool isEditMode
    property bool isDirty

    implicitWidth: hintRow.implicitWidth + 2*Theme.padding
    implicitHeight: 40
    color: Theme.palette.baseColor2
    radius: height/2
    border.width: 1
    border.color: Theme.palette.indirectColor4

    QtObject {
        id: d
        readonly property var joinHint: PermissionTypes.getJoinEligibilityHint(root.eligibleToJoinAs, root.isEditMode, root.isDirty)
    }

    RowLayout {
        id: hintRow
        spacing: 4
        anchors.centerIn: parent

        StatusBaseText {
            text: d.joinHint[0]
        }
        StatusIcon {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            Layout.leftMargin: 2
            visible: !!icon
            icon: d.joinHint[2]
            color: Theme.palette.directColor1
        }
        StatusBaseText {
            text: d.joinHint[1]
            visible: !!text
            font.weight: Font.Medium
        }
    }
}
