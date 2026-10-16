pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: root
  property bool clock24h: true
  property bool showSeconds: false
  property string dateFormat: "ddd dd MMM"
  property bool dnd: false
  property string wallpaper: ""
  property string wallpaperFit: "fill"
  property string wallpaperDir: Quickshell.env("HOME") + "/Pictures"
  property var colors: ({})
  property string fontFamily: ""
  property string screenshotDir: Quickshell.env("HOME") + "/Pictures/Screenshots"
  property bool screenshotCopy: true
  property bool screenshotEdit: true
  property string keyboardLayout: ""
  property string keyboardVariant: ""
  property real fontScale: 1.0
  property bool loaded: false
  property bool migrated: false

  readonly property string timeFormat: (clock24h ? "HH:mm" : "h:mm") + (showSeconds ? ":ss" : "") + (clock24h ? "" : " AP")

  function save() {
    if (!loaded) return
    file.setText(JSON.stringify({ clock24h: clock24h, showSeconds: showSeconds, dateFormat: dateFormat, dnd: dnd, wallpaper: wallpaper, wallpaperFit: wallpaperFit, wallpaperDir: wallpaperDir, colors: colors, fontFamily: fontFamily, fontScale: fontScale, keyboardLayout: keyboardLayout, keyboardVariant: keyboardVariant, screenshotDir: screenshotDir, screenshotCopy: screenshotCopy, screenshotEdit: screenshotEdit, colorsVersion: colorsVersion }, null, 2))
  }

  onClock24hChanged: save()
  onShowSecondsChanged: save()
  onDateFormatChanged: save()
  onDndChanged: save()
  onWallpaperChanged: save()
  onWallpaperFitChanged: save()
  onWallpaperDirChanged: save()
  onColorsChanged: save()
  onFontFamilyChanged: save()
  onFontScaleChanged: save()
  onScreenshotDirChanged: save()
  onScreenshotCopyChanged: save()
  onScreenshotEditChanged: save()
  onKeyboardLayoutChanged: save()
  onKeyboardVariantChanged: save()

  // Color picks from before the token split: each old id fed several new tokens
  readonly property var legacyColors: ({
    fg: ["textBody", "textInput", "iconBody", "knob"],
    muted: ["textHint", "iconDim", "lineDivider"],
    accent: ["textSelected", "iconActive", "fillHighlight", "lineFocus"],
    bg: ["fillWindow", "textOnHighlight", "knobActive"],
    surface: ["fillCard"],
    hover: ["fillHover"],
    bright: ["textTitle", "fillMarker"],
    danger: ["textError", "iconAlert", "fillDanger"],
    warning: ["textWarning", "fillWarning"],
    success: ["textSuccess"],
    titleActive: ["titlebarActive"],
    titleInactive: ["titlebarInactive"],
    titleText: ["titlebarText"]
  })

  function migrateColors(map) {
    const out = {}
    let changed = false
    for (const key in map) {
      if (legacyColors[key]) {
        changed = true
        for (const id of legacyColors[key]) if (!(id in map)) out[id] = map[key]
      } else out[key] = map[key]
    }
    return { colors: out, changed: changed }
  }

  // Version 3 removed fillHighlight and textHighlight: today and the current workspace use the main color
  // Version 2 swapped fillHighlight and fillMarker names (the main color is now fillPrimary) and split textOnHighlight
  readonly property int colorsVersion: 3

  function renameV2(map) {
    const out = {}
    for (const key in map) {
      if (key === "fillHighlight") out.fillPrimary = map[key]
      else if (key === "fillMarker") out.fillHighlight = map[key]
      else if (key === "textOnHighlight") { out.textPrimary = map[key]; out.textHighlight = map[key] }
      else out[key] = map[key]
    }
    return out
  }

  function dropV3(map) {
    const out = {}
    for (const key in map) if (key !== "fillHighlight" && key !== "textHighlight") out[key] = map[key]
    return out
  }

  function setColor(id, slot) {
    const next = Object.assign({}, colors)
    if (slot) next[id] = slot; else delete next[id]
    colors = next
  }

  FileView {
    id: file
    path: Quickshell.env("QS_PREFS") || (Quickshell.env("HOME") + "/.config/quickshell/prefs.json")
    atomicWrites: true
    onLoaded: {
      try {
        const data = JSON.parse(text())
        if (data.clock24h !== undefined) root.clock24h = data.clock24h
        if (data.showSeconds !== undefined) root.showSeconds = data.showSeconds
        if (data.dateFormat) root.dateFormat = data.dateFormat
        if (data.dnd !== undefined) root.dnd = data.dnd
        if (data.wallpaper !== undefined) root.wallpaper = data.wallpaper
        if (data.wallpaperFit) root.wallpaperFit = data.wallpaperFit
        if (data.wallpaperDir) root.wallpaperDir = data.wallpaperDir
        if (data.colors && typeof data.colors === "object") {
          const migrated = root.migrateColors(data.colors)
          let picks = migrated.colors
          let changed = migrated.changed
          const from = data.colorsVersion || 0
          if (from < 2) picks = root.renameV2(picks)
          if (from < 3) picks = root.dropV3(picks)
          if (from < root.colorsVersion) changed = true
          root.colors = picks
          if (changed) root.migrated = true
        }
        if (typeof data.fontFamily === "string") root.fontFamily = data.fontFamily
        if (data.fontScale > 0) root.fontScale = data.fontScale
        if (data.screenshotDir) root.screenshotDir = data.screenshotDir
        if (data.screenshotCopy !== undefined) root.screenshotCopy = data.screenshotCopy
        if (data.screenshotEdit !== undefined) root.screenshotEdit = data.screenshotEdit
        if (typeof data.keyboardLayout === "string") root.keyboardLayout = data.keyboardLayout
        if (typeof data.keyboardVariant === "string") root.keyboardVariant = data.keyboardVariant
      } catch (e) {}
      root.loaded = true
      if (root.migrated) root.save()
    }
    onLoadFailed: root.loaded = true
  }
}
