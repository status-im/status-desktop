#include "StatusQ/statuscolors.h"

#include <QRegularExpression>
#include <QtQml/qqml.h>

using namespace Qt::StringLiterals;

namespace {

const QVariantMap s_colors = {
    { "black"_L1,              StatusColors::black },
    { "white"_L1,              StatusColors::white },
    { "transparent"_L1,        StatusColors::transparent },

    { "blue"_L1,               StatusColors::blue },
    { "blue2"_L1,              StatusColors::blue2 },
    { "blue3"_L1,              StatusColors::blue3 },
    { "blue4"_L1,              StatusColors::blue4 },
    { "blue5"_L1,              StatusColors::blue5 },
    { "blue6"_L1,              StatusColors::blue6 },
    { "blue7"_L1,              StatusColors::blue7 },
    { "blue8"_L1,              StatusColors::blue8 },

    { "brown"_L1,              StatusColors::brown },
    { "brown2"_L1,             StatusColors::brown2 },
    { "brown3"_L1,             StatusColors::brown3 },

    { "cyan"_L1,               StatusColors::cyan },

    { "graphite"_L1,           StatusColors::graphite },
    { "graphite2"_L1,          StatusColors::graphite2 },
    { "graphite3"_L1,          StatusColors::graphite3 },
    { "graphite4"_L1,          StatusColors::graphite4 },
    { "graphite5"_L1,          StatusColors::graphite5 },

    { "green"_L1,              StatusColors::green },
    { "green2"_L1,             StatusColors::green2 },
    { "green3"_L1,             StatusColors::green3 },
    { "green4"_L1,             StatusColors::green4 },
    { "green5"_L1,             StatusColors::green5 },
    { "green6"_L1,             StatusColors::green6 },

    { "grey"_L1,               StatusColors::grey },
    { "grey2"_L1,              StatusColors::grey2 },
    { "grey3"_L1,              StatusColors::grey3 },
    { "grey4"_L1,              StatusColors::grey4 },
    { "grey5"_L1,              StatusColors::grey5 },

    { "moss"_L1,               StatusColors::moss },
    { "moss2"_L1,              StatusColors::moss2 },

    { "orange"_L1,             StatusColors::orange },
    { "orange2"_L1,            StatusColors::orange2 },
    { "orange3"_L1,            StatusColors::orange3 },
    { "orange4"_L1,            StatusColors::orange4 },

    { "warning_orange"_L1,     StatusColors::warning_orange },

    { "purple"_L1,             StatusColors::purple },

    { "red"_L1,                StatusColors::red },
    { "red2"_L1,               StatusColors::red2 },
    { "red3"_L1,               StatusColors::red3 },

    { "turquoise"_L1,          StatusColors::turquoise },
    { "turquoise2"_L1,         StatusColors::turquoise2 },
    { "turquoise3"_L1,         StatusColors::turquoise3 },
    { "turquoise4"_L1,         StatusColors::turquoise4 },

    { "violet"_L1,             StatusColors::violet },

    { "yellow"_L1,             StatusColors::yellow },
    { "yellow2"_L1,            StatusColors::yellow2 },

    { "blueHijab"_L1,          StatusColors::blueHijab },

    { "lightPattensBlue"_L1,   StatusColors::lightPattensBlue },

    { "blackHovered"_L1,       StatusColors::blackHovered },
    { "blueHovered"_L1,        StatusColors::blueHovered },
    { "purpleHovered"_L1,      StatusColors::purpleHovered },
    { "cyanHovered"_L1,        StatusColors::cyanHovered },
    { "violetHovered"_L1,      StatusColors::violetHovered },
    { "redHovered"_L1,         StatusColors::redHovered },
    { "yellowHovered"_L1,      StatusColors::yellowHovered },
    { "greenHovered"_L1,       StatusColors::greenHovered },
    { "mossHovered"_L1,        StatusColors::mossHovered },
    { "brownHovered"_L1,       StatusColors::brownHovered },
    { "brown2Hovered"_L1,      StatusColors::brown2Hovered },

    { "lightDesktopBlue10"_L1, StatusColors::lightDesktopBlue10 },
    { "darkDesktopBlue10"_L1,  StatusColors::darkDesktopBlue10 }
};

} // unnamed namespace

StatusColors::StatusColors(QObject* parent)
    : QObject(parent)
{
}

const QVariantMap& StatusColors::colors()
{
    return s_colors;
}

QColor StatusColors::getColor(const QString& name, qreal alpha)
{
    QColor base;

    if (s_colors.contains(name)) {
        base = s_colors.value(name).value<QColor>();
    } else {
        base = QColor::fromString(name);
    }

    return alphaColor(base, alpha);
}

QColor StatusColors::alphaColor(const QColor& color, qreal alpha)
{
    QColor c = color;
    c.setAlphaF(std::clamp(alpha, 0.0, 1.0));
    return c;
}
