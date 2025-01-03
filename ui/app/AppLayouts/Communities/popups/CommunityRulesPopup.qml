import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0

import AppLayouts.Communities.panels 1.0

StatusModal {
    id: root

    property var community

    headerSettings.title: qsTr("%1 community rules").arg(community.name)

    contentItem: StatusScrollView {
        id: scrollView
        contentWidth: availableWidth

        ColumnLayout {
            width: scrollView.availableWidth
            spacing: 24

            StatusSmartIdenticon {
                Layout.alignment: Qt.AlignHCenter
                name: asset.isImage ? "" : community.name
                asset.isImage: community.image !== ""
                asset.name: community.image
                asset.isLetterIdenticon: !asset.isImage
                asset.color: community.color
                asset.charactersLen: 1
                asset.useAcronymForLetterIdenticon: false
                asset.width: 64
                asset.height: 64
            }

            StatusBaseText {
                text: community.introMessage
                Layout.fillWidth: true
                Layout.fillHeight: true
                wrapMode: Text.WordWrap
            }
        }
    }

    rightButtons: [
        StatusButton {
            text: qsTr("Done")
            onClicked: root.close()
        }
    ]
}
