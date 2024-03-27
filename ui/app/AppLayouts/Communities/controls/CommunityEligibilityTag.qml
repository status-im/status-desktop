import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Communities.helpers 1.0

import utils 1.0

Rectangle {
    id: root

    required property int /*PermissionTypes.Type*/ eligibleToJoinAs

    implicitWidth: hintRow.implicitWidth + 2*Style.current.padding
    implicitHeight: 40
    color: Theme.palette.baseColor2
    radius: height/2
    border.width: 1
    border.color: Theme.palette.indirectColor4

    QtObject {
        id: d
        readonly property var joinHint: PermissionTypes.getJoinEligibilityHint(root.eligibleToJoinAs)
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
