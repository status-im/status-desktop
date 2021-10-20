import QtQuick 2.14

QtObject {
    property string title
    property string subTitle
    property int titleElide: Text.ElideRight
    property int subTitleElide: Text.ElideRight
    property bool headerImageEditable: false
    property bool editable: false
    property Component popupMenu
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
