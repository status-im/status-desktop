import QtQuick 2.15

ListModel {
    id: root

    ListElement {
        pubKey: "0x043a7ed0e8d1012cf04"
        onlineStatus: 1
        isContact: true
        isVerified: false
        isAdmin: false
        isUntrustworthy: true
        displayName: "Mike has a very long name that should elide eventually and result in a tooltip displayed instead"
        alias: ""
        localNickname: ""
        ensName: ""
        icon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
              nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
        colorId: 7
        isEnsVerified: false
        colorHash: [
            ListElement {colorId: 0; segmentLength: 2},
            ListElement {colorId: 17; segmentLength: 2}
        ]
        isAwaitingAddress: false
        memberRole: 0 // Constants.memberRole.none
    }
    ListElement {
        pubKey: "0x04df12f12f12f12f1234"
        onlineStatus: 0
        isContact: false
        isVerified: false
        isAdmin: false
        isUntrustworthy: false
        displayName: "Jane"
        alias: ""
        localNickname: ""
        ensName: ""
        icon: ""
        colorId: 9
        isEnsVerified: false
        colorHash: [
            ListElement {colorId: 0; segmentLength: 1},
            ListElement {colorId: 19; segmentLength: 2}
        ]
        isAwaitingAddress: false
        memberRole: 1 // Constants.memberRole.owner
    }
    ListElement {
        pubKey: "0x04d1b7cc0ef3f470f1238"
        onlineStatus: 0
        isContact: false
        isVerified: false
        isAdmin: false
        isUntrustworthy: true
        displayName: "John"
        alias: ""
        localNickname: "Johnny Johny"
        ensName: ""
        icon: "https://cryptologos.cc/logos/status-snt-logo.svg?v=033"
        colorId: 4
        isEnsVerified: false
        isAwaitingAddress: false
        memberRole: 0
    }
    ListElement {
        pubKey: "0x04d1bed192343f470f1257"
        onlineStatus: 1
        isContact: true
        isVerified: true
        isAdmin: false
        isUntrustworthy: true
        displayName: "Maria"
        alias: "meth"
        localNickname: "86.eth"
        ensName: "8⃣6⃣.eth"
        icon: ""
        colorId: 5
        isEnsVerified: true
        isAwaitingAddress: false
        memberRole: 0
    }
    ListElement {
        pubKey: "0x04d1bed192343f470f1255"
        onlineStatus: 1
        isContact: true
        isVerified: true
        isAdmin: true
        isUntrustworthy: true
        displayName: ""
        alias: "Richard The Lionheart"
        localNickname: ""
        ensName: "richard-the-lionheart.eth"
        icon: ""
        colorId: 3
        isEnsVerified: true
        isAwaitingAddress: false
        memberRole: 0
    }
    ListElement {
        pubKey: "0x04d1bed192343f470fabc"
        onlineStatus: 0
        isContact: true
        isVerified: false
        isAdmin: false
        isUntrustworthy: false
        displayName: ""
        alias: ""
        localNickname: ""
        ensName: "8⃣6⃣.eth"
        icon: ""
        colorId: 7
        isEnsVerified: true
        isAwaitingAddress: true
        memberRole: 0
    }
}
