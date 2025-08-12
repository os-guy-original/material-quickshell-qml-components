.pragma library
// Centralized color tokens (Material 3 style). Non-QML JS module.
// Import in QML with: import "../colors.js" as Palette

var isDark = true; // default to dark mode

var light = {
  primary: "#6750A4",
  onPrimary: "#FFFFFF",
  primaryContainer: "#EADDFF",
  onPrimaryContainer: "#21005D",

  secondary: "#625B71",
  onSecondary: "#FFFFFF",
  secondaryContainer: "#E8DEF8",
  onSecondaryContainer: "#1D192B",

  tertiary: "#7D5260",
  onTertiary: "#FFFFFF",
  tertiaryContainer: "#FFD8E4",
  onTertiaryContainer: "#31111D",

  error: "#B3261E",
  onError: "#FFFFFF",
  errorContainer: "#F9DEDC",
  onErrorContainer: "#410E0B",

  background: "#FFFBFE",
  onBackground: "#1C1B1F",
  surface: "#FFFBFE",
  onSurface: "#1C1B1F",
  surfaceVariant: "#E7E0EC",
  onSurfaceVariant: "#49454F",
  outline: "#79747E",
  shadow: "#000000",

  inverseSurface: "#313033",
  inverseOnSurface: "#F4EFF4",
  inversePrimary: "#D0BCFF"
};

var dark = {
  primary: "#D0BCFF",
  onPrimary: "#381E72",
  primaryContainer: "#4F378B",
  onPrimaryContainer: "#EADDFF",

  secondary: "#CCC2DC",
  onSecondary: "#332D41",
  secondaryContainer: "#4A4458",
  onSecondaryContainer: "#E8DEF8",

  tertiary: "#EFB8C8",
  onTertiary: "#492532",
  tertiaryContainer: "#633B48",
  onTertiaryContainer: "#FFD8E4",

  error: "#F2B8B5",
  onError: "#601410",
  errorContainer: "#8C1D18",
  onErrorContainer: "#F9DEDC",

  background: "#1C1B1F",
  onBackground: "#E6E1E5",
  surface: "#1C1B1F",
  onSurface: "#E6E1E5",
  surfaceVariant: "#49454F",
  onSurfaceVariant: "#CAC4D0",
  outline: "#938F99",
  shadow: "#000000",

  inverseSurface: "#E6E1E5",
  inverseOnSurface: "#313033",
  inversePrimary: "#6750A4"
};

function setDarkMode(darkMode) { isDark = !!darkMode; }
function toggleMode() { isDark = !isDark; }
function palette() { return isDark ? dark : light; }
function isDarkMode() { return isDark; }

// Optional direct tokens (static snapshot at load)
var primary = palette().primary;
var onPrimary = palette().onPrimary;


