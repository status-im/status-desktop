import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

Item {
  property string errorMessage: ""
  property string defaultCurrency: "USD"
  property string fiatBalance: "0.00"
  property alias text: inputAmount.text
  property var selectedAccount
  property var getFiatValue: function () {}
  property var getCryptoValue: function () {}

  id: root

  height: inputAmount.height + txtFiatBalance.height + txtFiatBalance.anchors.topMargin
  anchors.right: parent.right
  anchors.left: parent.left

  onSelectedAccountChanged: {
    txtBalance.text = selectAsset.selectedAsset.value
  }

  Item {
      anchors.right: parent.right
      anchors.left: parent.left
      anchors.top: parent.top
      height: txtBalanceDesc.height

      StyledText {
          id: txtBalanceDesc
          text: qsTr("Balance: ")
          anchors.right: txtBalance.left
          font.weight: Font.Medium
          font.pixelSize: 13
          color: parseFloat(inputAmount.text) > parseFloat(txtBalance.text) ? Style.current.red : Style.current.secondaryText
      }

      StyledText {
          id: txtBalance
          property bool hovered: false
          text: selectAsset.selectedAsset.value
          anchors.right: parent.right
          font.weight: Font.Medium
          font.pixelSize: 13
          color: {
            if (txtBalance.hovered) {
              return Style.current.textColor
            }
            return parseFloat(inputAmount.text) > parseFloat(txtBalance.text) ? Style.current.red : Style.current.secondaryText
          }

          MouseArea {
              cursorShape: Qt.PointingHandCursor
              anchors.fill: parent
              hoverEnabled: true
              onExited: {
                  txtBalance.hovered = false
              }
              onEntered: {
                  txtBalance.hovered = true
              }
              onClicked: {
                  inputAmount.text = selectAsset.selectedAsset.value
                  txtFiatBalance.text = root.getFiatValue(inputAmount.text, selectAsset.selectedAsset.symbol, root.defaultCurrency)
              }
          }
      }
  }

  Input {
      id: inputAmount
      label: qsTr("Asset & Amount")
      placeholderText: "0.00"
      validationError: root.errorMessage
      anchors.top: parent.top
      customHeight: 56
      Keys.onReleased: {
        let amount = inputAmount.text.trim()

        if (isNaN(amount)) {
          return
        }
        if (amount === "") {
          txtFiatBalance.text = "0.00"
        } else {
          txtFiatBalance.text = root.getFiatValue(amount, selectAsset.selectedAsset.symbol, root.defaultCurrency)
        }
      }
  }

  AssetSelector {
      id: selectAsset
      assets: root.selectedAccount.assets
      width: 86
      height: 28
      anchors.top: inputAmount.top
      anchors.topMargin: Style.current.bigPadding + 14
      anchors.right: parent.right
      anchors.rightMargin: Style.current.smallPadding
      onSelectedAssetChanged: {
          inputAmount.text = selectAsset.selectedAsset.value
          txtBalance.text = selectAsset.selectedAsset.value
          txtFiatBalance.text = root.getFiatValue(inputAmount.text, selectAsset.selectedAsset.symbol, root.defaultCurrency)
      }
  }

  Item {
      height: txtFiatBalance.height
      anchors.left: parent.left
      anchors.top: inputAmount.bottom
      anchors.topMargin: inputAmount.labelMargin

      StyledTextField {
          id: txtFiatBalance
          anchors.left: parent.left
          anchors.top: parent.top
          color: txtFiatBalance.activeFocus ? Style.current.textColor : Style.current.secondaryText
          font.weight: Font.Medium
          font.pixelSize: 12
          inputMethodHints: Qt.ImhFormattedNumbersOnly
          text: root.fiatBalance
          selectByMouse: true
          background: Rectangle {
              color: Style.current.transparent
          }
          padding: 0
          Keys.onReleased: {
              let balance = txtFiatBalance.text.trim()
              if (balance === "" || isNaN(balance)) {
                  return
              }
              inputAmount.text = root.getCryptoValue(balance, root.defaultCurrency, selectAsset.selectedAsset.symbol)
          }
      }

      StyledText {
          id: txtFiatSymbol
          text: root.defaultCurrency.toUpperCase()
          font.weight: Font.Medium
          font.pixelSize: 12
          color: Style.current.secondaryText
          anchors.top: parent.top
          anchors.left: txtFiatBalance.right
          anchors.leftMargin: 2
      }
  }

  StyledText {
      text: root.errorMessage != "" ? root.errorMessage : qsTr("Insufficient balance")
      anchors.right: parent.right
      anchors.top: inputAmount.bottom
      anchors.topMargin: inputAmount.labelMargin
      font.weight: Font.Medium
      font.pixelSize: 12
      color: Style.current.red
      visible: parseFloat(inputAmount.text) > parseFloat(txtBalance.text) || root.errorMessage != ""
  }
}
