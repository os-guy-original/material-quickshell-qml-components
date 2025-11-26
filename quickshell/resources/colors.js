.pragma library
// Centralized color tokens (Material 3 style). Non-QML JS module.
// Import in QML with: import "../colors.js" as Palette

var isDark = true;

var light = {
  primary: "#114a73",
  onPrimary: "#ffffff",
  primaryContainer: "#cfe5ff",
  onPrimaryContainer: "#000000",

  secondary: "#b9c8da",
  onSecondary: "#000000",
  secondaryContainer: "#e0e2e8",
  onSecondaryContainer: "#000000",

  tertiary: "#d4bee6",
  onTertiary: "#000000",
  tertiaryContainer: "#FFD8E4",
  onTertiaryContainer: "#000000",

  error: "#B3261E",
  onError: "#ffffff",
  errorContainer: "#F9DEDC",
  onErrorContainer: "#000000",

  background: "#eceef4",
  onBackground: "#181c20",
  surface: "#e0e2e8",
  onSurface: "#42474e",
  surfaceVariant: "#c7ccd3",
  onSurfaceVariant: "#42474e",
  surfaceContainer: "#f7f9ff",
  surfaceContainerHighest: "#e0e2e8",
  outline: "#79747E",
  shadow: "#000000",

  inverseSurface: "#f7f9ff",
  inverseOnSurface: "#181c20",
  inversePrimary: "#9ccbfb"
};

var dark = {
  primary: "#ffb59b",
  onPrimary: "#72361e",
  primaryContainer: "#72361e",
  onPrimaryContainer: "#ffffff",

  secondary: "#e7bdaf",
  onSecondary: "#ffffff",
  secondaryContainer: "#322824",
  onSecondaryContainer: "#ffffff",

  tertiary: "#d5c68e",
  onTertiary: "#ffffff",
  tertiaryContainer: "#322824",
  onTertiaryContainer: "#ffffff",

  error: "#f2b8b5",
  onError: "#601410",
  errorContainer: "#8C1D18",
  onErrorContainer: "#F9DEDC",

  background: "#271d1a",
  onBackground: "#f1dfd9",
  surface: "#271d1a",
  onSurface: "#f1dfd9",
  surfaceVariant: "#53433e",
  onSurfaceVariant: "#d8c2bb",
  surfaceContainer: "#1a110e",
  surfaceContainerHighest: "#3d322f",
  outline: "#938F99",
  shadow: "#000000",

  inverseSurface: "#f1dfd9",
  inverseOnSurface: "#271d1a",
  inversePrimary: "#ffb59b"
};

function setDarkMode(darkMode) { isDark = !!darkMode; }
function toggleMode() { isDark = !isDark; }
function palette() { return isDark ? dark : light; }
function isDarkMode() { return isDark; }

// Optional direct tokens (static snapshot at load)
var primary = palette().primary;
var onPrimary = palette().onPrimary;


