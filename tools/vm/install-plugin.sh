#!/usr/bin/env bash
# Внутри виртуалки: ставит Skindancer так, как велит README (клон прямо в папку плагинов DMS),
# и включает плагин тем же флагом, что и переключатель в настройках DMS.
# Репозиторий приходит бандлом /tmp/skindancer.bundle; если рядом лежит /tmp/oboi-helper,
# он кладётся в bin до включения плагина (как скачанный из релиза).
set -euxo pipefail
P=~/.config/dms/plugins
mkdir -p "$P"
rm -rf "$P/oboi" "$P/skindancer"
git clone -q /tmp/skindancer.bundle "$P/skindancer"
[ -f /tmp/oboi-helper ] && install -m 755 /tmp/oboi-helper "$P/skindancer/bin/oboi-helper"
python3 - <<'P'
import json, os
p = os.path.expanduser("~/.config/dms/plugin_settings.json")
d = json.load(open(p)) if os.path.exists(p) else {}
d.pop("oboi", None)
d.setdefault("skindancer", {})["enabled"] = True
json.dump(d, open(p, "w"), indent=2)
P
rm -rf ~/.cache/oboi
systemctl --user restart dms; sleep 8
dms plugins list 2>&1 | grep -i skindancer || true
