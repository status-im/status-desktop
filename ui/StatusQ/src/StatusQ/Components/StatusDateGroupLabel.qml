import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusBaseText {
    id: root

    property int previousMessageIndex: -1
    property double previousMessageTimestamp
    property double messageTimestamp

    font.pixelSize: 13
    color: Theme.palette.baseColor1
    horizontalAlignment: Text.AlignHCenter

    text: {
        if (previousMessageIndex === -1)
            return "";

        const now = new Date()
        const yesterday = new Date()
        yesterday.setDate(now.getDate()-1)

        const currentMsgDate = new Date(messageTimestamp);
        const prevMsgDate = new Date(previousMessageTimestamp);

        if (!!prevMsgDate && currentMsgDate.getDay() === prevMsgDate.getDay())
            return "";

        if (now == currentMsgDate)
            return qsTr("Today");

        if (yesterday == currentMsgDate)
            return qsTr("Yesterday");

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

        return monthNames[currentMsgDate.getMonth()] + ", " + currentMsgDate.getDate();
    }
}
