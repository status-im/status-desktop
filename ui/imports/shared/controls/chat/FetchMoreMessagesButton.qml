import QtQuick 2.13

import StatusQ.Components 0.1

import shared.panels 1.0
import shared.stores 1.0
import utils 1.0

Item {
    id: root
    height: childrenRect.height + Style.current.smallPadding * 2
    anchors.left: parent.left
    anchors.right: parent.right

    property int nextMessageIndex
    property string nextMsgTimestamp
    
    signal clicked()
    signal timerTriggered()

    QtObject {
        id: d
         readonly property string formattedDate: nextMessageIndex > -1 ? Utils.formatLongDate(nextMsgTimestamp * 1, RootStore.accountSensitiveSettings.isDDMMYYDateFormat) :
                                                                         Utils.formatLongDate(undefined, RootStore.accountSensitiveSettings.isDDMMYYDateFormat)
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
        anchors.topMargin: Style.current.padding
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
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.blue
        text: qsTr("↓ Fetch more messages")
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: sep1.bottom
        anchors.topMargin: Style.current.smallPadding
        MouseArea {
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
        color: Style.current.secondaryText
        text: qsTr("Before %1").arg(d.formattedDate)
        visible: d.formattedDate
    }

    Separator {
        anchors.top: fetchDate.bottom
        anchors.topMargin: Style.current.smallPadding
    }
}
