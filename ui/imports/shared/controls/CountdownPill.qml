import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Communities.controls 1.0

IssuePill {
    id: root

    // request timestamp
    required property date timestamp
    onTimestampChanged: Qt.callLater(reset)

    // expiration timeout in seconds; min 5 minutes, max 7 days
    required property int expirationSeconds
    onExpirationSecondsChanged: Qt.callLater(reset)

    readonly property bool isExpired: expirationSeconds > 0 && d.secsDiff <= 0
    readonly property int remainingSeconds: d.secsDiff

    signal expired

    iconLoaderComponent: StatusCircularProgressBar {
        value: d.progress
        primaryColor: root.baseColor
        secondaryColor: root.background.border.color
    }

    implicitHeight: 32
    text: d.secsDiff < 0 ? qsTr("Expired") : d.formatSeconds(d.secsDiff + 1)

    type: {
        if (d.secsDiff < 60) // under 1 minute
            return CountdownPill.Type.Error
        if (d.secsDiff < 60 * 5) // under 5 minutes
            return CountdownPill.Type.Warning
        return CountdownPill.Type.Primary
    }

    font.family: Theme.palette.codeFont.name

    function reset() {
        if (expirationSeconds === 0) {
            timer.stop()
            return
        }

        const newTimestamp = timestamp
        newTimestamp.setSeconds(newTimestamp.getSeconds() + expirationSeconds)
        d.expirationTimestamp = newTimestamp

        d.ticker = 0
        d.secsDiff = 0

        console.warn("!!! RESET at:", timestamp, "; expires:", d.expirationTimestamp)

        if (d.expirationTimestamp <= new Date()) {
            console.warn("Expiration time set in past, or expired already on:", d.expirationTimestamp)
            d.secsDiff = -1
            timer.stop()
            root.expired()
            return
        }

        timer.restart()
    }

    QtObject {
        id: d
        readonly property real progress: d.secsDiff >= 0 ? d.secsDiff/(d.expirationTimestamp.valueOf() - timestamp.valueOf()) * 1000
                                                         : 0

        property var expirationTimestamp: root.timestamp
        property int secsDiff
        property int ticker

        function formatSeconds(seconds) {
            const isoString = new Date(seconds * 1000).toISOString()
            const days = Math.floor(seconds/86400)
            const hrs = parseInt(isoString.substring(11, 13))
            const mins = parseInt(isoString.substring(14, 16))

            var result = []
            if (days > 0)
                result.push(qsTr("%1d", "x days").arg(days))
            if (hrs > 0)
                result.push(qsTr("%1h", "x hours").arg(hrs))
            if (mins > 0) {
                if (days === 0 && hrs === 0 ) // long form
                    result.push(qsTr("%n min(s)", "", mins))
                else
                    result.push(qsTr("%1m", "x minutes").arg(mins))
            }
            if (days === 0 && hrs === 0 && mins === 0) {
                const secs = parseInt(isoString.substring(17, 19))
                if (secs >= 0)
                    result.push(qsTr("%n sec(s)", "", secs))
            }
            return result.join(" ")
        }
    }

    Timer  {
        id: timer
        repeat: true
        interval: 1000
        triggeredOnStart: true
        onTriggered: {
            d.ticker++
            d.secsDiff = (d.expirationTimestamp.valueOf() - root.timestamp.valueOf() - d.ticker*1000)/1000
            console.warn("!!! REMAINING SECS:", d.secsDiff, "; PROGRESS:", d.progress)
            if (d.secsDiff < 0) { // we let it run 1 more second to finish the animation
                timer.stop()
                root.expired()
            }
        }
    }

    StatusToolTip {
        id: tooltip
        visible: root.hovered && !!text
        text: root.isExpired ? qsTr("Expired on: %1").arg(LocaleUtils.formatDateTime(d.expirationTimestamp))
                             : qsTr("Expires on: %1").arg(LocaleUtils.formatDateTime(d.expirationTimestamp))
    }
}
