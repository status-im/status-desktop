import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusDialog {
    id: root

    // account, amount, symbol, network, feeText
    property alias model: repeater.model
    property alias showSummary: summaryRow.visible
    property alias errorText: errorTxt.text
    property alias totalFeeText: totalFeeText.text

    property bool isFeeLoading

    signal signTransactionClicked()
    signal cancelClicked()

    QtObject {
        id: d

        property int minTextWidth: 50
    }

    implicitWidth: 600 // by design
    topPadding: 2 * Style.current.padding // by design
    bottomPadding: topPadding

    contentItem: ColumnLayout {
        id: column

        spacing: Style.current.padding

        Repeater {
            id: repeater

            Item {
                Layout.fillWidth: true

                implicitHeight: delegateColumn.implicitHeight

                ColumnLayout {
                    id: delegateColumn

                    width: parent.width

                    RowLayout {
                        Layout.fillWidth: true

                        StatusBaseText {
                            Layout.fillWidth: true

                            text: qsTr("Airdropping %1 %2 on %3")
                                .arg(model.amount).arg(model.symbol)
                                .arg(model.network)

                            font.pixelSize: Style.current.primaryTextFontSize
                            elide: Text.ElideMiddle
                        }

                        StatusDotsLoadingIndicator {
                            visible: root.isFeeLoading

                            Layout.rightMargin: Style.current.padding
                        }

                        StatusBaseText {
                            text: model.feeText

                            font.pixelSize: Style.current.primaryTextFontSize
                            elide: Text.ElideMiddle

                            color: Theme.palette.baseColor1

                            visible: !root.isFeeLoading
                        }
                    }

                    StatusBaseText {
                        Layout.fillWidth: true

                        text: qsTr("via %1").arg(model.account)
                        horizontalAlignment: Text.AlignLeft
                        font.pixelSize: Style.current.primaryTextFontSize
                        elide: Text.ElideMiddle

                        color: Theme.palette.baseColor1
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: Theme.palette.baseColor2
        }

        RowLayout {
            id: summaryRow

            Layout.fillHeight: false
            Layout.fillWidth: true

            Layout.topMargin: Style.current.halfPadding
            Layout.bottomMargin: -Style.current.halfPadding

            StatusBaseText {
                Layout.fillWidth: true

                text: qsTr("Total")

                font.pixelSize: Style.current.primaryTextFontSize
                elide: Text.ElideMiddle
            }

            StatusDotsLoadingIndicator {
                visible: root.isFeeLoading

                Layout.rightMargin: Style.current.padding
            }

            StatusBaseText {
                id: totalFeeText

                font.pixelSize: Style.current.primaryTextFontSize
                visible: !root.isFeeLoading
            }
        }

        StatusBaseText {
            id: errorTxt

            Layout.topMargin: Style.current.halfPadding
            Layout.bottomMargin: -Style.current.halfPadding
            Layout.fillWidth: true

            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Style.current.primaryTextFontSize
            color: Theme.palette.dangerColor1

            text: root.errorText
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
