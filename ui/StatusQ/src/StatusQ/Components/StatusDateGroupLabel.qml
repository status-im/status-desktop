import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusBaseText {
    id: root

    property double previousMessageTimestamp
    property double messageTimestamp

    readonly property int msInADay: 86400000
    readonly property int lastMessageInDays: previousMessageTimestamp / msInADay
    readonly property int currentMessageInDays: messageTimestamp / msInADay

    font.pixelSize: 13
    color: Theme.palette.baseColor1
    horizontalAlignment: Text.AlignHCenter

    text: {
        if (messageTimestamp === 0)
            return ""

        if(previousMessageTimestamp > 0 && currentMessageInDays <= lastMessageInDays)
            return ""

        return LocaleUtils.formatDate(messageTimestamp)
    }
}
