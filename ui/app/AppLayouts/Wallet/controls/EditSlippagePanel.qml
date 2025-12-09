import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Popups
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils

import shared.controls

import utils

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

    horizontalPadding: Theme.padding
    verticalPadding: Theme.bigPadding

    background: Rectangle {
        radius: 16
        border.width: 1
        border.color: Theme.palette.directColor8
        color: Theme.palette.indirectColor3
    }

    contentItem: ColumnLayout {
        id: baseLayout
        spacing: Theme.bigPadding
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
        https://github.com/status-im/status-app/issues/15017 */
        SlippageSelector {
            id: slippageSelector
            objectName: "slippageSelector"
            Layout.fillWidth: true
        }
        StatusModalDivider {
            Layout.fillWidth: true
            Layout.topMargin: 0
            Layout.bottomMargin: -Theme.smallPadding
            dividerColor: Theme.palette.directColor8
        }
        RowLayout {
            spacing: 4
            StatusBaseText {
                text: qsTr("Receive at least")
                font.pixelSize: Theme.additionalTextSize
                font.weight: Font.Medium
            }
            StatusSmartIdenticon {
                Layout.preferredWidth: Theme.padding
                Layout.preferredHeight: Theme.padding
                asset.name: !!root.selectedToToken && !!root.selectedToToken.image
                              ? root.selectedToToken.image
                              : Constants.tokenIcon(d.selectedToTokenSymbol)
                asset.isImage: true
            }
            StatusTextWithLoadingState {
                text: {
                    const amount = !!root.toTokenAmount ? SQUtils.AmountsArithmetic.fromString(root.toTokenAmount).times(1 - slippageSelector.value/100)
                                                        : 0
                    return ("%1 %2").arg(LocaleUtils.numberToLocaleString(amount.toFixed())).arg(d.selectedToTokenSymbol)
                }
                font.pixelSize: Theme.additionalTextSize
                font.weight: Font.Medium
                loading: root.loading
            }
        }
    }
}
