import QtQuick

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Core.Theme

import AppLayouts.Communities.controls

IssuePill {
    id: root

    // request timestamp
    required property date timestamp
    onTimestampChanged: Qt.callLater(reset)

    // expiration timeout in seconds; min 5 minutes, max 7 days
    required property int expirationSeconds
    onExpirationSecondsChanged: Qt.callLater(reset)

    readonly property bool isExpired: remainingSeconds <= 0
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

    font.family: Fonts.codeFont.family

    function reset() {
        if (expirationSeconds === 0) {
            timer.stop()
            d.secsDiff = -1
            root.expired()
            return
        }

        const newTimestamp = timestamp
        newTimestamp.setSeconds(newTimestamp.getSeconds() + expirationSeconds)
        d.expirationTimestamp = newTimestamp

        d.ticker = 0
        d.secsDiff = 0

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

        property date expirationTimestamp: root.timestamp
        property int secsDiff
        property int ticker

        function formatSeconds(seconds) {
            const days = Math.floor(seconds / 86400)
            const hrs = Math.floor(seconds / 3600) % 24
            const mins = Math.floor(seconds / 60) % 60

            const result = []
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
                const secs = Math.floor(seconds)
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
