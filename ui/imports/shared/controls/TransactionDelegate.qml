import QtQuick 2.13
import QtQuick.Layouts 1.3

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0

StatusListItem {
    id: root

    property alias cryptoValueText: cryptoValueText
    property alias fiatValueText: fiatValueText

    property var modelData
    property string symbol
    property bool isIncoming
    property int transferStatus
    property var cryptoValue
    property var fiatValue
    property string networkIcon
    property string networkColor
    property string networkName
    property string shortTimeStamp
    property string savedAddressName

    state: "normal"
    asset.isImage: !loading
    asset.name: root.symbol ? Style.png("tokens/%1".arg(root.symbol)) : ""
    asset.isLetterIdenticon: loading
    title: modelData !== undefined && !!modelData ?
               isIncoming ? qsTr("Receive %1").arg(root.symbol) : !!savedAddressName ?
                            qsTr("Send %1 to %2").arg(root.symbol).arg(savedAddressName) :
                            qsTr("Send %1 to %2").arg(root.symbol).arg(Utils.compactAddress(modelData.to, 4)): ""
    subTitle: shortTimeStamp
    inlineTagModel: 1
    inlineTagDelegate: InformationTag {
        tagPrimaryLabel.text: networkName
        tagPrimaryLabel.color: networkColor
        image.source: !!networkIcon ? Style.svg("tiny/%1".arg(networkIcon)) : ""
        customBackground: Component {
            Rectangle {
                color: "transparent"
                border.width: 1
                border.color: Theme.palette.baseColor2
                radius: 36
            }
        }
        width: 51
        height: root.loading ? textMetrics.tightBoundingRect.height : 24
        rightComponent: transferStatus === Constants.TransactionStatus.Success ? completedIcon : loadingIndicator
        loading: root.loading
    }
    TextMetrics {
        id: textMetrics
        font: statusListItemSubTitle.font
        text: statusListItemSubTitle.text
    }
    components: [
        ColumnLayout {
            Row {
                Layout.alignment: Qt.AlignRight
                spacing: 4
                StatusIcon {
                    color: isIncoming ? Theme.palette.successColor1 : Theme.palette.dangerColor1
                    icon: "arrow-up"
                    rotation: isIncoming ? 135 : 45
                    height: 18
                    visible: !root.loading
                }
                StatusTextWithLoadingState {
                    id: cryptoValueText
                    text: LocaleUtils.currencyAmountToLocaleString(cryptoValue)
                    customColor: Theme.palette.directColor1
                    loading: root.loading
                }

            }
            StatusTextWithLoadingState {
                id: fiatValueText
                Layout.alignment: Qt.AlignRight
                text: LocaleUtils.currencyAmountToLocaleString(fiatValue)
                font.pixelSize: 15
                customColor: Theme.palette.baseColor1
                loading: root.loading
            }
        }
    ]

    Component {
        id: loadingIndicator
        StatusLoadingIndicator {
            height: 10
            width: 10
        }
    }

    Component {
        id: completedIcon
        StatusIcon {
            visible: icon !== ""
            icon: "checkmark"
            color: Theme.palette.baseColor1
            width: 10
            height: 10
        }
    }

    states: [
        State {
            name: "normal"
            PropertyChanges {
                target: asset
                width: 40
                height: 40
            }
            PropertyChanges {
                target: statusListItemTitle
                font.weight: Font.Medium
                font.pixelSize: 15
            }
            PropertyChanges {
                target: cryptoValueText
                font.pixelSize: 15
            }
        },
        State {
            name: "big"
            PropertyChanges {
                target: asset
                width: 50
                height: 50
            }
            PropertyChanges {
                target: statusListItemTitle
                font.weight: Font.Bold
                font.pixelSize: 17
            }
            PropertyChanges {
                target: cryptoValueText
                font.pixelSize: 17
            }
        }
    ]
}
