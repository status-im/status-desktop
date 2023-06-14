import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

Control {
    id: root

    // account, amount, symbol, network, feeText
    property alias model: repeater.model
    readonly property alias count: repeater.count

    property alias showSummary: summaryRow.visible
    property alias errorText: errorTxt.text
    property alias totalFeeText: totalFeeText.text

    property bool isFeeLoading: false
    property bool showAccounts: true

    QtObject {
        id: d

        readonly property int delegateHeightWhenAccountsHidden: 28
    }

    contentItem: ColumnLayout {
        spacing: Style.current.padding

        Repeater {
            id: repeater

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.showAccounts
                                        ? delegateColumn.implicitHeight
                                        : Math.max(delegateColumn.implicitHeight,
                                                   d.delegateHeightWhenAccountsHidden)

                ColumnLayout {
                    id: delegateColumn

                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter

                    RowLayout {
                        Layout.fillWidth: true

                        StatusBaseText {
                            Layout.fillWidth: true

                            text: qsTr("Airdropping %1 %2 on %3")
                                .arg(model.amount).arg(model.symbol)
                                .arg(model.network)

                            font.pixelSize: Style.current.primaryTextFontSize
                            elide: Text.ElideRight
                        }

                        StatusDotsLoadingIndicator {
                            Layout.rightMargin: Style.current.padding

                            visible: root.isFeeLoading
                        }

                        StatusBaseText {
                            text: model.feeText

                            visible: !root.isFeeLoading
                            font.pixelSize: Style.current.primaryTextFontSize
                            elide: Text.ElideMiddle
                            color: repeater.count === 1 ? Theme.palette.directColor1
                                                        : Theme.palette.baseColor1
                        }
                    }

                    StatusBaseText {
                        Layout.fillWidth: true

                        visible: root.showAccounts

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

            visible: summaryRow.visible

            color: Theme.palette.baseColor2
        }

        RowLayout {
            id: summaryRow

            Layout.fillWidth: true
            Layout.topMargin: Style.current.halfPadding

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
            Layout.fillWidth: true

            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Style.current.primaryTextFontSize
            color: Theme.palette.dangerColor1

            text: root.errorText
            visible: root.errorText !== ""
        }
    }
}
