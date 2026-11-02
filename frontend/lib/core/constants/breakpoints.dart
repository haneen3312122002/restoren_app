// Screen widths where the layout changes (used with LayoutBuilder).
class Breakpoints {
  const Breakpoints._();

  // smaller than this = phone (one column):
  static const double tablet = 600;

  // this or wider = laptop (cart as a side panel instead of a drawer).
  static const double desktop = 900;

  // max width for forms so they don't stretch across the whole screen.
  static const double formMaxWidth = 560;

  // true if the width is a laptop width:
  static bool isDesktop(double width) => width >= desktop;

  // number of product grid columns for the available width:
  static int gridColumns(double width) {
    if (width < tablet) return 1;
    if (width < 1100) return 2;
    return 3;
  }
}
