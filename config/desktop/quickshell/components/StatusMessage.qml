import QtQuick
import QtQuick.Layouts
import qs

Label {
  property bool ok: false

  visible: text !== ""
  color: ok ? Theme.textSuccess : Theme.textError
  wrapMode: Text.Wrap
  Layout.fillWidth: true
}
