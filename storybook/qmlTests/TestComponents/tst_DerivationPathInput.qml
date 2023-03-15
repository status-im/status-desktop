import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQml 2.14
import QtTest 1.0

import AppLayouts.Wallet.addaccount.panels 1.0
import AppLayouts.Wallet.addaccount.panels.DerivationPathInput 1.0

Item {
    id: root
    width: 600
    height: 400

    TestCase {
        name: "DerivationPathInputControllerTests"

        Component {
            id: controllerComponent

            Controller {
                enabledColor: "white"
                frozenColor: "black"
                errorColor: "red"
            }
        }

        property Controller controller: null

        function init() {
            controller = createTemporaryObject(controllerComponent, root)
        }

        function test_parseRegularBases_data() {
            return [
                {tag: "Ethereum Standard", base: "m/44'/60'/0'/0", expected: ["m/44'/", "60", "'/", "0", "'/", "0"]},
                {tag: "Custom", base: "m/44'/", expected: ["m/44'/"]},
                {tag: "Ethereum Ledger", base: "m/44'/60'/0'", expected: ["m/44'/", "60", "'/", "0", "'"]},
                {tag: "Ethereum Ledger Live", base: "m/44'/60'", expected: ["m/44'/", "60", "'"]},
            ]
        }

        function test_parseRegularBases(data) {
            let res = controller.parseDerivationPath(data.base)
            compare(res.length, data.expected.length, `expect same length: ${JSON.stringify(res)} vs ${JSON.stringify(data.expected)}`)
            for (const i in res) {
                compare(data.expected[i], res[i].content)
            }
        }

        function test_parseRegularDerivationPath_data() {
            return [
                {tag: "Ethereum one address index", derivationPath: "m/44'/60'/0'/0/1", expected: ["m/44'/", "60", "'/", "0", "'/", "0", "/", "1"]},
                {tag: "Ethereum two address index", derivationPath: "m/44'/60'/0'/0/1/2", expected: ["m/44'/", "60", "'/", "0", "'/", "0", "/", "1", "/", "2"]},
                {tag: "Ethereum Ledger", derivationPath: "m/44'/60'/0'/1/2", expected: ["m/44'/", "60", "'/", "0", "'/", "1", "/", "2"]},
                {tag: "Ethereum Ledger Live", derivationPath: "m/44'/60'/1'/2/3", expected: ["m/44'/", "60", "'/", "1", "'/", "2", "/", "3"]},
                {tag: "Empty entries", derivationPath: "m/44'/'/'//", expected: ["m/44'/", "", "'/", "", "'/", "", "/", ""]},
                {tag: "Wrong entries", derivationPath: "m/44'/T<'/.?'/;/wrong", expected: ["m/44'/", "T<", "'/", ".?", "'/", ";", "/", "wrong"]}
            ]
        }

        function test_parseRegularDerivationPath(data) {
            let res = controller.parseDerivationPath(data.derivationPath)
            compare(res.length, data.expected.length)
            for (const i in res) {
                compare(data.expected[i], res[i].content)
            }
        }
        function test_completeDerivationPath_data() {
            return [
                {name: "Ethereum", base: "m/44'/60'/0'/0", derivationPath: "m/44'/60'/0'/0/1", expected: ["m/44'/", "60", "'/", "0", "'/", "0", "/", "1"]},
                {name: "Ending in separator", base: "m/44'/60'/0'/0", derivationPath: "m/44'/60'/0'/0/", expected: ["m/44'/", "60", "'/", "0", "'/", "0", "/", ""]},
                {name: "Custom", base: "m/44'", derivationPath: "m/44'", expected: ["m/44'/", ""]},
            ]
        }

        function test_completeDerivationPath(data) {
            let res = controller.completeDerivationPath(data.base, data.derivationPath)
            verify(res.errorMessage.length === 0, `expect no error message, got "${res.errorMessage}"`)
            compare(res.elements.length, data.expected.length, `expect same length for test data entry ${data.name}, ${JSON.stringify(res.elements)} vs ${JSON.stringify(data.expected)}`)
            for (const i in res) {
                compare(data.expected[i], res[i].content)
            }
        }

        function test_parseRegularWrongDerivationPath_data() {
            return [
                {name: "Ethereum", derivationPath: "m'/46'/60'/0'/0/1"},
                {name: "Ethereum", derivationPath: "m/44'/60/0'/0/1/2"},
                {name: "Ethereum Ledger", derivationPath: "m/44'/60'/0/1/2"},
                {name: "Incomplete", derivationPath: "m/44"},
                {name: "Ethereum", derivationPath: "'/46'/60'/0'/0/1"},
            ]
        }

        function test_parseRegularWrongDerivationPath(data) {
            let res = controller.parseDerivationPath(data.derivationPath)
            compare(res, null)
        }

        Component {
            id: testDataElementsComponent
            Item {
                Element { id: base; content: "m/44'/"; startIndex: 0; endIndex: 7; contentType: Element.ContentType.Base }
                Element { id: coin; content: "60"; startIndex: base.endIndex; endIndex: startIndex + content.length; contentType: Element.ContentType.Number }
                Element { id: coinAccSep; content: "'/"; startIndex: coin.endIndex; endIndex: startIndex + content.length; contentType: Element.ContentType.Separator }
                Element { id: acc; content: "777"; startIndex: coinAccSep.endIndex; endIndex: startIndex + content.length; contentType: Element.ContentType.Number }
                Element { id: accChgSep; content: "'/"; startIndex: acc.endIndex; endIndex: startIndex + content.length; contentType: Element.ContentType.Separator }
                Element { id: chg; content: "0"; startIndex: accChgSep.endIndex; endIndex: startIndex + content.length; contentType: Element.ContentType.Number }
                Element { id: chgAccIdxSep; content: "/"; startIndex: chg.endIndex; endIndex: startIndex + content.length; contentType: Element.ContentType.Separator }
                Element { id: accIdx1; content: "1"; startIndex: chgAccIdxSep.endIndex; endIndex: startIndex + content.length; contentType: Element.ContentType.Number }
                Element { id: accIdxSep1; content: "/"; startIndex: accIdx1.endIndex; endIndex: startIndex + content.length; contentType: Element.ContentType.Separator }
                Element { id: accIdx2; content: "2"; startIndex: accIdxSep1.endIndex; endIndex: startIndex + content.length; contentType: Element.ContentType.Number }
                Element { id: accIdxSep2; content: "/"; startIndex: accIdx2.endIndex; endIndex: startIndex + content.length; contentType: Element.ContentType.Separator }
                Element { id: accIdx3; content: "2"; startIndex: accIdxSep2.endIndex; endIndex: startIndex + content.length; contentType: Element.ContentType.Number }
            }
        }

        function test_generateHtml() {
            let res = controller.generateHtmlFromElements(testDataElementsComponent.createObject(root).resources)
            verify(/^<style>(?:\.[a-zA-Z]{[a-zA-Z0-9#:;]+})+<\/style>(?:<span\sclass=["']\w["']>[\/\d'm]+<\/span>)+$/.test(res), `The generated html is valid and optimum (no extra spaces or CSS long names) - "${res}"`)
        }
    }

    TestCase {
        name: "DerivationPathInputRegressionTests"

        Component {
            id: regressionControlComponent

            DerivationPathInput {
                initialDerivationPath: "m/44'/60'/0'/0/1"
                initialBasePath: "m/44'/60'/0'/0"
            }
        }

        property DerivationPathInput controller: null

        // Controller.Component.onCompleted was initializing Component.d.referenceElements after DerivationPathInput.onCompleted was processing the DerivationPathInput.initialDerivationPath, hence the output was wrong (m/44'/60001)
        function test_successfulInitializationOfControllerBeforeItem() {
            const control = createTemporaryObject(regressionControlComponent, root)
            compare("m/44'/60'/0'/0/1", control.derivationPath)
        }
    }
}
