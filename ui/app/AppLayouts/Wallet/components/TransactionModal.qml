import QtQuick 2.13
import "../../../../imports"
import "../../../../shared"
import "./"

ModalPopup {
  id: popup
  title: qsTr("Transaction Details")

  Item {
    id: confirmations
    anchors.left: parent.left
    anchors.leftMargin: Theme.smallPadding
    anchors.top: parent.top
    anchors.topMargin: Theme.smallPadding
    anchors.right: parent.right
    anchors.rightMargin: Theme.smallPadding
    height: children[0].height + children[1].height + Theme.smallPadding

    StyledText {
      id: confirmationsCount
      text: qsTr("9999 Confirmations")
      font.pixelSize: 14
    }

    StyledText {
      id: confirmationsInfo
      text: qsTr("When the transaction has 12 confirmations you can consider it settled.")
      font.pixelSize: 14
      font.weight: Font.Medium
      color: Theme.darkGrey
      anchors.top: confirmationsCount.bottom
      anchors.topMargin: Theme.smallPadding
    }
  }

  Separator {
    id: separator
    anchors.top: confirmations.bottom
    anchors.topMargin: Theme.padding
    anchors.left: parent.left
    anchors.leftMargin: -Theme.padding
    anchors.right: parent.right
    anchors.rightMargin: -Theme.padding
  }

  Item {
    id: block
    anchors.top: separator.bottom
    anchors.topMargin: Theme.padding
    anchors.left: parent.left
    anchors.leftMargin: Theme.smallPadding
    height: children[0].height

    StyledText {
      id: labelBlock
      text: qsTr("Block")
      font.pixelSize: 14
      font.weight: Font.Medium
      color: Theme.darkGrey
    }

    StyledText {
      id: valueBlock
      text: blockNumber
      font.pixelSize: 14
      anchors.left: labelBlock.right
      anchors.leftMargin: Theme.padding
    }
  }

  Item {
    id: hash
    anchors.top: block.bottom
    anchors.topMargin: Theme.padding
    anchors.left: parent.left
    anchors.leftMargin: Theme.smallPadding
    height: children[0].height

    StyledText {
      id: labelHash
      text: qsTr("Hash")
      font.pixelSize: 14
      font.weight: Font.Medium
      color: Theme.darkGrey
    }

    StyledText {
      id: valueHash
      text: blockHash
      font.family: Theme.fontHexRegular.name
      width: 160
      elide: Text.ElideMiddle
      font.pixelSize: 14
      anchors.left: labelHash.right
      anchors.leftMargin: Theme.padding
    }
  }

  Item {
    id: from
    anchors.top: hash.bottom
    anchors.topMargin: Theme.padding
    anchors.left: parent.left
    anchors.leftMargin: Theme.smallPadding
    height: children[0].height

    StyledText {
      id: labelFrom
      text: qsTr("From")
      font.pixelSize: 14
      font.weight: Font.Medium
      color: Theme.darkGrey
    }

    StyledText {
      id: valueFrom
      text: fromAddress
      font.family: Theme.fontHexRegular.name
      width: 160
      elide: Text.ElideMiddle
      font.pixelSize: 14
      anchors.left: labelFrom.right
      anchors.leftMargin: Theme.padding
    }
  }

  Item {
    id: toItem
    anchors.top: from.bottom
    anchors.topMargin: Theme.padding
    anchors.left: parent.left
    anchors.leftMargin: Theme.smallPadding
    height: children[0].height

    StyledText {
      id: labelTo
      text: qsTr("To")
      font.pixelSize: 14
      font.weight: Font.Medium
      color: Theme.darkGrey
    }

    StyledText {
      id: valueTo
      text: to
      width: 160
      elide: Text.ElideMiddle
      font.pixelSize: 14
      anchors.left: labelTo.right
      anchors.leftMargin: Theme.padding
    }
  }

  Item {
    id: gasLimitItem
    anchors.top: toItem.bottom
    anchors.topMargin: Theme.padding
    anchors.left: parent.left
    anchors.leftMargin: Theme.smallPadding
    height: children[0].height

    StyledText {
      id: labelGasLimit
      text: qsTr("Gas limit")
      font.pixelSize: 14
      font.weight: Font.Medium
      color: Theme.darkGrey
    }

    StyledText {
      id: valueGasLimit
      text: gasLimit
      font.pixelSize: 14
      anchors.left: labelGasLimit.right
      anchors.leftMargin: Theme.padding
    }
  }

  Item {
    id: gasPriceItem
    anchors.top: gasLimitItem.bottom
    anchors.topMargin: Theme.padding
    anchors.left: parent.left
    anchors.leftMargin: Theme.smallPadding
    height: children[0].height

    StyledText {
      id: labelGasPrice
      text: qsTr("Gas price")
      font.pixelSize: 14
      font.weight: Font.Medium
      color: Theme.darkGrey
    }

    StyledText {
      id: valueGasPrice
      text: gasPrice
      font.pixelSize: 14
      anchors.left: labelGasPrice.right
      anchors.leftMargin: Theme.padding
    }
  }

  Item {
    id: gasUsedItem
    anchors.top: gasPriceItem.bottom
    anchors.topMargin: Theme.padding
    anchors.left: parent.left
    anchors.leftMargin: Theme.smallPadding
    height: children[0].height

    StyledText {
      id: labelGasUsed
      text: qsTr("Gas used")
      font.pixelSize: 14
      font.weight: Font.Medium
      color: Theme.darkGrey
    }

    StyledText {
      id: valueGasUsed
      text: gasUsed
      font.pixelSize: 14
      anchors.left: labelGasUsed.right
      anchors.leftMargin: Theme.padding
    }
  }

  Item {
    id: nonceItem
    anchors.top: gasUsedItem.bottom
    anchors.topMargin: Theme.padding
    anchors.left: parent.left
    anchors.leftMargin: Theme.smallPadding
    height: children[0].height

    StyledText {
      id: labelNonce
      text: qsTr("Nonce")
      font.pixelSize: 14
      font.weight: Font.Medium
      color: Theme.darkGrey
    }

    StyledText {
      id: valueNonce
      text: nonce
      font.pixelSize: 14
      anchors.left: labelNonce.right
      anchors.leftMargin: Theme.padding
    }
  }
}
