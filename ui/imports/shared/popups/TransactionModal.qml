import QtQuick 2.13

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import "../stores"

// TODO: replace with StatusModal
ModalPopup {
  id: popup

  property var transaction
  //% "Transaction Details"
  title: qsTrId("transaction-details")

  Item {
    id: confirmations
    anchors.left: parent.left
    anchors.leftMargin: Style.current.smallPadding
    anchors.top: parent.top
    anchors.topMargin: Style.current.smallPadding
    anchors.right: parent.right
    anchors.rightMargin: Style.current.smallPadding
    height: children[0].height + children[1].height + Style.current.smallPadding

    StyledText {
      id: confirmationsCount
      text: {
          if(transaction !== undefined)
              return RootStore.getLatestBlockNumber() - RootStore.hex2Dec(transaction.blockNumber) + qsTr(" confirmation(s)")
          else
              return ""
      }
      font.pixelSize: Style.current.secondaryTextFontSize
    }

    StyledText {
      id: confirmationsInfo
      //% "When the transaction has 12 confirmations you can consider it settled."
      text: qsTrId("confirmations-helper-text")
      wrapMode: Text.WordWrap
      font.pixelSize: Style.current.secondaryTextFontSize
      font.weight: Font.Medium
      color: Style.current.secondaryText
      anchors.top: confirmationsCount.bottom
      anchors.topMargin: Style.current.smallPadding
      width: parent.width
    }
  }

  Separator {
    id: separator
    anchors.top: confirmations.bottom
    anchors.topMargin: Style.current.padding
    anchors.left: parent.left
    anchors.leftMargin: -Style.current.padding
    anchors.right: parent.right
    anchors.rightMargin: -Style.current.padding
  }

  Item {
    id: block
    anchors.top: separator.bottom
    anchors.topMargin: Style.current.padding
    anchors.left: parent.left
    anchors.leftMargin: Style.current.smallPadding
    height: children[0].height

    StyledText {
      id: labelBlock
      //% "Block"
      text: qsTrId("block")
      font.pixelSize: 14
      font.weight: Font.Medium
      color: Style.current.secondaryText
    }

    StyledText {
      id: valueBlock
      text: transaction !== undefined ? RootStore.hex2Dec(transaction.blockNumber) : ""
      font.pixelSize: Style.current.secondaryTextFontSize
      anchors.left: labelBlock.right
      anchors.leftMargin: Style.current.padding
    }
  }

  Item {
    id: hash
    anchors.top: block.bottom
    anchors.topMargin: Style.current.padding
    anchors.left: parent.left
    anchors.leftMargin: Style.current.smallPadding
    anchors.right: parent.right
    anchors.rightMargin: Style.current.smallPadding
    height: children[0].height

    StyledText {
      id: labelHash
      //% "Hash"
      text: qsTrId("hash")
      font.pixelSize: Style.current.secondaryTextFontSize
      font.weight: Font.Medium
      color: Style.current.secondaryText
    }

    Address {
      id: valueHash
      text: transaction !== undefined ? transaction.id : ""
      width: Style.dp(160)
      maxWidth: parent.width - labelHash.width - Style.current.padding
      color: Style.current.textColor
      font.pixelSize: Style.current.secondaryTextFontSize
      anchors.left: labelHash.right
      anchors.leftMargin: Style.current.padding
    }
  }

  Item {
    id: from
    anchors.top: hash.bottom
    anchors.topMargin: Style.current.padding
    anchors.left: parent.left
    anchors.leftMargin: Style.current.smallPadding
    height: children[0].height

    StyledText {
      id: labelFrom
      //% "From"
      text: qsTrId("from")
      font.pixelSize: Style.current.secondaryTextFontSize
      font.weight: Font.Medium
      color: Style.current.secondaryText
    }

    Address {
      id: valueFrom
      text: transaction !== undefined ? transaction.from: ""
      color: Style.current.textColor
      width: Style.dp(160)
      font.pixelSize: Style.current.secondaryTextFontSize
      anchors.left: labelFrom.right
      anchors.leftMargin: Style.current.padding
    }
  }

  Item {
    id: toItem
    anchors.top: from.bottom
    anchors.topMargin: Style.current.padding
    anchors.left: parent.left
    anchors.leftMargin: Style.current.smallPadding
    height: children[0].height

    StyledText {
      id: labelTo
      //% "To"
      text: qsTrId("to")
      font.pixelSize: Style.current.secondaryTextFontSize
      font.weight: Font.Medium
      color: Style.current.secondaryText
    }

    Address {
      id: valueTo
      text: transaction !== undefined ? transaction.to: ""
      color: Style.current.textColor
      width: Style.dp(160)
      font.pixelSize: Style.current.secondaryTextFontSize
      anchors.left: labelTo.right
      anchors.leftMargin: Style.current.padding
    }
  }

  Item {
    id: gasLimitItem
    anchors.top: toItem.bottom
    anchors.topMargin: Style.current.padding
    anchors.left: parent.left
    anchors.leftMargin: Style.current.smallPadding
    height: children[0].height

    StyledText {
      id: labelGasLimit
      //% "Gas limit"
      text: qsTrId("gas-limit")
      font.pixelSize: Style.current.secondaryTextFontSize
      font.weight: Font.Medium
      color: Style.current.secondaryText
    }

    StyledText {
      id: valueGasLimit
      text: transaction !== undefined ? RootStore.hex2Dec(transaction.gasLimit): ""
      font.pixelSize: Style.current.secondaryTextFontSize
      anchors.left: labelGasLimit.right
      anchors.leftMargin: Style.current.padding
    }
  }

  Item {
    id: gasPriceItem
    anchors.top: gasLimitItem.bottom
    anchors.topMargin: Style.current.padding
    anchors.left: parent.left
    anchors.leftMargin: Style.current.smallPadding
    height: children[0].height

    StyledText {
      id: labelGasPrice
      //% "Gas price"
      text: qsTrId("gas-price")
      font.pixelSize: Style.current.secondaryTextFontSize
      font.weight: Font.Medium
      color: Style.current.secondaryText
    }

    StyledText {
      id: valueGasPrice
      text: transaction !== undefined ? RootStore.hex2Eth(transaction.gasPrice): ""
      font.pixelSize: Style.current.secondaryTextFontSize
      anchors.left: labelGasPrice.right
      anchors.leftMargin: Style.current.padding
    }
  }

  Item {
    id: gasUsedItem
    anchors.top: gasPriceItem.bottom
    anchors.topMargin: Style.current.padding
    anchors.left: parent.left
    anchors.leftMargin: Style.current.smallPadding
    height: children[0].height

    StyledText {
      id: labelGasUsed
      //% "Gas used"
      text: qsTrId("gas-used")
      font.pixelSize: Style.current.secondaryTextFontSize
      font.weight: Font.Medium
      color: Style.current.secondaryText
    }

    StyledText {
      id: valueGasUsed
      text: transaction !== undefined ? RootStore.hex2Dec(transaction.gasUsed): ""
      font.pixelSize: Style.current.secondaryTextFontSize
      anchors.left: labelGasUsed.right
      anchors.leftMargin: Style.current.padding
    }
  }

  Item {
    id: nonceItem
    anchors.top: gasUsedItem.bottom
    anchors.topMargin: Style.current.padding
    anchors.left: parent.left
    anchors.leftMargin: Style.current.smallPadding
    height: children[0].height

    StyledText {
      id: labelNonce
      //% "Nonce"
      text: qsTrId("nonce")
      font.pixelSize: Style.current.secondaryTextFontSize
      font.weight: Font.Medium
      color: Style.current.secondaryText
    }

    StyledText {
      id: valueNonce
      text: transaction !== undefined ? RootStore.hex2Dec(transaction.nonce) : ""
      font.pixelSize: Style.current.secondaryTextFontSize
      anchors.left: labelNonce.right
      anchors.leftMargin: Style.current.padding
    }
  }
}
