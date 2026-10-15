import QtQuick
import QtTest

import AppLayouts.Communities.popups

Item {
    id: root
    width: 800
    height: 800

    ListModel {
        id: feesModel
    }

    Component {
        id: componentUnderTest
        SignTransactionsPopup {
            model: feesModel
            accountName: "Status account"
            errorText: ""
            totalFeeText: ""
            requireFeeText: true
            destroyOnClose: false
            modal: false
        }
    }

    TestCase {
        name: "SignTransactionsPopup"
        when: windowShown

        function test_requireFeeText_gates_sign_button() {
            const popup = createTemporaryObject(componentUnderTest, root)
            verify(!!popup)
            popup.open()
            tryCompare(popup, "opened", true)

            const sign = findChild(popup, "signTransactionButton")
            verify(!!sign)
            compare(sign.enabled, false)

            popup.totalFeeText = "0.01 ETH"
            compare(sign.enabled, true)

            popup.totalFeeText = ""
            compare(sign.enabled, false)

            popup.close()
        }
    }
}
