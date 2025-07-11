import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import shared.panels
import shared.stores
import utils

Item {
    id: root

    property int nextMessageIndex
    property double nextMsgTimestamp
    
    signal clicked()
    signal timerTriggered()

    implicitHeight: childrenRect.height + Theme.smallPadding * 2

    QtObject {
        id: d
         readonly property string formattedDate: nextMessageIndex > -1 ? LocaleUtils.formatDate(nextMsgTimestamp) : LocaleUtils.formatDate()
    }

    Timer {
        id: timer
        interval: 3000
        onTriggered: {
            fetchLoaderIndicator.active = false;
            fetchMoreButton.visible = true;
            fetchDate.visible = true;
            root.timerTriggered();
        }
    }

    Separator {
        id: sep1
    }

    Loader {
        id: fetchLoaderIndicator
        anchors.top: sep1.bottom
        anchors.topMargin: Theme.padding
        anchors.left: parent.left
        anchors.right: parent.right
        active: false
        sourceComponent: StatusLoadingIndicator {
            width: 12
            height: 12
        }
    }
    StyledText {
        id: fetchMoreButton
        font.weight: Font.Medium
        font.pixelSize: Theme.primaryTextFontSize
        color: Theme.palette.primaryColor1
        text: qsTr("↓ Fetch more messages")
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: sep1.bottom
        anchors.topMargin: Theme.smallPadding
        StatusMouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
                root.clicked();
                fetchLoaderIndicator.active = true;
                fetchMoreButton.visible = false;
                fetchDate.visible = false;
                timer.start();
            }
        }
    }
    StyledText {
        id: fetchDate
        anchors.top: fetchMoreButton.bottom
        anchors.topMargin: 3
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        color: Theme.palette.secondaryText
        text: qsTr("Before %1").arg(d.formattedDate)
        visible: d.formattedDate
    }

    Separator {
        anchors.top: fetchDate.bottom
        anchors.topMargin: Theme.smallPadding
    }
}
