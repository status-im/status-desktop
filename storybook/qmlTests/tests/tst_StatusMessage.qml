import QtQuick 2.15
import QtTest 1.15

import StatusQ.Components 0.1

Item {
    id: root
    width: 600
    height: 400

    Component {
        id: componentUnderTest
        StatusMessage {
            anchors.fill: parent
            messageDetails {
                messageText: ""
                contentType: StatusMessage.ContentType.Text
                amISender: false
                sender.id: "zq123456790"
                sender.displayName: "Alice"
                sender.isContact: true
                sender.trustIndicator: StatusContactVerificationIcons.TrustedType.None
                sender.isEnsVerified: false
                sender.profileImage {
                    name: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg="
                    colorId: 1
                    colorHash: "#51D0F0"
                }
            }
            linkAddressAndEnsName: true
            outgoingStatus: StatusMessage.OutgoingStatus.Sending
        }
    }

    property StatusMessage controlUnderTest: null

    TestCase {
        name: "StatusMessage"
        when: windowShown

        function init() {
            controlUnderTest = createTemporaryObject(componentUnderTest, root)
        }


        function test_different_address_formats_data() {
            return [
                        {messageText: "0x1234567890abcdef1234567890abcdef12345678", validAddressEnsCount: 1},   // Valid ETH address
                        {messageText: "0x1234567890abcdef1234567890abcdef12345678,
                                       0x16437e05858c1a34f0ae63c9ca960d61a5583d5e,
                                       0x75d5673fc25bb4993ea1218d9d415487c3656853", validAddressEnsCount: 3},   // Valid ETH address
                        {messageText: "0xAbCdEf1234567890abcdef1234567890AbCdEf12", validAddressEnsCount: 1},   // Valid ETH address
                        {messageText: "0x123", validAddressEnsCount: 0},                                        // Invalid ETH address (too short)
                        {messageText: "1234567890abcdef1234567890abcdef12345678", validAddressEnsCount: 0},     // Invalid ETH address (no 0x)
                        {messageText: "qwerty.stateofus.eth", validAddressEnsCount: 1},                         // Valid ETH address
                        {messageText: "alice.eth", validAddressEnsCount: 1},                                    // Valid ENS name
                        {messageText: "bob.eth", validAddressEnsCount: 1},                                      // Valid ENS name
                        {messageText: "sub.alice.eth", validAddressEnsCount: 1},                                // Valid ENS name with subdomain
                        {messageText: "bob.stateofus.eth", validAddressEnsCount: 1},                            // Valid ENS name with subdomain
                        {messageText: "ens.sub.sub.eth", validAddressEnsCount: 1},                              // Valid ENS name with multiple subdomains
                        {messageText: "example.com", validAddressEnsCount: 0},                                  // Invalid DNS-based ENS name
                        {messageText: "another.example.xyz", validAddressEnsCount: 0},                          // Invalid DNS-based ENS name
                        {messageText: "my-site.io", validAddressEnsCount: 0},                                   // Invalid DNS-based ENS name
                        {messageText: "invalid.ethaddress", validAddressEnsCount: 0},                           // Invalid ENS-like name
                        {messageText: "bob.eth.invalid", validAddressEnsCount: 0},                              // Invalid ENS-like name (invalid TLD)
                        {messageText: "My wallet is 0x1234567890abcdef1234567890abcdef12345678, and my ENS is alice.eth.", validAddressEnsCount: 2},  // Valid ETH and ENS in sentence
                        {messageText: "You can find me at bob.eth or contact me via 0xAbCdEf1234567890abcdef1234567890AbCdEf12.", validAddressEnsCount: 2},  // Valid ETH and ENS in sentence
                        {messageText: "Invalid address: 0x12345 and valid ENS: sub.alice.eth.", validAddressEnsCount: 1},  // Mixed case with valid and invalid
                        {messageText: "Check 0x123GHIJKLMNOPQRSTUVWXYZ and visit example.com.", validAddressEnsCount: 0},  // Mixed case with valid DNS and invalid ETH
                        {messageText: "0x1234567890abcdef1234567890abcdef12345678, qwerty.stateofus.eth,  0x16437e05858c1a34f0ae63c9ca960d61a5583d5e, 0x75d5673fc25bb4993ea1218d9d415487c3656853", validAddressEnsCount: 4},   // Valid ETH address
                    ]
        }

        function test_different_address_formats(data) {
            verify(!!controlUnderTest)

            controlUnderTest.messageDetails.messageText = data.messageText
            waitForRendering(controlUnderTest)

            const statusTextMessage = findChild(controlUnderTest, "StatusMessage_textMessage")
            verify(!!statusTextMessage)

            // Use regular expression to match all <a> tags in the text
            var linkMatches = statusTextMessage.textField.text.match(/<a\b[^>]*>(.*?)<\/a>/gi)
            var actualLinkCount = linkMatches ? linkMatches.length : 0

            compare(actualLinkCount, data.validAddressEnsCount, "TextEdit should contain a link %1".arg(data.messageText))
        }

        function test_attachment_empty() {
            verify(!!controlUnderTest)
            controlUnderTest.messageDetails.contentType = StatusMessage.ContentType.Attachment
            controlUnderTest.messageDetails.messageText = ""
            waitForRendering(controlUnderTest)

            const statusTextMessage = findChild(controlUnderTest, "StatusMessage_textMessage")
            verify(!statusTextMessage)
            const imageAlbum = findChild(controlUnderTest, "StatusMessage_imageAlbum")
            verify(!!imageAlbum)
            compare(imageAlbum.albumCount, 0)
            const image = findChild(imageAlbum, "album_image_loader_0")
            verify(!image)
            const requestPaymentItem = findChild(controlUnderTest, "StatusMessage_requestPaymentDelegate_0")
            verify(!requestPaymentItem)
        }

        function test_attachment_only_text() {
            verify(!!controlUnderTest)
            controlUnderTest.messageDetails.contentType = StatusMessage.ContentType.Attachment
            controlUnderTest.messageDetails.messageText = "test message"
            waitForRendering(controlUnderTest)

            const statusTextMessage = findChild(controlUnderTest, "StatusMessage_textMessage")
            verify(!!statusTextMessage)
            verify(statusTextMessage.textField.text.indexOf("test message") > 0)
            const imageAlbum = findChild(controlUnderTest, "StatusMessage_imageAlbum")
            verify(!!imageAlbum)
            compare(imageAlbum.albumCount, 0)
            const image = findChild(imageAlbum, "album_image_loader_0")
            verify(!image)
            const requestPaymentItem = findChild(controlUnderTest, "StatusMessage_requestPaymentDelegate_0")
            verify(!requestPaymentItem)
        }

        function test_attachment_multiple_attachments() {
            verify(!!controlUnderTest)
            controlUnderTest.messageDetails.contentType = StatusMessage.ContentType.Attachment
            controlUnderTest.messageDetails.messageText = "test message with attachments"
            controlUnderTest.messageDetails.album = [ "image0", "image1", "image2" ]
            controlUnderTest.messageDetails.albumCount = 3
            controlUnderTest.messageDetails.requestPaymentModel = [
                        {amount: "0.1", currency: "ETH", address: "0x1234567890abcdef1234567890abcdef12345678", chainId: 1},
                        {amount: "0.2", currency: "DAI", address: "0xAbCdEf1234567890abcdef1234567890AbCdEf12", chainId: 10},
                    ]
            waitForRendering(controlUnderTest)

            const statusTextMessage = findChild(controlUnderTest, "StatusMessage_textMessage")
            verify(!!statusTextMessage)
            verify(statusTextMessage.textField.text.indexOf("test message with attachments") > 0)
            const imageAlbum = findChild(controlUnderTest, "StatusMessage_imageAlbum")
            verify(!!imageAlbum)
            compare(imageAlbum.albumCount, 3)
            for (let i = 0 ; i < 3 ; i++) {
                const image = findChild(imageAlbum, "album_image_loader_"+i)
                verify(!!image)
            }
            const requestPaymentItem0 = findChild(controlUnderTest, "StatusMessage_requestPaymentDelegate_0")
            verify(!!requestPaymentItem0)
            const requestPaymentItem1 = findChild(controlUnderTest, "StatusMessage_requestPaymentDelegate_1")
            verify(!!requestPaymentItem1)
            const requestPaymentItem2 = findChild(controlUnderTest, "StatusMessage_requestPaymentDelegate_2")
            verify(!requestPaymentItem2)
        }
    }
}
