import QtQuick 2.13
import QtQuick.Layouts 1.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root
    title: qsTr("Swap")

    // This should be the only property which should be used when being launched from elsewhere
    property SwapFormData formData: SwapFormData {}

    bottomPadding: 16
    padding: 0

    background: StatusDialogBackground {
        implicitHeight: 846
        implicitWidth: 556
        color: Theme.palette.baseColor3
    }

    contentItem: Column {
        spacing: 5
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: "This area is a temporary placeholder"
            font.bold: true
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: "Selected account index: %1".arg(formData.selectedAccountIndex)
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: "Selected network: %1".arg(formData.selectedNetworkChainId)
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: "Selected from token: %1".arg(formData.fromTokensKey)
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: "from token amount: %1".arg(formData.fromTokenAmount)
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter
            text: "Selected to token: %1".arg(formData.toTokenKey)
        }
    }
}

