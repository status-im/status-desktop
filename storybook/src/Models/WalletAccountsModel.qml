import QtQuick 2.15

ListModel {
    ListElement { name: "Test account"; emoji: "😋"; colorId: "primary"; address: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240"; walletType: "" }
    ListElement { name: "Another account - generated"; emoji: "🚗"; colorId: "army"; address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8888"; walletType: "generated" }
    ListElement { name: "Another account - seed"; emoji: "🎨"; colorId: "army"; address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8888"; walletType: "seed" }
    ListElement { name: "Another account - watch"; emoji: "🔗"; colorId: "army"; address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8888"; walletType: "watch" }
    ListElement { name: "Another account - key"; emoji: "💼"; colorId: "army"; address: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8888"; walletType: "key" }
}
