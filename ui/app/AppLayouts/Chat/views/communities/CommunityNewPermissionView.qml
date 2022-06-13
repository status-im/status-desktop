import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0

import "../../controls/community"

Flickable {
    id: root

    signal createPermission()

    QtObject {
        id: d
        property bool isPrivate: false
    }

    contentWidth: mainLayout.width
    contentHeight: mainLayout.height
    clip: true
    flickableDirection: Flickable.AutoFlickIfNeeded

    ColumnLayout {
        id: mainLayout
        width: 560 // by design
        spacing: 0
        CurveSeparatorWithText {
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 14
            text: qsTr("Anyone")
        }
        StatusItemSelector {
            id: tokensSelector
            Layout.fillWidth: true
            icon: Style.svg("contact_verified")
            title: qsTr("Who holds")
            defaultItemText: qsTr("Example: 10 SNT")
            andOperatorText: qsTr("and")
            orOperatorText: qsTr("or")
            popupItem: HoldingsDropdown {
                id: dropdown
                withOperatorSelector: tokensSelector.itemsModel.count > 0
                onAddToken: {                    
                    tokensSelector.addItem(tokenText, tokenImage, operator)
                    dropdown.close()
                }
            }
        }
        Rectangle {
            Layout.leftMargin: 16
            Layout.preferredWidth: 2
            Layout.preferredHeight: 24
            color: Style.current.separator
        }
        StatusItemSelector {
            Layout.fillWidth: true
            icon: Style.svg("profile/security")
            iconSize: 24
            title: qsTr("Is allowed to")
            defaultItemText: qsTr("Example: View and post")
        }
        Rectangle {
            Layout.leftMargin: 16
            Layout.preferredWidth: 2
            Layout.preferredHeight: 24
            color: Style.current.separator
        }
        StatusItemSelector {
            Layout.fillWidth: true
            icon: Style.svg("create-category")
            iconSize: 24
            title: qsTr("In")
            defaultItemText: qsTr("Example: `#general` channel")
        }
        Separator {
            Layout.topMargin: 24
        }
        RowLayout {
            Layout.topMargin: 12
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
            Layout.topMargin: 24
            text: qsTr("Create permission")
            enabled: false
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter
            //Layout.fillWidth: true
            onClicked: root.createPermission()
        }
    }
}
