import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared 1.0
import shared.panels 1.0
import shared.stores 1.0
import utils 1.0

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
        MouseArea {
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
