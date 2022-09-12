import QtQuick 2.13
import QtQuick.Layouts 1.3

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

import utils 1.0
import shared 1.0

StatusListItem {
    id: root

    property var modelData
    property string symbol
    property bool isIncoming
    property int transferStatus
    property string currentCurrency
    property string cryptoValue
    property string fiatValue
    property string networkIcon
    property string networkColor
    property string networkName
    property string shortTimeStamp
    property string resolvedSymbol: root.symbol != "" ? root.symbol : "ETH"
    property string savedAddressName

    asset.isImage: true
    asset.name: Style.png("tokens/%1".arg(resolvedSymbol))
    statusListItemTitle.font.weight: Font.Medium
    title: isIncoming ? qsTr("Receive %1").arg(resolvedSymbol) : !!savedAddressName ?
                            qsTr("Send %1 to %2").arg(resolvedSymbol).arg(savedAddressName) :
                            qsTr("Send %1 to %2").arg(resolvedSymbol).arg(Utils.compactAddress(modelData.to, 4))
    subTitle: shortTimeStamp
    inlineTagModel: 1
    inlineTagDelegate: InformationTag {
        tagPrimaryLabel.text: networkName
        tagPrimaryLabel.color: networkColor
        image.source: Style.svg("tiny/%1".arg(networkIcon))
        background: Rectangle {
            id: controlBackground
            implicitWidth: 51
            implicitHeight: 24
            color: "transparent"
            border.width: 1
            border.color: Theme.palette.baseColor2
            radius: 36
        }
        rightComponent: transferStatus === Constants.TransactionStatus.Success ? completedIcon : loadingIndicator
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
                }
                StatusBaseText {
                    text: LocaleUtils.formatCryptoCurrency(cryptoValue, resolvedSymbol) // FIXME i18n check precision
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                }
            }
            StatusBaseText {
                Layout.alignment: Qt.AlignRight
                text: LocaleUtils.formatCurrency(fiatValue, currentCurrency.toUpperCase())
                font.pixelSize: 15
                color: Theme.palette.baseColor1
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
}
