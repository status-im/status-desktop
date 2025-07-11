import QtQuick
import QtQml

QtObject {
    readonly property var iterator: getIterator()
    readonly property var messages: [
            [
                qsTr("Status messenger is the most secure fully decentralised messenger in the world"),
                qsTr("Full metadata privacy means it’s impossible to tell who you are talking to by surveilling your internet traffic"),
                qsTr("Status is truly private - none of your personal details (or any other information) are sent to us"),
                qsTr("Messages sent using Status are end to end encrypted and can only be opened by the recipient"),
                qsTr("Status uses the Waku p2p gossip messaging protocol — an evolution of the EF’s original Whisper protocol"),
                qsTr("Status is home to crypto’s leading multi-chain self-custodial wallet"),
                qsTr("Status removes intermediaries to keep your messages private and your assets secure"),
                qsTr("Status uses the latest encryption and security tools to secure your messages and transactions"),
                qsTr("Status enables pseudo-anonymous interaction with Web3, DeFi, and society in general"),
                qsTr("The Status Network token (SNT) is a modular utility token that fuels the Status network"),
                qsTr("Your cryptographic key pair encrypts all of your messages which can only be unlocked by the intended recipient"),
                qsTr("Your non-custodial wallet gives you full control over your funds without the use of a server"),
                qsTr("Status is decentralized and serverless - chat, transact, and browse without surveillance and censorship"),
                qsTr("Status is open source software that lets you use with p2p networks. Status itself doesn’t provide any services"),
                qsTr("Status is a way to access p2p networks that are permissionlessly created and run by individuals around the world"),
            ],
            [
                qsTr("Our 10 core principles include liberty, security, transparency, censorship resistance and inclusivity"),
                qsTr("Status believes in freedom, and in maximizing the individual freedom of our users"),
                qsTr("Status is designed and built to protect the sovereignty of individuals"),
                qsTr("Status aims to protect the right to private, secure conversations, and the freedom to associate and collaborate"),
                qsTr("One of our core aims is to maximize social, political, and economic freedoms"),
                qsTr("Status abides by the cryptoeconomic design principle of censorship resistance"),
                qsTr("Status is a public good licensed under the MIT open source license, for anyone to share, modify and benefit from"),
                qsTr("Status supports free communication without the approval or oversight of big tech"),
                qsTr("Status allows you to communicate freely without the threat of surveillance"),
                qsTr("Status supports free speech. Using p2p networks prevents us, or anyone else, from censoring you"),
            ],
            [
                qsTr("Status is entirely open source and made by contributors all over the world"),
                qsTr("Status is a globally distributed team of 150+ specialist core contributors"),
                qsTr("Our team of core contributors work remotely from over 50+ countries spread across 6 continents"),
                qsTr("The only continent that doesn’t (yet!) have any Status core contributors is Antarctica"),
                qsTr("We are the 5th most active crypto project on github"),
                qsTr("We are dedicated to transitioning our governance model to being decentralised and autonomous"),
                qsTr("Status core-contributors use Status as their primary communication tool"),
            ],
            [
                qsTr("Status was co-founded by Jarrad Hope and Carl Bennetts"),
                qsTr("Status was created to ease the transition to a more open mobile internet"),
                qsTr("Status aims to help anyone, anywhere, interact with Ethereum, requiring no more than a phone"),
            ],
            [
                qsTr("Your mobile company, and government are able to see the contents of all your private SMS messages"),
                qsTr("Many other messengers with e2e encryption don’t have metadata privacy!"),
            ],
            [
                qsTr("Help to translate Status into your native language see https://translate.status.im/ for more info"),
                qsTr("By using Keycard, you can ensure your funds are safe even if your phone is stolen"),
                qsTr("You can enhance security by using Keycard + PIN entry as two-factor authentication"),
            ],
            [
                qsTr("Status is currently working on a multi-chain wallet which will allow quick and easy multi-chain txns."),
                qsTr("The new Status mobile app is being actively developed and is earmarked for release in 2023"),
                qsTr("The all new Status desktop app is being actively developed and is earmarked for release in 2023"),
                qsTr("Status also builds the Nimbus Ethereum consensus, execution and light clients"),
                qsTr("Status’s Nimbus team is collaborating with the Ethereum Foundation to create the Portal Network"),
                qsTr("Status’s Portal Network client (Fluffy) will let Status users interact with Ethereum in a fully decenteralised way"),
                qsTr("We are currently working on a tool to let you import an existing Telegram or Discord group into Status"),
            ]
    ]

    //provides a way to randomly iterate through the messages
    function getIterator() {
        let categoryIndex = 0
        return {
            next: function() {
                if (categoryIndex == messages.length -1) {
                    categoryIndex = 0
                } else {
                    categoryIndex++
                }
                let messageArray = messages[categoryIndex]
                return messageArray[Math.floor(Math.random() * messageArray.length)]
            }
        }
    }
}
