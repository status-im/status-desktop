import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Control {
    id: root

    property bool isControlNode: true   
    property string communityName: ""
    property string communityColor: ""

    // Community transfer ownership related props:
    required property bool isPendingOwnershipRequest

    signal exportControlNodeClicked
    signal importControlNodeClicked
    signal learnMoreClicked
    signal finaliseOwnershipTransferClicked

    QtObject {
        id: d
        
        readonly property real verticalBreakPoint: 950
        readonly property bool twoRowsLayout: contentItem.width <= verticalBreakPoint

        property string paragraphTitle
        property string paragraphSubtitle
        property string primaryButtonText
        property string secondaryButtonText
        property string indicatorBgColor
        property string indicatorColor
        property string indicatorName
        property var primaryButtonAction: root.exportControlNodeClicked
    }

    contentItem: GridLayout {
        id: mainGrid
        columnSpacing: 16
        rowSpacing: 16

        StatusRoundIcon {
            id: icon
            Layout.row: 0
            Layout.column: 0
            color: d.indicatorBgColor
            asset.color: d.indicatorColor
            asset.name: d.indicatorName
        }

        ColumnLayout {
            id: paragraph
            Layout.row: 0
            Layout.column: 1
            Layout.columnSpan: d.twoRowsLayout ? 2 : 1
            Layout.fillWidth: true
            spacing: 4
            StatusBaseText {
                id: title
                Layout.fillWidth: true
                text: d.paragraphTitle
                font.pixelSize: 15
                font.bold: true
                color: Theme.palette.directColor1
                wrapMode: Text.WordWrap
            }

            StatusBaseText {
                id: subtitle
                Layout.fillWidth: true
                text: d.paragraphSubtitle
                font.pixelSize: 15
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.row: 0
            Layout.column: 3
        }

        RowLayout {
            Layout.row: d.twoRowsLayout ? 1 : 0
            Layout.column: d.twoRowsLayout ? 1 : 4
            Layout.alignment: Qt.AlignLeft

            StatusFlatButton {
                size: StatusBaseButton.Size.Small
                text:  qsTr("Learn more")
                icon.name: "external-link"
                onClicked: root.learnMoreClicked()
            }

            StatusButton {
                size: StatusBaseButton.Size.Small
                text: d.primaryButtonText
                onClicked: d.primaryButtonAction()
            }
        }
    }

    // Behavior
    states: [
        State {
            name: "isPendingOwnershipRequest"
            when: root.isPendingOwnershipRequest
            PropertyChanges { target: d; indicatorBgColor: Theme.palette.alphaColor(root.communityColor, 0.1) }
            PropertyChanges { target: d; indicatorColor: root.communityColor }
            PropertyChanges { target: d; paragraphTitle: qsTr("Finalise your ownership of the %1 Community").arg(root.communityName) }
            PropertyChanges { target: d; paragraphSubtitle: qsTr("You currently hodl the Owner token for %1. Make your device the control node to finalise ownership.").arg(root.communityName) }
            PropertyChanges { target: d; primaryButtonText: qsTr("Finalise %1 ownership").arg(root.communityName) }
            PropertyChanges { target: d; primaryButtonAction: root.finaliseOwnershipTransferClicked }
            PropertyChanges { target: d; indicatorName: "crown" }
        },
        State {
            name: "isControlNode"
            when: root.isControlNode && !root.isPendingOwnershipRequest
            PropertyChanges { target: d; indicatorBgColor: Theme.palette.successColor2 }
            PropertyChanges { target: d; indicatorColor: Theme.palette.successColor1 }
            PropertyChanges { target: d; paragraphTitle: qsTr("This device is currently the control node for the %1 Community").arg(root.communityName) }
            PropertyChanges { target: d; paragraphSubtitle: qsTr("For your Community to function correctly keep this device online with Status running as much as possible.") }
            PropertyChanges { target: d; primaryButtonText: qsTr("How to move control node") }
            PropertyChanges { target: d; primaryButtonAction: root.exportControlNodeClicked }
            PropertyChanges { target: d; indicatorName: "desktop" }
        },
        State {
            name: "isNotControlNode"
            when: !root.isControlNode && !root.isPendingOwnershipRequest
            PropertyChanges { target: d; indicatorBgColor: Theme.palette.primaryColor3 }
            PropertyChanges { target: d; indicatorColor: Theme.palette.primaryColor1 }
            PropertyChanges { target: d; paragraphTitle: qsTr("Make this device the control node for the %1 Community").arg(root.communityName) }
            PropertyChanges { target: d; paragraphSubtitle: qsTr("Ensure this is a device you can keep online with Status running.") }
            PropertyChanges { target: d; primaryButtonText: qsTr("Make this device the control node") }
            PropertyChanges { target: d; primaryButtonAction: root.importControlNodeClicked }
            PropertyChanges { target: d; indicatorName: "desktop" }
        }
    ]
}
