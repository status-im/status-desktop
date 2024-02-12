import QtQuick 2.15
import QtQml 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusBaseText {
    id: root
    property double timestamp: 0
    property bool showFullTimestamp

    color: Theme.palette.baseColor1
    font.pixelSize: 10
    visible: !!text
    text: d.formattedLabel

    QtObject {
        id: d
        // initial value
        property string formattedLabel: root.showFullTimestamp ? LocaleUtils.formatDateTime(root.timestamp) : LocaleUtils.formatRelativeTimestamp(root.timestamp)

        // updates
        Binding on formattedLabel {
            when: !root.showFullTimestamp && root.timestamp && root.visible
            value: {
                StatusSharedUpdateTimer.secondsActive
                return LocaleUtils.formatRelativeTimestamp(root.timestamp)
            }
            restoreMode: Binding.RestoreBinding
        }
    }

    StatusToolTip {
        id: tooltip
        visible: hhandler.hovered && !!text
        maxWidth: 350
    }
    HoverHandler {
        id: hhandler
        enabled: !root.showFullTimestamp
        onHoveredChanged: {
            if(hhandler.hovered && root.timestamp) {
                tooltip.text = LocaleUtils.formatDateTime(root.timestamp)
            }
        }
    }
}
