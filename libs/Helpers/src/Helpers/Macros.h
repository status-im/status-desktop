#pragma once

// Macro arguments are completely macro-expanded before they are substituted into a macro body.
#define STATUS_EXPAND(x) x

// 2 arguments macro selector.
#define STATUS_MACRO_SELECTOR_2_ARGS(_1, _2, selected, ...) selected

// 3 arguments macro selector.
#define STATUS_MACRO_SELECTOR_3_ARGS(_1, _2, _3, selected, ...) selected
