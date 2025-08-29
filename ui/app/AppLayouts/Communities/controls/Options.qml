import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Utils as StatusQUtils

import AppLayouts.Communities.popups

import utils

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
        readonly property string aboutPermissionsLink: Constants.statusHelpLinkPrefix + "communities/set-up-your-community-permissions"
    }

    StatusCheckBox {
        id: requestToJoinToggle
        Layout.fillWidth: true
        Layout.topMargin: Theme.padding
        Layout.preferredHeight: d.optionHeight
        text: checked ? qsTr("Request to join required") + "<br><font size='-1' color='%1'>".arg(Theme.palette.warningColor1) +
                        qsTr("Warning: Only token gated communities (or token gated channels inside non-token gated community) are encrypted") + "</font>"
                      : qsTr("Request to join required")
        leftSide: false
        padding: 0
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
                    onClicked: messageHistoryInfoPopupComponent.createObject(root).open()
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

    StatusWarningBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.padding
        borderColor: Theme.palette.baseColor2
        textColor: Theme.palette.directColor1
        icon: Theme.svg("token")
        iconColor: Theme.palette.directColor1
        iconAlignment: Qt.AlignVCenter
        isRowLayout: false
        text: qsTr("You can token-gate your community and channels anytime after creation using existing tokens or by minting new ones in the community admin area.")
        extraContentComponent: RowLayout {
            spacing: 0
            StatusLinkText {
                Layout.fillWidth: true
                text: qsTr("Learn more about token-gating")
                font.pixelSize: Theme.primaryTextFontSize
                normalColor: linkColor
                onClicked: Global.openLinkWithConfirmation(d.aboutPermissionsLink,
                                                           StatusQUtils.StringUtils.extractDomainFromLink(d.aboutPermissionsLink))
            }

            StatusIcon {
                icon: "external-link"
                color: Theme.palette.primaryColor1
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: Global.openLinkWithConfirmation(d.aboutPermissionsLink,
                                                               StatusQUtils.StringUtils.extractDomainFromLink(d.aboutPermissionsLink))
                }
            }
        }
    }


    Component {
        id: messageHistoryInfoPopupComponent

        EnableFullMessageHistoryPopup {
            onAccepted: Global.openLinkWithConfirmation(d.aboutHistoryServiceLink, StatusQUtils.StringUtils.extractDomainFromLink(d.aboutHistoryServiceLink))
            onClosed: destroy()
        }
    }
}
