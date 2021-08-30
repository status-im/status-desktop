import QtQuick 2.14

QtObject {
    property string title
    property string subTitle
    property int titleElide: Text.ElideRight
    property int subTitleElide: Text.ElideRight
    property StatusImageSettings image: StatusImageSettings {
        width: 40
        height: 40
        isIdenticon: false
    }

    property StatusIconSettings icon: StatusIconSettings {
        width: 40
        height: 40
        isLetterIdenticon: false
    }
}
