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

        const msInADay = 86400000
        const lastMessageInDays = Math.floor(previousMessageTimestamp / msInADay)
        const currentMessageInDays = Math.floor(messageTimestamp / msInADay)
        if(previousMessageTimestamp > 0 && currentMessageInDays <= lastMessageInDays)
            return ""

        let date = new Date()
        const currentYear = date.getFullYear()
        date.setTime(messageTimestamp)

        // FIXME Qt6: replace with Intl.DateTimeFormat
        const monthName = Qt.locale().standaloneMonthName(date.getMonth(), Locale.LongFormat)
        if (currentYear > date.getFullYear())
            return "%1 %2, %3".arg(monthName).arg(date.getDate()).arg(date.getFullYear())
        return "%1, %2".arg(monthName).arg(date.getDate())
    }
}
