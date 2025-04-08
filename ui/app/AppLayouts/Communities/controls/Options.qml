import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Communities.popups 1.0

import utils 1.0

ColumnLayout {
    id: root

    property alias archiveSupportEnabled: archiveSupportToggle.checked
    property alias requestToJoinEnabled: requestToJoinToggle.checked
    property alias pinMessagesEnabled: pinMessagesToggle.checked
    property alias archiveSupporVisible: archiveSupport.visible

    spacing: 0

    QtObject {
        id: d
        readonly property int optionHeight: 64
        readonly property string aboutHistoryServiceLink: Constants.statusHelpLinkPrefix + "communities/about-the-community-history-service"
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        StatusCheckBox {
            id: requestToJoinToggle
            Layout.fillWidth: true
            Layout.preferredHeight: d.optionHeight
            Layout.alignment: Qt.AlignVCenter
            text: qsTr("Request to join required")
            leftSide: false
            padding: 0
            spacing: 0
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.rightMargin: 64
            visible: requestToJoinToggle.checked
            wrapMode: Text.WordWrap
            text: qsTr("Warning: Only token gated communities (or token gated channels inside non-token gated community) are encrypted")
            font.pixelSize: Theme.tertiaryTextFontSize
            color: Theme.palette.warningColor1
        }
    }

    Item {
        id: archiveSupport

        Layout.fillWidth: true
        Layout.preferredHeight: visible ? d.optionHeight : 0

        StatusCheckBox {
            id: archiveSupportToggle

            width: parent.width
            leftSide: false
            padding: 0
            anchors.verticalCenter: parent.verticalCenter

            contentItem: Item {
                width: archiveSupportToggle.availableWidth

                StatusFlatButton {
                    id: infoBtn

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: archiveSupportToggle.indicator.width + Theme.halfPadding
                    anchors.left: parent.left
                    textColor: Theme.palette.directColor5
                    textHoverColor: Theme.palette.primaryColor1
                    icon.name: "info"
                    onClicked: Global.openPopup(messageHistoryInfoPopupComponent)
                }

                StatusBaseText {
                    width: parent.width - infoBtn.width - archiveSupportToggle.indicator.width - Theme.halfPadding
                    text: qsTr("New members can see full message history")
                    font: archiveSupportToggle.font
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    lineHeight: 1.2
                }
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: d.optionHeight

        StatusCheckBox {
            id: pinMessagesToggle

            width: parent.width
            leftSide: false
            padding: 0
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Any member can pin a message")
        }
    }

    Component {
        id: messageHistoryInfoPopupComponent

        EnableFullMessageHistoryPopup {
            onAccepted: Global.openLinkWithConfirmation(d.aboutHistoryServiceLink, StatusQUtils.StringUtils.extractDomainFromLink(d.aboutHistoryServiceLink))
        }
    }
}
