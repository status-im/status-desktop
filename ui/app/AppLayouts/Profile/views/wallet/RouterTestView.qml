import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Core.Theme 0.1

import shared.panels 1.0

ColumnLayout {
    id: root

    QtObject {
        id: d

        readonly property int ethMultiplier: 18
        readonly property int precision: 15

        property bool dataFetched: false

        readonly property int mainnetChainID: 1
        readonly property int optimismChainID: 10
        readonly property int arbitrumChainID: 42161

        readonly property int sepoliaChainID: 11155111
        readonly property int optimismSepoliaChainID: 11155420
        readonly property int arbitrumSepoliaChainID: 421614

        readonly property var sendTypes: [
            "Transfer",
            "ENSRegister",
            "ENSRelease",
            "ENSSetPubKey",
            "StickersBuy",
            "Bridge",
            "ERC721Transfer",
            "ERC1155Transfer",
            "Swap"
        ]

        property int selectedType: 1
        readonly property int multiplierValue: parseInt(multiplier.text.trim())

        property var routerResultJson: ({})

        onRouterResultJsonChanged: {
            candidatesModel.clear()
            bestRouteModel.clear()

            for (var i = 0; i < d.routerResultJson.Candidates.length; i++) {
                for (let key in d.routerResultJson.Candidates[i]) {
                    if (d.routerResultJson.Candidates[i][key] === null) {
                        d.routerResultJson.Candidates[i][key] = ""
                    }
                }
                candidatesModel.append(d.routerResultJson.Candidates[i])
            }

            for (var i = 0; i < d.routerResultJson.Best.length; i++) {
                for (let key in d.routerResultJson.Best[i]) {
                    if (d.routerResultJson.Best[i][key] === null) {
                        d.routerResultJson.Best[i][key] = ""
                    }
                }
                bestRouteModel.append(d.routerResultJson.Best[i])
            }
        }

        function fromChainIdToName(id) {
            switch (id) {
            case d.mainnetChainID:
                return qsTr("Mainnet")
            case d.optimismChainID:
                return qsTr("MainnetOptimism")
            case d.arbitrumChainID:
                return qsTr("MainnetArbitrum")
            case d.sepoliaChainID:
                return qsTr("Sepolia")
            case d.optimismSepoliaChainID:
                return qsTr("SepoliaOptimism")
            case d.arbitrumSepoliaChainID:
                return qsTr("SepoliaArbitrum")
            default:
                return qsTr("Unknown")
            }
        }

        function getFiatValue(cryptoAmount, cryptoSymbol) {
            var amount = profileSectionModule.ensUsernamesModule.getFiatValue(cryptoAmount, cryptoSymbol)
            return parseFloat(amount)
        }

        function getWei2Eth(wei,decimals) {
            return globalUtils.wei2Eth(wei,decimals)
        }
    }

    ListModel {
        id: candidatesModel
    }

    ListModel {
        id: bestRouteModel
    }

    ColumnLayout {
        Layout.fillHeight: true
        Layout.fillWidth: true
        spacing: 20

        GridLayout {
            columns: 2
            columnSpacing: 20
            rowSpacing: 20
            Layout.fillWidth: true

            RowLayout {
                Layout.columnSpan: 2
                Layout.fillWidth: true

                StatusBaseText {
                    Layout.alignment: Qt.AlignVCenter
                    text: qsTr("Send type")
                }

                StatusButton {
                    id: button
                    text: d.sendTypes[d.selectedType]
                    icon.name: "chevron-down"

                    onClicked: {
                        if (selectMenu.opened) {
                            selectMenu.close()
                        } else {
                            selectMenu.popup(button.x, button.y + button.height + 8)
                        }
                    }
                }


                StatusMenu {
                    id: selectMenu
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                    width: parent.width
                    clip: true

                    Repeater {
                        model: d.sendTypes.length

                        MenuItem {
                            text: d.sendTypes[index]
                            onTriggered: {
                                d.selectedType = index
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.columnSpan: 2
                Layout.fillWidth: true

                StatusBaseText {
                    Layout.alignment: Qt.AlignVCenter
                    text: qsTr("Amount To Send")
                }

                StatusInput {
                    id: amount
                    Layout.preferredWidth: 200
                    placeholderText: qsTr("1.2")
                }

                StatusBaseText {
                    Layout.alignment: Qt.AlignVCenter
                    text: qsTr("Multiplier")
                }

                StatusInput {
                    id: multiplier
                    Layout.preferredWidth: 200
                    placeholderText: qsTr("eg. 18 for ETH, 0 for collectibles")
                }
            }

            RowLayout {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                visible: d.selectedType === 1 ||
                         d.selectedType === 2 ||
                         d.selectedType === 3
                spacing: 10

                StatusInput {
                    id: username
                    label: qsTr("Username")
                    placeholderText: qsTr("myensname")
                }

                StatusInput {
                    id: publicKey
                    enabled: false
                    label: qsTr("Public key")
                    text: userProfile.pubKey
                }
            }

            RowLayout {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                visible: d.selectedType === 4
                spacing: 10

                StatusInput {
                    id: packId
                    label: qsTr("PackId")
                    placeholderText: qsTr("11")
                }
            }

            ColumnLayout {
                spacing: 10
                StatusInput {
                    id: addrFrom
                    label: qsTr("Address From")
                    placeholderText: qsTr("0x123...")
                }

                StatusInput {
                    id: tokenFrom
                    label: qsTr("Token From")
                    placeholderText: qsTr("ETH or SNT or DAI...")
                }

                ColumnLayout {
                    StatusBaseText {
                        text: qsTr("Disabled From Chains")
                    }

                    Row {
                        StatusCheckBox {
                            id: fromDisabledMainnet
                            text: qsTr("Mainnet")
                        }
                        StatusCheckBox {
                            id: fromDisabledOptimism
                            text: qsTr("Optimism")
                        }
                        StatusCheckBox {
                            id: fromDisabledArbitrum
                            text: qsTr("Arbitrum")
                        }
                    }
                }

                ColumnLayout {
                    StatusInput {
                        id: fromLockedMainnet
                        label: qsTr("Amount Locked On Mainnet")
                        placeholderText: qsTr("0.1232")
                    }

                    StatusInput {
                        id: fromLockedOptimism
                        label: qsTr("Amount Locked On Optimism")
                        placeholderText: qsTr("0.1232")
                    }

                    StatusInput {
                        id: fromLockedArbitrum
                        label: qsTr("Amount Locked On Arbitrums")
                        placeholderText: qsTr("0.1232")
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }

            ColumnLayout {
                spacing: 10
                StatusInput {
                    id: addrTo
                    label: qsTr("Address To")
                    placeholderText: qsTr("0x123...")
                }

                StatusInput {
                    id: tokenTo
                    label: qsTr("Token To")
                    placeholderText: qsTr("ETH or SNT or DAI...")
                    enabled: d.selectedType === 8
                    onEnabledChanged: tokenTo.text = ""
                }

                ColumnLayout {
                    StatusBaseText {
                        text: qsTr("Preferred To Chains")
                    }

                    Row {
                        StatusCheckBox {
                            id: prefferedMainnet
                            text: qsTr("Mainnet")
                        }
                        StatusCheckBox {
                            id: prefferedOptimism
                            text: qsTr("Optimism")
                        }
                        StatusCheckBox {
                            id: prefferedArbitrum
                            text: qsTr("Arbitrum")
                        }
                    }
                }

                ColumnLayout {
                    StatusBaseText {
                        text: qsTr("Disabled To Chains")
                    }

                    Row {
                        StatusCheckBox {
                            id: toDisabledMainnet
                            text: qsTr("Mainnet")
                        }
                        StatusCheckBox {
                            id: toDisabledOptimism
                            text: qsTr("Optimism")
                        }
                        StatusCheckBox {
                            id: toDisabledArbitrum
                            text: qsTr("Arbitrum")
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }

            Flow {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                spacing: 10

                StatusButton {
                    text: qsTr("Set Tx")
                    onClicked: {
                        d.selectedType = 0
                        amount.text = "2"
                        multiplier.text = "6"
                        addrFrom.text = "0x76C58e84320E633f3421A2F816fE086A13E353Da"
                        addrTo.text = "0xC63813Cf6f1173350A6350745bfd7b2bD4Ee8a79"
                        tokenFrom.text = "USDC"
//                        fromDisabledMainnet.checked = true
                        fromDisabledOptimism.checked = true
                        fromDisabledArbitrum.checked = true
//                        toDisabledMainnet.checked = true
                        toDisabledOptimism.checked = true
                        toDisabledArbitrum.checked = true
                    }
                }

                StatusButton {
                    text: qsTr("Set Bridge")
                    onClicked: {
                        d.selectedType = 5
                        amount.text = "15"
                        multiplier.text = "6"
                        addrFrom.text = "0x946a89180365d054677d10b1a73235c0bee6734f"
                        addrTo.text = "0x946a89180365d054677d10b1a73235c0bee6734f"
                        tokenFrom.text = "USDC"
                        fromDisabledMainnet.checked = true
//                        fromDisabledOptimism.checked = true
                        fromDisabledArbitrum.checked = true
                        toDisabledMainnet.checked = true
                        toDisabledOptimism.checked = true
//                        toDisabledArbitrum.checked = true
                    }
                }

                StatusButton {
                    text: qsTr("Set Erc721")
                    onClicked: {
                        d.selectedType = 6
                        amount.text = "1"
                        multiplier.text = "0"
                        addrFrom.text = "0x76C58e84320E633f3421A2F816fE086A13E353Da"
                        addrTo.text = "0xC63813Cf6f1173350A6350745bfd7b2bD4Ee8a79"
                        tokenFrom.text = "0x1fbaab49e7e3228b1f265ce894c5537434e7468b:2"
                        fromDisabledMainnet.checked = true
                        fromDisabledOptimism.checked = true
//                        fromDisabledArbitrum.checked = true
                        toDisabledMainnet.checked = true
                        toDisabledOptimism.checked = true
//                        toDisabledArbitrum.checked = true
                    }
                }

                StatusButton {
                    text: qsTr("Register ENS")
                    onClicked: {
                        d.selectedType = 1
                        username.text = "myens"
                        amount.text = "0"
                        multiplier.text = "0"
                        addrFrom.text = "0x76C58e84320E633f3421A2F816fE086A13E353Da"
                        addrTo.text = "0x76C58e84320E633f3421A2F816fE086A13E353Da"
                        tokenFrom.text = "ETH"
//                        fromDisabledMainnet.checked = true
                        fromDisabledOptimism.checked = true
                        fromDisabledArbitrum.checked = true
//                        toDisabledMainnet.checked = true
                        toDisabledOptimism.checked = true
                        toDisabledArbitrum.checked = true
                    }
                }

                StatusButton {
                    text: qsTr("Buy Stickers")
                    onClicked: {
                        d.selectedType = 4
                        packId.text = "11"
                        amount.text = "350"
                        multiplier.text = "18"
                        addrFrom.text = "0x76C58e84320E633f3421A2F816fE086A13E353Da"
                        addrTo.text = "0x76C58e84320E633f3421A2F816fE086A13E353Da"
                        tokenFrom.text = "STT"
//                        fromDisabledMainnet.checked = true
                        fromDisabledOptimism.checked = true
                        fromDisabledArbitrum.checked = true
//                        toDisabledMainnet.checked = true
                        toDisabledOptimism.checked = true
                        toDisabledArbitrum.checked = true
                    }
                }

                StatusButton {
                    Layout.preferredWidth: 300
                    text: qsTr("Calculate Route")
                    enabled: amount.text.trim() !== "" &&
                             multiplier.text.trim() !== "" &&
                             addrFrom.text.trim() !== "" &&
                             addrTo.text.trim() !== "" &&
                             tokenFrom.text.trim() !== "" &&
                             (!tokenTo.enabled || tokenTo.text.trim() !== "")

                    onClicked: {
                        d.dataFetched = false
                        d.routerResultJson = {}

                        const disabledFromChains = []
                        const lockedInAmounts = ({})
                        if (networksModule.areTestNetworksEnabled) {
                            if (fromDisabledMainnet.checked) disabledFromChains.push(d.sepoliaChainID)
                            if (fromDisabledOptimism.checked) disabledFromChains.push(d.optimismSepoliaChainID)
                            if (fromDisabledArbitrum.checked) disabledFromChains.push(d.arbitrumSepoliaChainID)

                            if (fromLockedMainnet.text.trim() !== "") {
                                const amountFinal = AmountsArithmetic.fromNumber(fromLockedMainnet.text.trim(), d.multiplierValue)
                                lockedInAmounts[d.sepoliaChainID.toString()] = amountFinal.toFixed()
                            }
                            if (fromLockedOptimism.text.trim() !== "") {
                                const amountFinal = AmountsArithmetic.fromNumber(fromLockedOptimism.text.trim(), d.multiplierValue)
                                lockedInAmounts[d.optimismSepoliaChainID.toString()] = amountFinal.toFixed()
                            }
                            if (fromLockedArbitrum.text.trim() !== "") {
                                const amountFinal = AmountsArithmetic.fromNumber(fromLockedArbitrum.text.trim(), d.multiplierValue)
                                lockedInAmounts[d.arbitrumSepoliaChainID.toString()] = amountFinal.toFixed()
                            }
                        } else {
                            if (fromDisabledMainnet.checked) disabledFromChains.push(d.mainnetChainID)
                            if (fromDisabledOptimism.checked) disabledFromChains.push(d.optimismChainID)
                            if (fromDisabledArbitrum.checked) disabledFromChains.push(d.arbitrumChainID)

                            if (fromLockedMainnet.text.trim() !== "") {
                                const amountFinal = AmountsArithmetic.fromNumber(fromLockedMainnet.text.trim(), d.multiplierValue)
                                lockedInAmounts[d.mainnetChainID.toString()] = amountFinal.toFixed()
                            }
                            if (fromLockedOptimism.text.trim() !== "") {
                                const amountFinal = AmountsArithmetic.fromNumber(fromLockedOptimism.text.trim(), d.multiplierValue)
                                lockedInAmounts[d.optimismChainID.toString()] = amountFinal.toFixed()
                            }
                            if (fromLockedArbitrum.text.trim() !== "") {
                                const amountFinal = AmountsArithmetic.fromNumber(fromLockedArbitrum.text.trim(), d.multiplierValue)
                                lockedInAmounts[d.arbitrumChainID.toString()] = amountFinal.toFixed()
                            }
                        }

                        const disabledToChains = []
                        if (networksModule.areTestNetworksEnabled) {
                            if (toDisabledMainnet.checked) disabledToChains.push(d.sepoliaChainID)
                            if (toDisabledOptimism.checked) disabledToChains.push(d.optimismSepoliaChainID)
                            if (toDisabledArbitrum.checked) disabledToChains.push(d.arbitrumSepoliaChainID)
                        } else {
                            if (toDisabledMainnet.checked) disabledToChains.push(d.mainnetChainID)
                            if (toDisabledOptimism.checked) disabledToChains.push(d.optimismChainID)
                            if (toDisabledArbitrum.checked) disabledToChains.push(d.arbitrumChainID)
                        }

                        const prefChains = []
                        if (networksModule.areTestNetworksEnabled) {
                            if (prefferedMainnet.checked) prefChains.push(d.sepoliaChainID)
                            if (prefferedOptimism.checked) prefChains.push(d.optimismSepoliaChainID)
                            if (prefferedArbitrum.checked) prefChains.push(d.arbitrumSepoliaChainID)
                        } else {
                            if (prefferedMainnet.checked) prefChains.push(d.mainnetChainID)
                            if (prefferedOptimism.checked) prefChains.push(d.optimismChainID)
                            if (prefferedArbitrum.checked) prefChains.push(d.arbitrumChainID)
                        }

                        const disabledFromChainsJson = JSON.stringify(disabledFromChains)
                        const disabledToChainsJson = JSON.stringify(disabledToChains)
                        const prefChainsJson = JSON.stringify(prefChains)
                        const lockedInAmountsJson = JSON.stringify(lockedInAmounts)

                        const amountFinal = AmountsArithmetic.fromNumber(amount.text.trim(), d.multiplierValue)

                        const extraParams = ({})
                        if (d.selectedType == 1 || d.selectedType === 3) {
                            extraParams["username"] = username.text
                            extraParams["publicKey"] = publicKey.text
                        } else if (d.selectedType == 2) {
                            extraParams["username"] = username.text
                        } else if (d.selectedType == 4) {
                            extraParams["packID"] = packId.text
                        }

                        const extraParamsJson = JSON.stringify(extraParams)

                        console.warn("Data For Backend: ",
                                     "\n sendType: ", d.selectedType,
                                     "\n addressFrom: ", addrFrom.text,
                                     "\n addressTo: ", addrTo.text,
                                     "\n tokenFrom: ", tokenFrom.text,
                                     "\n tokenTo: ", tokenTo.text,
                                     "\n amount: ", amountFinal.toFixed(),
                                     "\n disabledFromChains: ", disabledFromChainsJson,
                                     "\n disabledToChains: ", disabledToChainsJson,
                                     "\n prefferedChains: ", prefChainsJson,
                                     "\n lockedInAmounts: ", lockedInAmountsJson,
                                     "\n extraParamsJson: ", extraParamsJson
                                     )

                        let result = walletSectionSend.suggestedRoutesV2(addrFrom.text.trim(),
                                                                         addrTo.text.trim(),
                                                                         amountFinal.toFixed(),
                                                                         tokenFrom.text.trim(),
                                                                         tokenTo.text.trim(),
                                                                         disabledFromChainsJson,
                                                                         disabledToChainsJson,
                                                                         prefChainsJson,
                                                                         d.selectedType,
                                                                         lockedInAmountsJson,
                                                                         extraParamsJson
                                                                         )

                        try {
                            d.routerResultJson = JSON.parse(result)
                        }
                        catch (e) {
                            console.warn("error parsing router result: ", e.message)
                        }

                        d.dataFetched = true
                    }
                }
            }
        }

        Separator {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
        }

        ColumnLayout {

            StatusBaseText { text: "Received Token Price From Router: " + d.routerResultJson.TokenPrice }

            StatusBaseText { text: "Received Token Price In The App: " + d.getFiatValue(1, tokenFrom.text.trim()) }

            StatusBaseText { text: "Received Native Token Price From Router: " + d.routerResultJson.NativeChainTokenPrice }

            StatusBaseText { text: "Received Native Token Price In The App: " + d.getFiatValue(1, "ETH") }
        }

        Separator {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
        }

        StatusBaseText { text: "CANDIDATES     %1".arg(d.dataFetched && candidatesModel.count === 0? "NO ROUTES FOUND" : "") }

        Separator {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
        }

        StatusListView {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            spacing: 20
            model: candidatesModel

            delegate: Path {
                width: ListView.view.width
                modelData: model
            }
        }

        Separator {
            Layout.fillWidth: true
            color: "red"
            Layout.preferredHeight: 4
        }

        StatusBaseText { text: "BEST ROUTE" }

        Separator {
            Layout.fillWidth: true
            color: "red"
            Layout.preferredHeight: 4
        }

        StatusListView {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            spacing: 20
            model: bestRouteModel

            delegate: Path {
                width: ListView.view.width
                modelData: model
            }
        }

        Separator {
            Layout.fillWidth: true
            color: "red"
            Layout.preferredHeight: 4
        }
    }

    component Path: GridLayout {
        id: pathId

        columns: 4
        columnSpacing: 20

        property var modelData

        property var txBaseFeeEth: d.getWei2Eth(pathId.modelData.TxBaseFee, d.ethMultiplier)
        property var txBaseFeeFiat: d.getFiatValue(pathId.txBaseFeeEth, "ETH")

        property var txPriorityFeeEth: d.getWei2Eth(pathId.modelData.TxPriorityFee, d.ethMultiplier)
        property var txPriorityFeeFiat: d.getFiatValue(pathId.txPriorityFeeEth, "ETH")

        property real totalFeePerGasEth: parseFloat(pathId.txBaseFeeEth) + parseFloat(pathId.txPriorityFeeEth)
        property var totalFeePerGasFiat: d.getFiatValue(pathId.totalFeePerGasEth, "ETH")

        property real txFeeEth: pathId.totalFeePerGasEth * pathId.modelData.TxGasAmount
        property var txFeeFiat: d.getFiatValue(pathId.txFeeEth, "ETH")

        property var valueInInToken: d.getWei2Eth(pathId.modelData.AmountIn, d.multiplierValue)
        property var valueInInFiat: d.getFiatValue(pathId.valueInInToken, tokenFrom.text.trim())

        property var valueOutInToken: d.getWei2Eth(pathId.modelData.AmountOut, d.multiplierValue)
        property var valueOutInFiat: d.getFiatValue(pathId.valueOutInToken, tokenFrom.text.trim())

        property var txBonderFeesInToken: d.getWei2Eth(pathId.modelData.TxBonderFees, d.multiplierValue)
        property var txBonderFeesFiat: d.getFiatValue(pathId.txBonderFeesInToken, tokenFrom.text.trim())

        property var txTokenFeesInToken: d.getWei2Eth(pathId.modelData.TxTokenFees, d.multiplierValue)
        property var txTokenFeesFiat: d.getFiatValue(pathId.txTokenFeesInToken, tokenFrom.text.trim())

        property var txL1FeeEth: d.getWei2Eth(pathId.modelData.TxL1Fee, d.ethMultiplier)
        property var txL1FeeFiat: d.getFiatValue(pathId.txL1FeeEth, "ETH")

        property var approvalAmountRequiredInToken: d.getWei2Eth(pathId.modelData.ApprovalAmountRequired, d.multiplierValue)
        property var approvalAmountRequiredInFiat: d.getFiatValue(pathId.approvalAmountRequiredInToken, tokenFrom.text.trim())

        property var approvalBaseFeeEth: d.getWei2Eth(pathId.modelData.ApprovalBaseFee, d.ethMultiplier)
        property var approvalBaseFeeFiat: d.getFiatValue(pathId.approvalBaseFeeEth, "ETH")

        property var approvalPriorityFeeEth: d.getWei2Eth(pathId.modelData.ApprovalPriorityFee, d.ethMultiplier)
        property var approvalPriorityFeeFiat: d.getFiatValue(pathId.approvalPriorityFeeEth, "ETH")

        property real approvalFeePerGasEth: parseFloat(pathId.approvalBaseFeeEth) + parseFloat(pathId.approvalPriorityFeeEth)
        property var approvalFeePerGasFiat: d.getFiatValue(pathId.approvalFeePerGasEth, "ETH")

        property real approvalFeeEth: pathId.approvalFeePerGasEth * pathId.modelData.ApprovalGasAmount
        property var approvalFeeFiat: d.getFiatValue(pathId.approvalFeeEth, "ETH")

        property var approvalL1FeeEth: d.getWei2Eth(pathId.modelData.ApprovalL1Fee, d.ethMultiplier)
        property var approvalL1FeeFiat: d.getFiatValue(pathId.approvalL1FeeEth, "ETH")

        property real totalTxCost: parseFloat(pathId.txFeeFiat) +
                                   parseFloat(pathId.txBonderFeesFiat) +
                                   parseFloat(pathId.txTokenFeesFiat) +
                                   parseFloat(pathId.txL1FeeFiat)

        property string totalTxCostSplit: "txFee($): %1<br/>bonderFee($): %2<br/>tokenFees($): %3<br/>txL1Fee($): %4<br/>Total($): %5"
        .arg(pathId.txFeeFiat.toFixed(d.precision))
        .arg(pathId.txBonderFeesFiat.toFixed(d.precision))
        .arg(pathId.txTokenFeesFiat.toFixed(d.precision))
        .arg(pathId.txL1FeeFiat.toFixed(d.precision))
        .arg(pathId.totalTxCost)

        property real totalAppCost: parseFloat(pathId.approvalFeeFiat) +
                                    parseFloat(pathId.approvalL1FeeFiat)
        property string fianlAppCostSplit: "appFee($): %1<br/>appL1Fee($): %2<br/>Total($): %3"
        .arg(pathId.approvalFeeFiat.toFixed(d.precision))
        .arg(pathId.approvalL1FeeFiat.toFixed(d.precision))
        .arg(pathId.totalAppCost)

        property string fianlCost: "TX($): %1"
        .arg(pathId.totalTxCost + pathId.totalAppCost)

        StatusBaseText {
            text: "Bridge Name"
        }
        StatusBaseText {
            Layout.columnSpan: 3
            text: pathId.modelData.BridgeName
        }

        StatusBaseText {
            text: "From Chain"
        }
        StatusBaseText {
            text: "%1(%2)".arg(pathId.modelData.FromChain.chainId).arg(d.fromChainIdToName(pathId.modelData.FromChain.chainId))
        }
        StatusBaseText {
            text: "To Chain"
        }
        StatusBaseText {
            text: "%1(%2)".arg(pathId.modelData.ToChain.chainId).arg(d.fromChainIdToName(pathId.modelData.ToChain.chainId))
        }

        // amount in
        StatusBaseText {
            text: "Amount In"
        }
        StatusBaseText {
            text: "HEX: %1".arg(pathId.modelData.AmountIn)
        }
        StatusBaseText {
            text: "%1: %2".arg(tokenFrom.text.trim()).arg(pathId.valueInInToken)
        }
        StatusBaseText {
            text: "FIAT($): %1".arg(pathId.valueInInFiat.toFixed(d.precision))
        }

        // amount out
        StatusBaseText {
            text: "Amount Out"
        }
        StatusBaseText {
            text: "HEX: %1".arg(pathId.modelData.AmountOut)
        }
        StatusBaseText {
            text: "%1: %2".arg(tokenFrom.text.trim()).arg(pathId.valueOutInToken)
        }
        StatusBaseText {
            text: "FIAT($): %1".arg(pathId.valueOutInFiat.toFixed(d.precision))
        }

        StatusBaseText {
            text: "Estimated time"
        }

        StatusBaseText {
            Layout.columnSpan: 3
            text: {
                if (pathId.modelData.EstimatedTime === 1)
                    return "Less than 1 min"
                if (pathId.modelData.EstimatedTime === 2)
                    return "Less than 3 mins"
                if (pathId.modelData.EstimatedTime === 3)
                    return "Less than 5 mins"
                if (pathId.modelData.EstimatedTime === 4)
                    return "More than 5 mins"
                return "unknown"
            }
        }

        Item {
            Layout.columnSpan: 4
            Layout.preferredHeight: 20
        }

        StatusBaseText {
            Layout.columnSpan: 4
            text: "Tx fees"
        }

        // tx base fee
        StatusBaseText {
            text: "TxBaseFee"
        }
        StatusBaseText {
            text: "HEX: %1".arg(pathId.modelData.TxBaseFee)
        }
        StatusBaseText {
            text: "ETH: %1".arg(pathId.txBaseFeeEth)
        }
        StatusBaseText {
            text: "FIAT($): %1".arg(pathId.txBaseFeeFiat.toFixed(d.precision))
        }

        // tx priority fee
        StatusBaseText {
            text: "TxPriorityFee"
        }
        StatusBaseText {
            text: "HEX: %1".arg(pathId.modelData.TxPriorityFee)
        }
        StatusBaseText {
            text: "ETH: %1".arg(pathId.txPriorityFeeEth)
        }
        StatusBaseText {
            text: "FIAT($): %1".arg(pathId.txPriorityFeeFiat.toFixed(d.precision))
        }

        // tx base + priority fee
        StatusBaseText {
            text: "TxFeePerGas\n(base+priority)"
        }
        StatusBaseText {
            text: "HEX: %1".arg("")
        }
        StatusBaseText {
            text: "ETH: %1".arg(pathId.totalFeePerGasEth.toFixed(d.precision))
        }
        StatusBaseText {
            text: "FIAT($): %1".arg(pathId.totalFeePerGasFiat.toFixed(d.precision))
        }

        // tx gas amount
        StatusBaseText {
            text: "TxGasAmount"
        }
        StatusBaseText {
            Layout.columnSpan: 3
            text: pathId.modelData.TxGasAmount
        }

        // tx (base + priority fee) x gas amount
        StatusBaseText {
            text: "TxFee\n(GasAmountXFeePerGas)"
        }
        StatusBaseText {
            text: "HEX: %1".arg("")
        }
        StatusBaseText {
            text: "ETH: %1".arg(pathId.txFeeEth.toFixed(d.precision))
        }
        StatusBaseText {
            text: "FIAT($): %1".arg(pathId.txFeeFiat.toFixed(d.precision))
        }

        // tx bonder fee
        StatusBaseText {
            text: "TxBonderFees"
        }
        StatusBaseText {
            text: "HEX: %1".arg(pathId.modelData.TxBonderFees)
        }
        StatusBaseText {
            text: "%1: %2".arg(tokenFrom.text.trim()).arg(pathId.txBonderFeesInToken)
        }
        StatusBaseText {
            text: "FIAT($): %1".arg(pathId.txBonderFeesFiat.toFixed(d.precision))
        }

        // tx token fee
        StatusBaseText {
            text: "TxTokenFees"
        }
        StatusBaseText {
            text: "HEX: %1".arg(pathId.modelData.TxTokenFees)
        }
        StatusBaseText {
            text: "%1: %2".arg(tokenFrom.text.trim()).arg(pathId.txTokenFeesInToken)
        }
        StatusBaseText {
            text: "FIAT($): %1".arg(pathId.txTokenFeesFiat.toFixed(d.precision))
        }

        // tx L1 fee
        StatusBaseText {
            text: "TxL1Fee"
        }
        StatusBaseText {
            text: "HEX: %1".arg(pathId.modelData.TxL1Fee)
        }
        StatusBaseText {
            text: "ETH: %1".arg(pathId.txL1FeeEth)
        }
        StatusBaseText {
            text: "FIAT($): %1".arg(pathId.txL1FeeFiat.toFixed(d.precision))
        }

        Item {
            Layout.columnSpan: 4
            Layout.preferredHeight: 20
        }

        StatusBaseText {
            Layout.columnSpan: 4
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "Tx approval fees, %1".arg(pathId.modelData.ApprovalRequired? "--APPROVAL REQUIRED--" : "--NO APPROVAL--")
        }

        StatusBaseText {
            Layout.columnSpan: 4
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "Approval contract address: %1".arg(pathId.modelData.ApprovalContractAddress)
        }

        // approval amount
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "Approval Amount"
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "HEX: %1".arg(pathId.modelData.ApprovalAmountRequired)
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "%1: %2".arg(tokenFrom.text.trim()).arg(pathId.approvalAmountRequiredInToken)
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "FIAT($): %1".arg(pathId.approvalAmountRequiredInFiat.toFixed(d.precision))
        }

        // approval base fee
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "ApprovalBaseFee"
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "HEX: %1".arg(pathId.modelData.ApprovalBaseFee)
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "ETH: %1".arg(pathId.approvalBaseFeeEth)
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "FIAT($): %1".arg(pathId.approvalBaseFeeFiat.toFixed(d.precision))
        }

        // approval priority fee
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "ApprovalPriorityFee"
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "HEX: %1".arg(pathId.modelData.ApprovalPriorityFee)
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "ETH: %1".arg(pathId.approvalPriorityFeeEth)
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "FIAT($): %1".arg(pathId.approvalPriorityFeeFiat.toFixed(d.precision))
        }

        // approval base + priority fee
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "ApprovalFeePerGas\n(base+priority)"
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "HEX: %1".arg("")
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "ETH: %1".arg(pathId.approvalFeePerGasEth.toFixed(d.precision))
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "FIAT($): %1".arg(pathId.approvalFeePerGasFiat.toFixed(d.precision))
        }

        // approval gas amount
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "ApprovalGasAmount"
        }
        StatusBaseText {
            Layout.columnSpan: 3
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: pathId.modelData.ApprovalGasAmount
        }

        // approval (base + priority fee) x gas amount
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "ApprovalFee\n(GasAmountXFeePerGas)"
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "HEX: %1".arg("")
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "ETH: %1".arg(pathId.approvalFeeEth.toFixed(d.precision))
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "FIAT($): %1".arg(pathId.approvalFeeFiat.toFixed(d.precision))
        }

        // approval L1 fee
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "ApprovalL1Fee"
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "HEX: %1".arg(pathId.modelData.ApprovalL1Fee)
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "ETH: %1".arg(pathId.approvalL1FeeEth)
        }
        StatusBaseText {
            color: pathId.modelData.ApprovalRequired? Theme.palette.directColor1 : Theme.palette.baseColor1
            text: "FIAT($): %1".arg(pathId.approvalL1FeeFiat.toFixed(d.precision))
        }

        Item {
            Layout.columnSpan: 4
            Layout.preferredHeight: 20
        }

        // final cost
        StatusBaseText {
            text: "FinalCost"
        }
        StatusBaseText {
            Layout.columnSpan: 3
            textFormat: Text.RichText
            text: "%1<br/><br/>%2<br/><br/><b>%3</b>".arg(pathId.totalTxCostSplit).arg(pathId.fianlAppCostSplit).arg(pathId.fianlCost)
        }

        Separator {
            Layout.columnSpan: 4
        }
    }
}
