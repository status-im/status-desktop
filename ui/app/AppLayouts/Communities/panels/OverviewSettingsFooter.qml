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
    property int loginType: Constants.LoginType.Password
    property string communityName: ""

    signal primaryButtonClicked
    signal secondaryButtonClicked

    QtObject {
        id: d
        
        readonly property real verticalBreakPoint: 950
        readonly property bool twoRowsLayout: contentItem.width <= verticalBreakPoint

        property string paragraphTitle
        property string paragraphSubtitle
        property string primaryButtonText
        property string primaryButtonIcon
        property string secondaryButtonText
        property string secondaryButtonIcon
        property string indicatorBgColor
        property string indicatorColor
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
            asset.name: "desktop"
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
                text: d.secondaryButtonText
                icon.name: d.secondaryButtonIcon
                onClicked: root.secondaryButtonClicked()
            }

            StatusButton {
                size: StatusBaseButton.Size.Small
                text: d.primaryButtonText
                icon.name: d.primaryButtonIcon
                onClicked: root.primaryButtonClicked()
            }
        }
    }

    // Behavior
    states: [
        State {
            name: "isControlNode"
            when: root.isControlNode
            PropertyChanges { target: d; indicatorBgColor: Theme.palette.successColor2 }
            PropertyChanges { target: d; indicatorColor: Theme.palette.successColor1 }
            PropertyChanges { target: d; paragraphTitle: qsTr("This device is currently the control node for the %1 Community").arg(root.communityName) }
            PropertyChanges { target: d; paragraphSubtitle: qsTr("For your Community to function correctly keep this device online with Status running as much as possible.") }
            PropertyChanges { target: d; primaryButtonText: qsTr("Move control node") }
            PropertyChanges { target: d; primaryButtonIcon: Constants.authenticationIconByType[root.loginType] }
            PropertyChanges { target: d; secondaryButtonText: qsTr("Learn more") }
            PropertyChanges { target: d; secondaryButtonIcon: "external-link" }
        },
        State {
            name: "isNotControlNode"
            when: !root.isControlNode
            PropertyChanges { target: d; indicatorBgColor: Theme.palette.primaryColor3 }
            PropertyChanges { target: d; indicatorColor: Theme.palette.primaryColor1 }
            PropertyChanges { target: d; paragraphTitle: qsTr("Make this device the control node for the %1 Community").arg(root.communityName) }
            PropertyChanges { target: d; paragraphSubtitle: qsTr("You will need to input the Community private key. Ensure this is a device you can keep online with Status running.") }
            PropertyChanges { target: d; primaryButtonText: qsTr("Make this device the control node") }
            PropertyChanges { target: d; primaryButtonIcon: "" }
            PropertyChanges { target: d; secondaryButtonText: qsTr("Learn more") }
            PropertyChanges { target: d; secondaryButtonIcon: "external-link" }
        }
    ]
}
