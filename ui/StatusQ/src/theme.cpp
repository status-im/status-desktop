#include "StatusQ/theme.h"

namespace {

constexpr qreal s_defaultPadding = 16;
constexpr qreal s_xlPaddingFactor = 2.0;
constexpr qreal s_bigPaddingFactor = 1.5;
constexpr qreal s_halfPaddingFactor = 0.5;
constexpr qreal s_smallPaddingFactor = 0.625;

const std::unique_ptr<ThemePalette> s_paletteDark = createDarkThemePalette();
const std::unique_ptr<ThemePalette> s_paletteLight = createLightThemePalette();

} // unnamed namespace

Theme::Theme(QObject *parent)
    : QQuickAttachedPropertyPropagator(parent), m_padding(s_defaultPadding)
{
    initialize();
}

qreal Theme::padding() const {
    return m_padding;
}

qreal Theme::xlPadding() const {
    return m_padding * s_xlPaddingFactor;
}

qreal Theme::bigPadding() const {
    return m_padding * s_bigPaddingFactor;
}

qreal Theme::halfPadding() const {
    return m_padding * s_halfPaddingFactor;
}

qreal Theme::smallPadding() const {
    return m_padding * s_smallPaddingFactor;
}

void Theme::setPadding(qreal padding)
{
    auto explicitPaddingOld = m_explicitPadding;
    m_explicitPadding = true;

    if (m_padding == padding) {
        if (!explicitPaddingOld)
            emit explicitPaddingChanged();

        return;
    }

    m_padding = padding;
    propagatePadding();
    emit paddingChanged();

    if (!explicitPaddingOld)
        emit explicitPaddingChanged();
}

void Theme::resetPadding()
{
    if (!m_explicitPadding)
        return;

    m_explicitPadding = false;
    auto theme = qobject_cast<Theme*>(attachedParent());

    inheritPadding(theme ? theme->padding() : 0);

    emit explicitPaddingChanged();
}

void Theme::inheritPadding(qreal padding)
{
    if (m_explicitPadding || m_padding == padding)
        return;

    m_padding = padding;
    propagatePadding();
    emit paddingChanged();
}

void Theme::propagatePadding()
{
    const auto themes = attachedChildren();
    for (QQuickAttachedPropertyPropagator *child : themes) {
        auto theme = qobject_cast<Theme*>(child);
        if (theme)
            theme->inheritPadding(m_padding);
    }
}

bool Theme::explicitPadding() const {
    return m_explicitPadding;
}

Theme::Style Theme::style() const
{
    return m_style;
}

void Theme::setStyle(Style style)
{
    auto explicitStyleOld = m_explicitStyle;
    m_explicitStyle = true;

    if (m_style == style) {
        if (!explicitStyleOld)
            emit explicitStyleChanged();

        return;
    }

    m_style = style;

    propagateStyle();
    emit styleChanged();

    if (!explicitStyleOld)
        emit explicitStyleChanged();
}

void Theme::resetStyle()
{
    if (!m_explicitStyle)
        return;

    m_explicitStyle = false;
    auto theme = qobject_cast<Theme*>(attachedParent());

    inheritStyle(theme ? theme->style() : Style::Light);

    emit explicitStyleChanged();
}

void Theme::inheritStyle(Style style)
{
    if (m_explicitStyle || m_style == style)
        return;

    m_style = style;
    propagateStyle();
    emit styleChanged();
}

void Theme::propagateStyle()
{
    const auto themes = attachedChildren();
    for (QQuickAttachedPropertyPropagator *child : themes) {
        auto theme = qobject_cast<Theme*>(child);
        if (theme)
            theme->inheritStyle(m_style);
    }
}

bool Theme::explicitStyle() const {
    return m_explicitStyle;
}

const ThemePalette* Theme::palette() const
{
    return m_style == Style::Light ? s_paletteLight.get()
                                   : s_paletteDark.get();
}

Theme* Theme::qmlAttachedProperties(QObject *object)
{
    return new Theme(object);
}

void Theme::attachedParentChange(QQuickAttachedPropertyPropagator* newParent,
                                 QQuickAttachedPropertyPropagator* oldParent)
{
    Q_UNUSED(oldParent);
    auto attachedParentTheme = qobject_cast<Theme*>(newParent);
    if (attachedParentTheme) {
        inheritPadding(attachedParentTheme->padding());
        inheritStyle(attachedParentTheme->style());
    }
}
