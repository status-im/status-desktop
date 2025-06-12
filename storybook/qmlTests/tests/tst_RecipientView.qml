import QtQuick 2.15
import QtTest 1.15
import QtQml 2.15

import AppLayouts.Wallet.views 1.0

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

import QtModelsToolkit 1.0

Item {
    id: root

    Component {
        id: testComponent

        RecipientView {
            id: recipientView
            width: 500

            model: ListModel {
                readonly property var data: [
                    {
                        name: "helloworld",
                        emoji: "😋",
                        colorId: Constants.walletAccountColors.primary,
                        color: "#2A4AF5",
                        address: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240",
                    },
                    {
                        name: "Hot wallet (generated)",
                        emoji: "🚗",
                        colorId: Constants.walletAccountColors.army,
                        color: "#216266",
                        address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881",
                    },
                    {
                        name: "Family (seed)",
                        emoji: "🎨",
                        colorId: Constants.walletAccountColors.magenta,
                        color: "#EC266C",
                        address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8882",
                    },
                ]
                Component.onCompleted: append(data)
            }
        }
    }

    ListModel {
        id: emptyModel
    }

    TestCase {
        name: "RecipientView"

        SignalSpy {
            id: resolveEnsSignalSpy
            signalName: "resolveENS"
        }

        when: windowShown

        function test_empty() {
            const view = createTemporaryObject(testComponent, root, {model: emptyModel })
            verify(view)

            compare(view.model.ModelCount.count, 0)
            compare(view.searchPattern, "")
            compare(view.selectedRecipientAddress, "")
            verify(view.interactive)
            compare(view.item.objectName, "RecipientView_SendRecipientInput")
        }

        function test_search() {
            const view = createTemporaryObject(testComponent, root)
            verify(view)
            const privateObject = findChild(view, "RecipientView_private")
            verify(privateObject)
            verify(privateObject.validationTimer)
            privateObject.validationTimer.interval = 0 // For testing purposes skipping the validation delay

            compare(view.searchPattern, "")
            compare(view.selectedRecipientAddress, "")
            compare(view.item.objectName, "RecipientView_SendRecipientInput")

            view.item.text = "hello"
            wait(100)
            compare(view.searchPattern, "hello")
            compare(view.selectedRecipientAddress, "")
            compare(view.item.objectName, "RecipientView_SendRecipientInput")

            // Imitate filtering: no results found
            view.model = emptyModel
            view.item.text = "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0Fd864dd"
            wait(100)
            compare(view.searchPattern, "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0Fd864dd")
            compare(view.selectedRecipientAddress, "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0Fd864dd")
            compare(view.item.objectName, "RecipientView_RecipientViewDelegate", "Delegate is changed after selection is done")
        }

        function test_ens() {
            const view = createTemporaryObject(testComponent, root)
            verify(view)
            const privateObject = findChild(view, "RecipientView_private")
            verify(privateObject)
            privateObject.validationTimer.interval = 0 // For testing purposes skipping the validation delay

            compare(view.searchPattern, "")
            compare(view.selectedRecipientAddress, "")
            compare(view.item.objectName, "RecipientView_SendRecipientInput")

            resolveEnsSignalSpy.target = view

            view.item.text = "helloworld.eth"
            wait(100)
            compare(view.searchPattern, "", "Search pattern is not changed until ENS is resolved or error")
            compare(view.selectedRecipientAddress, "")
            compare(resolveEnsSignalSpy.count, 1)
            compare(resolveEnsSignalSpy.signalArguments[0][0], "helloworld.eth")

            const uuid = resolveEnsSignalSpy.signalArguments[0][1]
            verify(uuid !== "")

            view.ensNameResolved("", "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", uuid)
            compare(view.searchPattern, "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", "Resolved address is searched if model is not empty")
            compare(view.selectedRecipientAddress, "")

            view.ensNameResolved("", "", uuid)
            compare(view.searchPattern, "helloworld.eth", "ENS is searched if address is not received")
            compare(view.selectedRecipientAddress, "")

            // Imitate filtering: no results found
            view.model = emptyModel
            view.ensNameResolved("", "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", uuid)
            compare(view.searchPattern, "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240")
            compare(view.selectedRecipientAddress, "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240")
            compare(view.item.objectName, "RecipientView_RecipientViewDelegate", "Delegate is changed after selection is done")
        }

        function test_prefillSelectedRecipientAddress() {
            const view = createTemporaryObject(testComponent, root, { selectedRecipientAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240" })
            verify(view)

            compare(view.selectedRecipientAddress, "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240")
            compare(view.item.objectName, "RecipientView_RecipientViewDelegate")
            compare(view.item.address, "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240")
        }

        function test_interactive() {
            const view = createTemporaryObject(testComponent, root, { selectedRecipientAddress: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0Fd864dd", interactive: false })
            verify(view)

            const clearButton = findChild(view, "RecipientView_clearButton")
            verify(clearButton)

            verify(!view.interactive)
            verify(!clearButton.visible)

            view.interactive = true
            verify(clearButton.visible)
        }
    }
}
