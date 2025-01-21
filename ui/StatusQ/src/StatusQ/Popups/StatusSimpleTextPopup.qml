import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root

    width: 600
    padding: 0
    standardButtons: Dialog.Ok

    property alias content: contentText

    signal linkActivated(string link)

    StatusScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth
        StatusBaseText {
            id: contentText
            width: scrollView.availableWidth
            wrapMode: Text.Wrap
            onLinkActivated: (link) => root.linkActivated(link)
        }
    }
}
