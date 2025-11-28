#include "StatusQ/statuscolors.h"

#include <QRegularExpression>
#include <QtQml/qqml.h>

using namespace Qt::StringLiterals;

namespace {

const QVariantMap s_colors = {
    { "black"_L1,              QColor(0x00, 0x00, 0x00) },
    { "white"_L1,              QColor(0xFF, 0xFF, 0xFF) },

    { "blue"_L1,               QColor(0x43, 0x60, 0xDF) },
    { "blue2"_L1,              QColor(0x29, 0x46, 0xC4) },
    { "blue3"_L1,              QColor(0x88, 0xB0, 0xFF) },
    { "blue4"_L1,              QColor(0x86, 0x9E, 0xFF) },
    { "blue5"_L1,              QColor(0xAA, 0xC6, 0xFF) },
    { "blue6"_L1,              QColor(0xEC, 0xEF, 0xFC) },
    { "blue7"_L1,              QColor(0x09, 0x10, 0x1C) },
    { "blue8"_L1,              QColor(0x6B, 0x6F, 0x76) },

    { "brown"_L1,              QColor(0x8B, 0x31, 0x31) },
    { "brown2"_L1,             QColor(0x9B, 0x83, 0x2F) },
    { "brown3"_L1,             QColor(0xAD, 0x43, 0x43) },

    { "cyan"_L1,               QColor(0x51, 0xD0, 0xF0) },

    { "graphite"_L1,           QColor(0x21, 0x21, 0x21) },
    { "graphite2"_L1,          QColor(0x25, 0x25, 0x25) },
    { "graphite3"_L1,          QColor(0x2C, 0x2C, 0x2C) },
    { "graphite4"_L1,          QColor(0x37, 0x37, 0x37) },
    { "graphite5"_L1,          QColor(0x90, 0x90, 0x90) },

    { "green"_L1,              QColor(0x4E, 0xBC, 0x60) },
    { "green2"_L1,             QColor(0x7C, 0xDA, 0x00) },
    { "green3"_L1,             QColor(0x60, 0xC3, 0x70) },
    { "green4"_L1,             QColor(0x93, 0xDB, 0x33) },
    { "green5"_L1,             QColor(0x9E, 0xA8, 0x5D) },
    { "green6"_L1,             QColor(0xAF, 0xB5, 0x51) },

    { "grey"_L1,               QColor(0xF0, 0xF2, 0xF5) },
    { "grey2"_L1,              QColor(0xF6, 0xF8, 0xFA) },
    { "grey3"_L1,              QColor(0xE9, 0xED, 0xF1) },
    { "grey4"_L1,              QColor(0xEE, 0xF2, 0xF5) },
    { "grey5"_L1,              QColor(0x93, 0x9B, 0xA1) },

    { "moss"_L1,               QColor(0x26, 0xA6, 0x9A) },
    { "moss2"_L1,              QColor(0x10, 0xA8, 0x8E) },

    { "orange"_L1,             QColor(0xFE, 0x8F, 0x59) },
    { "orange2"_L1,            QColor(0xFF, 0x9F, 0x0F) },
    { "orange3"_L1,            QColor(0xFF, 0xA6, 0x7B) },
    { "orange4"_L1,            QColor(0xFE, 0x8F, 0x59) },

    { "warning_orange"_L1,     QColor(0xF6, 0x79, 0x3C) },

    { "purple"_L1,             QColor(0x88, 0x7A, 0xF9) },

    { "red"_L1,                QColor(0xFF, 0x2D, 0x55) },
    { "red2"_L1,               QColor(0xFA, 0x65, 0x65) },
    { "red3"_L1,               QColor(0xFF, 0x5C, 0x7B) },

    { "turquoise"_L1,          QColor(0x0D, 0xA4, 0xC9) },
    { "turquoise2"_L1,         QColor(0x07, 0xBC, 0xE9) },
    { "turquoise3"_L1,         QColor(0x7B, 0xE5, 0xFF) },
    { "turquoise4"_L1,         QColor(0x0D, 0xA4, 0xC9) },

    { "violet"_L1,             QColor(0xD3, 0x7E, 0xF4) },

    { "yellow"_L1,             QColor(0xFF, 0xCA, 0x0F) },
    { "yellow2"_L1,            QColor(0xEA, 0xD2, 0x7B) },

    { "blueHijab"_L1,          QColor(0xCD, 0xF2, 0xFB) },

    { "lightPattensBlue"_L1,   QColor(0xD7, 0xDE, 0xE4) },

    { "blackHovered"_L1,       QColor(0x1D, 0x23, 0x2E) },
    { "blueHovered"_L1,        QColor(0x36, 0x4D, 0xB2) },
    { "purpleHovered"_L1,      QColor(0x6D, 0x62, 0xC7) },
    { "cyanHovered"_L1,        QColor(0x41, 0xA6, 0xC0) },
    { "violetHovered"_L1,      QColor(0xA9, 0x65, 0xC3) },
    { "redHovered"_L1,         QColor(0xC8, 0x51, 0x51) },
    { "yellowHovered"_L1,      QColor(0xCC, 0xA2, 0x0C) },
    { "greenHovered"_L1,       QColor(0x63, 0xAE, 0x00) },
    { "mossHovered"_L1,        QColor(0x1E, 0x85, 0x7B) },
    { "brownHovered"_L1,       QColor(0x6F, 0x27, 0x27) },
    { "brown2Hovered"_L1,      QColor(0x7C, 0x69, 0x26) },

    { "lightDesktopBlue10"_L1, QColor(0xEC, 0xEF, 0xFB) },
    { "darkDesktopBlue10"_L1,  QColor(0x27, 0x32, 0x51) }
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

    if (alpha > 0.0 && alpha <= 1.0)
        base.setAlphaF(alpha);

    return base;
}

QColor StatusColors::alphaColor(const QColor& color, qreal alpha)
{
    QColor c = color;
    if (alpha > 0.0 && alpha <= 1.0)
        c.setAlphaF(alpha);
    return c;
}
