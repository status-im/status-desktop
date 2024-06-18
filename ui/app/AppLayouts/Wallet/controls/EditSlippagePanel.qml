import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import shared.controls 1.0

import utils 1.0

Control {
    id: root

    property bool loading
    property var selectedToToken
    property string toTokenAmount
    property alias slippageValue: slippageSelector.value
    property alias valid: slippageSelector.valid

    QtObject {
        id: d
        readonly property string selectedToTokenSymbol: !!root.selectedToToken && !!root.selectedToToken.symbol ?
                                                   root.selectedToToken.symbol : ""
    }

    horizontalPadding: Style.current.padding
    verticalPadding: Style.current.bigPadding

    background: Rectangle {
        radius: 16
        border.width: 1
        border.color: Theme.palette.directColor8
        color: Theme.palette.indirectColor3
    }

    contentItem: ColumnLayout {
        id: baseLayout
        spacing: Style.current.bigPadding
        RowLayout {
            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Slippage tolerance")
                font.weight: Font.Medium
                lineHeight: button.implicitHeight
                lineHeightMode: Text.FixedHeight
                verticalAlignment: Text.AlignVCenter
            }
            StatusLinkText {
                id: button
                visible: slippageSelector.isEdited
                text: qsTr("Use default")
                normalColor: Theme.palette.primaryColor1
                onClicked: slippageSelector.reset()
            }
        }
        StatusBaseText {
            Layout.fillWidth: true
            Layout.topMargin: -12
            text: qsTr("Maximum deviation in price due to market volatility and liquidity allowed before the swap is cancelled. (%L1% default).").arg(slippageSelector.defaultValue)
            wrapMode: Text.Wrap
            color: Theme.palette.directColor5
        }
        /* TODO: error conditions for custom enteries missing will be done under -
        https://github.com/status-im/status-desktop/issues/15017 */
        SlippageSelector {
            id: slippageSelector
            objectName: "slippageSelector"
            Layout.fillWidth: true
        }
        StatusModalDivider {
            Layout.fillWidth: true
            Layout.topMargin: 0
            Layout.bottomMargin: -Style.current.smallPadding
            dividerColor: Theme.palette.directColor8
        }
        RowLayout {
            spacing: 4
            StatusBaseText {
                text: qsTr("Receive at least")
                font.pixelSize: 13
                font.weight: Font.Medium
            }
            StatusSmartIdenticon {
                Layout.preferredWidth: Style.current.padding
                Layout.preferredHeight: Style.current.padding
                asset.name: !!root.selectedToToken && !!root.selectedToToken.image
                              ? root.selectedToToken.image
                              : Constants.tokenIcon(d.selectedToTokenSymbol)
                asset.isImage: true
            }
            StatusTextWithLoadingState {
                text: {
                    let amount = !!root.toTokenAmount ? SQUtils.AmountsArithmetic.fromString(root.toTokenAmount) : NaN
                    let percentageAmount = 0
                    if(!Number.isNaN(amount)) {
                        percentageAmount = (amount - ((amount/100) * slippageSelector.value))
                    }
                    return ("%1 %2").arg(LocaleUtils.numberToLocaleString(percentageAmount)).arg(d.selectedToTokenSymbol)
                }
                font.pixelSize: 13
                font.weight: Font.Medium
                loading: root.loading
            }
        }
    }
}
