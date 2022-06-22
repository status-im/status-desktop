import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

StatusListItem {
    property var community

    title: community.name
    subTitle: community.amISectionAdmin ? qsTr("Admin") : qsTr("Member")
    
    image {
        source: community.image
    }

    icon {
        name: community.name
        letterSize: 14
        isLetterIdenticon: !community.image
        color: community.color
    }
}
