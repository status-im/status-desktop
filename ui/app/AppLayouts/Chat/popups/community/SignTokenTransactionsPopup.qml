import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusDialog {
    id: root

    property alias accountName: accountText.text
    property alias feeText: feeText.text
    property alias errorText: errorTxt.text
    property alias isFeeLoading: feeLoading.visible

    property string tokenName
    property string networkName

    signal signTransactionClicked()
    signal cancelClicked()

    QtObject {
        id: d

        property int minTextWidth: 50
    }

    implicitWidth: 520 // by design
    topPadding: 2 * Style.current.padding // by design
    bottomPadding: topPadding
    contentItem: ColumnLayout {
        id: column

        spacing: Style.current.padding

        RowLayout {
            id: accountRow

            Layout.fillWidth: true

            StatusBaseText {
                Layout.maximumWidth: accountRow.width - accountRow.spacing - accountText.implicitWidth
                Layout.minimumWidth: d.minTextWidth
                text: qsTr("Account:")
                horizontalAlignment: Text.AlignLeft
                font.pixelSize: Style.current.primaryTextFontSize
                elide: Text.ElideMiddle
            }

            StatusBaseText {
                id: accountText

                Layout.fillWidth: true
                Layout.minimumWidth: d.minTextWidth
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideRight
                font.pixelSize: Style.current.primaryTextFontSize
            }
        }

        RowLayout {
            id: feeRow

            Layout.fillWidth: true

            StatusBaseText {
                Layout.maximumWidth: feeRow.width - feeRow.spacing - (root.isFeeLoading ? feeLoading.implicitWidth : feeText.implicitWidth)
                Layout.minimumWidth: d.minTextWidth
                text: qsTr("%1 transaction fee:").arg(root.networkName)
                horizontalAlignment: Text.AlignLeft
                font.pixelSize: Style.current.primaryTextFontSize
                elide: Text.ElideMiddle
            }

            // Filler
            Item {
                visible: feeLoading.visible
                Layout.fillWidth: true
            }

            StatusDotsLoadingIndicator {
                id: feeLoading
            }

            StatusBaseText {
                id: feeText

                visible: !feeLoading.visible
                Layout.fillWidth: true
                Layout.minimumWidth: d.minTextWidth
                horizontalAlignment: Text.AlignRight
                color: Theme.palette.baseColor1
                elide: Text.ElideRight
                font.pixelSize: Style.current.primaryTextFontSize
            }
        }

        StatusBaseText {
            id: errorTxt

            Layout.fillWidth: true
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
            font.pixelSize: Style.current.primaryTextFontSize
            color: Theme.palette.dangerColor1
            visible: root.errorText !== ""
        }
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
        rightButtons: ObjectModel {
            StatusButton {
                text: qsTr("Cancel")
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    root.cancelClicked()
                    root.close()
                }
            }
            StatusButton {
                enabled: root.errorText === "" && !root.isFeeLoading
                icon.name: "password"
                text: qsTr("Sign transaction")
                onClicked: {
                    root.signTransactionClicked()
                    root.close()
                }
            }
        }
    }
}
