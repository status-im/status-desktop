import QtQuick 2.13

ListModel {
    ListElement {
        userName: "Ferocious Herringbone Sinewave"
        message: "Everybody betrayed me! \n I'm fed up with this world."
        sticker: ""
        contentType: 1
        repeatMessageInfo: true
    }
    ListElement {
        userName: "Teenage Mutant Turtle"
        message: "You're tearing me apart, Lisa!"
        sticker: ""
        contentType: 1
        repeatMessageInfo: true
    }
    ListElement {
        userName: "Teenage Mutant Turtle"
        message: "It's bullshit, I did not hit her.\nI did nooot."
        sticker: ""
        contentType: 1
        repeatMessageInfo: false
    }
    ListElement {
        userName: "Teenage Mutant Turtle"
        //message: "Oh hi, Mark!"
        contentType: 2
        sticker: "Qme8vJtyrEHxABcSVGPF95PtozDgUyfr1xGjePmFdZgk9v"
        repeatMessageInfo: false
    }
    ListElement {
        userName: "me"
        message: "Hi Johnny"
        isCurrentUser: true
        contentType: 1
        sticker: ""
        repeatMessageInfo: true
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
