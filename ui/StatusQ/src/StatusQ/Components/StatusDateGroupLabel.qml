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
        if (messageTimestamp === 0)
            return ""

        const currentMsgDate = new Date(messageTimestamp)
        const prevMsgDate = new Date(previousMessageTimestamp)

        if (prevMsgDate > 0 && currentMsgDate.getDay() <= prevMsgDate.getDay())
            return ""

        const now = new Date();
        // FIXME Qt6: replace with Intl.DateTimeFormat
        const monthName = Qt.locale().standaloneMonthName(currentMsgDate.getMonth(), Locale.LongFormat)
        if (now.getFullYear() > currentMsgDate.getFullYear())
            return "%1 %2, %3".arg(monthName).arg(currentMsgDate.getDate()).arg(currentMsgDate.getFullYear())
        return "%1, %2".arg(monthName).arg(currentMsgDate.getDate())
    }
}
