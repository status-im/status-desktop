import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1

StatusBaseText {
    id: root

    property double previousMessageTimestamp
    property double messageTimestamp

    font.pixelSize: 13
    color: Theme.palette.baseColor1
    horizontalAlignment: Text.AlignHCenter

    text: {
        const currentMsgDate = new Date(messageTimestamp)
        const prevMsgDate = new Date(previousMessageTimestamp)

        if (prevMsgDate > 0 && currentMsgDate.getDay() === prevMsgDate.getDay())
            return "";

        const now = new Date();
        if (now.getFullYear() == currentMsgDate.getFullYear() && now.getMonth() == currentMsgDate.getMonth() && now.getDate() == currentMsgDate.getDate())
            return qsTr("Today");

        const yesterday = new Date();
        yesterday.setDate(now.getDate() - 1);
        if (yesterday.getFullYear() == currentMsgDate.getFullYear() && yesterday.getMonth() == currentMsgDate.getMonth() && yesterday.getDate() == currentMsgDate.getDate())
            return qsTr("Yesterday");

        // FIXME Qt6: replace with Intl.DateTimeFormat
        const monthName = Qt.locale().standaloneMonthName(currentMsgDate.getMonth(), Locale.LongFormat)
        if (now.getFullYear() > currentMsgDate.getFullYear())
            return "%1 %2, %3".arg(monthName).arg(currentMsgDate.getDate()).arg(currentMsgDate.getFullYear())
        return "%1, %2".arg(monthName).arg(currentMsgDate.getDate())
    }
}
