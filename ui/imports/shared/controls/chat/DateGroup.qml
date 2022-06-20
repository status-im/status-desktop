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
    font.pixelSize: Style.current.additionalTextSize
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
            //% "Today"
            return qsTrId("today")
        } else if (yesterday.toDateString() === currentMsgDate.toDateString()) {
            //% "Yesterday"
            return qsTrId("yesterday")
        } else {
            const monthNames = [
                //% "January"
                qsTrId("january"),
                //% "February"
                qsTrId("february"),
                //% "March"
                qsTrId("march"),
                //% "April"
                qsTrId("april"),
                //% "May"
                qsTrId("may"),
                //% "June"
                qsTrId("june"),
                //% "July"
                qsTrId("july"),
                //% "August"
                qsTrId("august"),
                //% "September"
                qsTrId("september"),
                //% "October"
                qsTrId("october"),
                //% "November"
                qsTrId("november"),
                //% "December"
                qsTrId("december")
            ];
            return monthNames[currentMsgDate.getMonth()] + ", " + currentMsgDate.getDate()
        }
    }
    visible: text !== ""
}
