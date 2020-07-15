import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

StyledText {
    id: dateGroupLbl
    font.pixelSize: 13
    color: Style.current.darkGrey
    horizontalAlignment: Text.AlignHCenter
    anchors.horizontalCenter: parent.horizontalCenter
    text: {
        if (prevMessageIndex == -1) return ""; // identifier

        let now = new Date()
        let yesterday = new Date()
        yesterday.setDate(now.getDate()-1)

        let prevMsgTimestamp = chatsModel.messageList.getMessageData(prevMessageIndex, "timestamp")
        var currentMsgDate = new Date(parseInt(timestamp, 10));
        var prevMsgDate = prevMsgTimestamp === "" ? new Date(0) : new Date(parseInt(prevMsgTimestamp, 10));
        if(currentMsgDate.getDay() !== prevMsgDate.getDay()){
            if (now.toDateString() === currentMsgDate.toDateString()) {
                return qsTr("Today")
            } else if (yesterday.toDateString() === currentMsgDate.toDateString()) {
                //% "Yesterday"
                return qsTrId("yesterday")
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
                return monthNames[currentMsgDate.getMonth()] + ", " + currentMsgDate.getDay()
            }
        } else {
            return "";
        }

    }
    visible: text !== ""
    anchors.top: parent.top
    anchors.topMargin: this.visible ? 20 : 0
}
