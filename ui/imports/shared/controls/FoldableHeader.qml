import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    property bool folded: false
    property alias title: label.text
    property alias titleColor: label.color
    property alias switchText: modeSwitch.text
    property alias checked: modeSwitch.checked
    property Component rightAdditionalComponent

    signal toggleFolding
    signal toggleSwitch

    height: headerContent.height
    z: 1

    color: Theme.palette.statusListItem.backgroundColor

    QtObject {
        id: d

        readonly property int sectionHeight: 64
    }

    RowLayout {
        id: headerContent

        width: parent.width
        height: d.sectionHeight

        StatusFlatButton {
            checkable: true
            size: StatusBaseButton.Size.Small
            icon.name: checked ? "chevron-down" : "next"
            textColor: Theme.palette.baseColor1
            textHoverColor: Theme.palette.directColor1

            checked: !root.folded
            onToggled: root.toggleFolding()
        }

        StatusBaseText {
            id: label

            Layout.fillWidth: true
        }
        StatusSwitch {
            id: modeSwitch
            objectName: "switch"

            visible: !!text && !!root.ListView.view && root.ListView.view.model && root.ListView.view.model.count
            LayoutMirroring.enabled: true
            LayoutMirroring.childrenInherit: true
            textColor: Theme.palette.baseColor1
            font.pixelSize: Theme.additionalTextSize
            onToggled: root.toggleSwitch()
        }
        Loader {
            sourceComponent: root.rightAdditionalComponent
        }
    }
}
