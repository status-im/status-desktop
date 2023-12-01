import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

ListView {
    id: root

    signal disconnect(string topic)

    spacing: 32

    delegate: Item {
        implicitWidth: delegateLayout.implicitWidth
        implicitHeight: delegateLayout.implicitHeight

        RowLayout {
            id: delegateLayout
            width: root.width

            StatusIcon {
                icon: model.peerMetadata.icons.length > 0 ? model.peerMetadata.icons[0] : ""
                visible: !!icon
            }

            StatusBaseText {
                text: `${model.peerMetadata.name}\n${model.peerMetadata.url}\nTopic: ${SQUtils.Utils.elideText(model.topic, 6, 6)}\nExpire: ${new Date(model.expiry * 1000).toLocaleString()}`
                color: model.active ? "green" : "orange"
            }

            StatusButton {
                text: "Disconnect"

                visible: model.active

                onClicked: {
                    root.disconnect(model.topic)
                }
            }
        }
    }
}
