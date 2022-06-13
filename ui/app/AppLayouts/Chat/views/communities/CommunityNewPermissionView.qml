import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0

Flickable {
    id: root    

    signal createPermission()

    QtObject {
        id: d
        property bool isPrivate: false
        signal addHolding()
        signal addAllowance()
        signal addChannel()

        onAddHolding: console.log("TODO: Add who holds...")
        onAddAllowance: console.log("TODO: Is allowed to...")
        onAddChannel: console.log("TODO: In...")
    }

    contentWidth: mainLayout.width
    contentHeight: mainLayout.height
    clip: true
    flickableDirection: Flickable.AutoFlickIfNeeded

    ColumnLayout {
        id: mainLayout
        width: 560 // by design
        spacing: 24
        CurveSeparatorWithText {
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 14
            text: qsTr("Anyone")
        }
        StatusItemSelector {
            Layout.fillWidth: true
            Layout.topMargin: -parent.spacing
            icon: Style.svg("contact_verified")
            title: qsTr("Who holds")
            defaultItemText: qsTr("Example: 10 SNT")
            onAddItem: d.addHolding()
            Rectangle {
                  anchors.top: parent.bottom
                  anchors.left:parent.left
                  anchors.leftMargin: 16
                  width: 2
                  height: 24
                  color: Style.current.separator
            }
        }        
        StatusItemSelector {
            Layout.fillWidth: true
            icon: Style.svg("profile/security")
            iconSize: 24
            title: qsTr("Is allowed to")
            defaultItemText: qsTr("Example: View and post")
            onAddItem: d.addAllowance()
            Rectangle {
                  anchors.top: parent.bottom
                  anchors.left:parent.left
                  anchors.leftMargin: 16
                  width: 2
                  height: 24
                  color: Style.current.separator
            }
        }
        StatusItemSelector {
            Layout.fillWidth: true
            icon: Style.svg("create-category")
            iconSize: 24
            title: qsTr("In")
            defaultItemText: qsTr("Example: `#general` channel")
            onAddItem: d.addChannel()
        }
        Separator {}
        RowLayout {
            Layout.topMargin: -parent.spacing / 2
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: Layout.leftMargin
            spacing: 16
            StatusRoundIcon {
                icon.name: "hide"
            }
            ColumnLayout {
                Layout.fillWidth: true
                StatusBaseText {
                    text: qsTr("Private")
                    color: Theme.palette.directColor1
                    font.pixelSize: 15
                }
                StatusBaseText {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("Make this permission private to hide it from members who don’t meet it’s requirements")
                    color: Theme.palette.baseColor1
                    font.pixelSize: 15
                    lineHeight: 1.2
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    clip: true
                }
            }
            StatusSwitch {
                checked: d.isPrivate
                onCheckedChanged: { d.isPrivate = checked }
            }
        }
        // TODO: Needed `StatusButton` redesign that allows to fill the width.
        StatusButton {
            text: qsTr("Create permission")
            enabled: false
            height: 44
            Layout.alignment: Qt.AlignHCenter
            //Layout.fillWidth: true
            onClicked: root.createPermission()
        }
    }
}
