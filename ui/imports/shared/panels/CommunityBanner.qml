import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1 as StatusQControls

import shared.panels 1.0
import shared.status 1.0

import utils 1.0

Rectangle {
    id: root

    property alias text: bannerText.text
    property alias buttonText: bannerButton.text
    property alias icon: bannerIcon.asset
    property string buttonTooltipText: ""
    property bool buttonLoading: false

    implicitWidth: 272
    implicitHeight: 168
    border.color: Style.current.border
    radius: 16
    color: Style.current.transparent

    signal buttonClicked()

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        propagateComposedEvents: true
        onClicked: {
            /* Prevents sending events to the component beneath
               if Right Mouse Button is clicked. */
            mouse.accepted = false;
        }
    }

    Rectangle {
        width: 70
        height: 4
        color: Style.current.background
        anchors.top: parent.top
        anchors.topMargin: -2
        anchors.horizontalCenter: parent.horizontalCenter
    }

    StatusRoundIcon {
        id: bannerIcon
        anchors.top: parent.top
        anchors.topMargin: -8
        anchors.horizontalCenter: parent.horizontalCenter
    }

    StatusBaseText {
        id: bannerText
        anchors.top: parent.top
        anchors.topMargin: 48
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 15
        color: Theme.palette.directColor1
        wrapMode: Text.WordWrap
        anchors.right: parent.right
        anchors.rightMargin: Style.current.xlPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.xlPadding
    }

    StatusQControls.StatusButton {
        id: bannerButton
        objectName: "communityBannerButton"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        font.weight: Font.Medium
        onClicked: {
            if (!root.buttonLoading) {
                root.buttonClicked()
            }
        }
        loading: root.buttonLoading

        StatusQControls.StatusToolTip {
            text: root.buttonTooltipText
            visible: !!root.buttonTooltipText && bannerButton.loading && bannerButton.hovered
        }
    }
}

