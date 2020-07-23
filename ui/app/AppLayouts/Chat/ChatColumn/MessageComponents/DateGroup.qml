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
        } else {
            return "";
        }

    }
    visible: text !== ""
    anchors.top: parent.top
    anchors.topMargin: this.visible ? 20 : 0
}
