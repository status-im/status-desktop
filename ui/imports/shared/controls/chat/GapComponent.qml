import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme

import shared
import shared.panels
import shared.stores
import utils

Item {
    id: root

    property int gapFrom: 0
    property int gapTo: 0

    signal clicked()

    implicitHeight: childrenRect.height + Theme.smallPadding * 2

    Separator {
        id: sep1
    }
    StyledText {
        id: fetchMoreButton
        font.weight: Font.Medium
        font.pixelSize: Theme.primaryTextFontSize
        color: Theme.palette.primaryColor1
        text: qsTr("Fetch messages")
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: sep1.bottom
        anchors.topMargin: Theme.smallPadding
        StatusMouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
                root.clicked();
            }
        }
    }
    StyledText {
        id: fetchDate
        anchors.top: fetchMoreButton.bottom
        anchors.topMargin: 3
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        color: Theme.palette.secondaryText
        text: qsTr("Between %1 and %2").arg(LocaleUtils.formatDate(root.gapFrom * 1000)).arg(LocaleUtils.formatDate(root.gapTo * 1000))
    }
    Separator {
        anchors.top: fetchDate.bottom
        anchors.topMargin: Theme.smallPadding
    }
}
