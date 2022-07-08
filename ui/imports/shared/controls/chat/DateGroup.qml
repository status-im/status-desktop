import QtQuick 2.3

import shared 1.0
import shared.panels 1.0
import utils 1.0

StyledText {
    property bool isActivityCenterMessage: false
    property int previousMessageIndex: -1
    property string previousMessageTimestamp
    property string messageTimestamp

    id: dateGroupLbl
    font.pixelSize: 13
    color: Style.current.secondaryText
    horizontalAlignment: Text.AlignHCenter
    anchors.horizontalCenter: isActivityCenterMessage ? undefined : parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: visible ? (isActivityCenterMessage ? Style.current.halfPadding : 20) : 0
    anchors.left: parent.left
    anchors.leftMargin: isActivityCenterMessage ? Style.current.padding : 0

    text: {
        if (previousMessageIndex === -1) return ""; // identifier

        let now = new Date()
        let yesterday = new Date()
        yesterday.setDate(now.getDate()-1)

        let currentMsgDate = new Date(parseInt(messageTimestamp, 10));
        let prevMsgDate = previousMessageTimestamp === "" ? undefined : new Date(parseInt(previousMessageTimestamp, 10));

        if (!!prevMsgDate && currentMsgDate.getDay() === prevMsgDate.getDay()) {
            return ""
        }

        if (now.toDateString() === currentMsgDate.toDateString()) {
            return qsTr("Today")
        } else if (yesterday.toDateString() === currentMsgDate.toDateString()) {
            return qsTr("Yesterday")
        } else {
            const monthNames = [
                qsTr("January"),
                qsTr("February"),
                qsTr("March"),
                qsTr("April"),
                qsTr("May"),
                qsTr("June"),
                qsTr("July"),
                qsTr("August"),
                qsTr("September"),
                qsTr("October"),
                qsTr("November"),
                qsTr("December")
            ];
            return monthNames[currentMsgDate.getMonth()] + ", " + currentMsgDate.getDate()
        }
    }
    visible: text !== ""
}
