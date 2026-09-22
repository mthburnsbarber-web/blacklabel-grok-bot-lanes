#!/bin/bash
# MAC-APPLY-BRAND-ICONS-20260922.sh — RUN ON MAC (machineId 75ba8c96…)
# Patch LOCKED Black Label product icons into AppIcon / StoreLogo source trees.
# No xcodebuild / notarize / ASC submit.
set -euo pipefail
test "$(uname -s)" = Darwin || { echo "FATAL: not Darwin"; exit 78; }
command -v sips >/dev/null || { echo "FATAL: sips missing"; exit 78; }

HOME_U="${HOME:-/Users/michaelbarber}"
STATE="$HOME_U/BlackLabel-Team/STATE/brand-icons-20260922"
ASC="$STATE/derived/asc-1024"
BAK_TAG="bak-pre-brand-20260922"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
REPORT="$STATE/APPLY-REPORT-$(date +%Y%m%d-%H%M%S).txt"
exec > >(tee -a "$REPORT") 2>&1

echo "=== BRAND ICON APPLY $(date) host=$(hostname) ==="

# --- Resolve masters (prefer STATE locked names; fall back to Downloads) ---
resolve_master() {
  local product="$1"
  local state_name="$2"
  local dl_glob="$3"
  if [[ -f "$STATE/$state_name" ]]; then
    echo "$STATE/$state_name"
    return
  fi
  local hit
  hit=$(ls -1 $HOME_U/Downloads/$dl_glob 2>/dev/null | head -1 || true)
  if [[ -n "$hit" && -f "$hit" ]]; then
    echo "$hit"
    return
  fi
  echo ""
}

ACADEMY_SRC=$(resolve_master academy academy-icon.png "*academy*logo*.png")
MARKETING_SRC=$(resolve_master marketing marketing-icon.png "*marketing*logo*.png")
VIGIL_SRC=$(resolve_master vigil vigil-icon.png "*vigil*logo*.png")
RE_SRC=$(resolve_master realestate realestate-icon.png "*real*estate*icon*.png")
# Extra Downloads fallbacks from parent steering
[[ -z "$ACADEMY_SRC" ]] && ACADEMY_SRC=$(ls "$HOME_U/Downloads/academy logo.png" 2>/dev/null || true)
[[ -z "$MARKETING_SRC" ]] && MARKETING_SRC=$(ls "$HOME_U/Downloads/marketing logo.png" 2>/dev/null || true)
[[ -z "$VIGIL_SRC" ]] && VIGIL_SRC=$(ls "$HOME_U/Downloads/vigil logo.png" 2>/dev/null || true)
[[ -z "$RE_SRC" ]] && RE_SRC=$(ls "$HOME_U/Downloads/the real estate icon.png" 2>/dev/null || true)

echo "MASTER academy=$ACADEMY_SRC"
echo "MASTER marketing=$MARKETING_SRC"
echo "MASTER vigil=$VIGIL_SRC"
echo "MASTER realestate=$RE_SRC"
for m in "$ACADEMY_SRC" "$MARKETING_SRC" "$VIGIL_SRC" "$RE_SRC"; do
  [[ -n "$m" && -f "$m" ]] || { echo "FATAL: missing master: $m"; exit 78; }
done

mkdir -p "$ASC" "$STATE"
# Ensure STATE locked copies exist
cp -f "$ACADEMY_SRC" "$STATE/academy-icon.png"
cp -f "$MARKETING_SRC" "$STATE/marketing-icon.png"
cp -f "$VIGIL_SRC" "$STATE/vigil-icon.png"
cp -f "$RE_SRC" "$STATE/realestate-icon.png"
ACADEMY_SRC="$STATE/academy-icon.png"
MARKETING_SRC="$STATE/marketing-icon.png"
VIGIL_SRC="$STATE/vigil-icon.png"
RE_SRC="$STATE/realestate-icon.png"

# ASC 1024s (idempotent)
sips -z 1024 1024 "$ACADEMY_SRC" --out "$ASC/academy-1024.png" >/dev/null
sips -z 1024 1024 "$MARKETING_SRC" --out "$ASC/marketing-1024.png" >/dev/null
sips -z 1024 1024 "$VIGIL_SRC" --out "$ASC/vigil-1024.png" >/dev/null
sips -z 1024 1024 "$RE_SRC" --out "$ASC/realestate-1024.png" >/dev/null
echo "ASC masters:"
for f in academy marketing vigil realestate; do
  sips -g pixelWidth -g pixelHeight "$ASC/${f}-1024.png" 2>/dev/null | paste - - -
  ls -la "$ASC/${f}-1024.png"
done

backup_once() {
  local dir="$1"
  local bak="${dir}.${BAK_TAG}"
  if [[ -d "$dir" && ! -e "$bak" ]]; then
    cp -R "$dir" "$bak"
    echo "BACKUP $bak"
  else
    echo "BACKUP skip (exists or missing src): $bak"
  fi
}

# Parse pixel size for a Contents.json image entry + filename
# Prefer filename patterns; fall back to size * scale from JSON fields.
pixel_size_for() {
  local filename="$1"
  local size_field="$2"   # e.g. 20x20 or 83.5x83.5 or 1024x1024
  local scale_field="$3"  # 1x 2x 3x
  local w h scale base

  # @2x / @3x in filename
  scale=1
  if [[ "$filename" == *"@3x"* ]]; then scale=3
  elif [[ "$filename" == *"@2x"* ]]; then scale=2
  fi

  # icon_NNN.png or icon_NNNxNNN.png
  if [[ "$filename" =~ ([0-9]+\.?[0-9]*)x([0-9]+\.?[0-9]*) ]]; then
    base="${BASH_REMATCH[1]}"
    # if filename has @Nx, multiply; if size already includes scale in absolute px names like icon_1024, don't double
    if [[ "$filename" == *"@2x"* || "$filename" == *"@3x"* ]]; then
      python3 - <<PY
print(int(round(float("$base") * $scale)))
PY
      return
    else
      python3 - <<PY
print(int(round(float("$base"))))
PY
      return
    fi
  fi

  # icon_20.png style (no x)
  if [[ "$filename" =~ icon_([0-9]+\.?[0-9]*) ]]; then
    base="${BASH_REMATCH[1]}"
    python3 - <<PY
print(int(round(float("$base") * $scale)))
PY
    return
  fi

  # StoreLogo / Square / Wide windows names
  case "$filename" in
    StoreLogo.png) echo 50; return ;;
    Square44x44Logo.png) echo 44; return ;;
    Square71x71Logo.png) echo 71; return ;;
    Square150x150Logo.png) echo 150; return ;;
    Square310x310Logo.png) echo 310; return ;;
    Wide310x150Logo.png) echo "310x150"; return ;;
  esac

  # Fall back to Contents size * scale
  if [[ -n "$size_field" ]]; then
    base="${size_field%%x*}"
    sc=1
    case "$scale_field" in
      3x) sc=3 ;;
      2x) sc=2 ;;
      *) sc=1 ;;
    esac
    python3 - <<PY
print(int(round(float("$base") * $sc)))
PY
    return
  fi
  echo ""
}

regen_appiconset() {
  local setdir="$1"
  local master="$2"
  local label="$3"
  if [[ ! -d "$setdir" ]]; then
    echo "SKIP missing $setdir"
    return
  fi
  backup_once "$setdir"
  local contents="$setdir/Contents.json"
  if [[ ! -f "$contents" ]]; then
    echo "WARN no Contents.json in $setdir — replacing any pngs present"
    for png in "$setdir"/*.png; do
      [[ -f "$png" ]] || continue
      local bn=$(basename "$png")
      local px
      px=$(pixel_size_for "$bn" "" "")
      if [[ "$px" == *x* ]]; then
        local ww=${px%x*} hh=${px#*x}
        sips -z "$hh" "$ww" "$master" --out "$TMP/$bn" >/dev/null
      elif [[ -n "$px" ]]; then
        sips -z "$px" "$px" "$master" --out "$TMP/$bn" >/dev/null
      else
        # keep same dimensions as existing
        local ow oh
        ow=$(sips -g pixelWidth "$png" 2>/dev/null | awk '/pixelWidth/{print $2}')
        oh=$(sips -g pixelHeight "$png" 2>/dev/null | awk '/pixelHeight/{print $2}')
        sips -z "$oh" "$ow" "$master" --out "$TMP/$bn" >/dev/null
      fi
      local before after
      before=$(stat -f%z "$png")
      mv -f "$TMP/$bn" "$png"
      after=$(stat -f%z "$png")
      echo "WRITE $label $png before=$before after=$after"
    done
    return
  fi

  python3 - <<PY
import json, os, re, subprocess, shutil
setdir = "$setdir"
master = "$master"
tmp = "$TMP"
label = "$label"
data = json.load(open(os.path.join(setdir, "Contents.json")))
updated = []
for img in data.get("images", []):
    fn = img.get("filename")
    if not fn:
        continue
    size = img.get("size") or ""
    scale = img.get("scale") or "1x"
    # determine pixels
    scale_n = 1
    if scale.endswith("x"):
        try: scale_n = int(scale[:-1])
        except: scale_n = 1
    # filename @Nx overrides
    if "@3x" in fn: scale_n = 3
    elif "@2x" in fn: scale_n = 2
    w = h = None
    m = re.search(r"(\\d+\\.?\\d*)x(\\d+\\.?\\d*)", fn)
    if m:
        base_w = float(m.group(1)); base_h = float(m.group(2))
        if "@2x" in fn or "@3x" in fn:
            w = int(round(base_w * scale_n)); h = int(round(base_h * scale_n))
        else:
            w = int(round(base_w)); h = int(round(base_h))
    else:
        m2 = re.search(r"icon_(\\d+\\.?\\d*)", fn)
        if m2:
            base = float(m2.group(1))
            w = h = int(round(base * scale_n))
        elif size:
            parts = size.lower().split("x")
            base_w = float(parts[0]); base_h = float(parts[1]) if len(parts)>1 else base_w
            w = int(round(base_w * scale_n)); h = int(round(base_h * scale_n))
        else:
            # probe existing
            path = os.path.join(setdir, fn)
            if os.path.exists(path):
                out = subprocess.check_output(["sips","-g","pixelWidth","-g","pixelHeight",path], text=True)
                ww = hh = None
                for line in out.splitlines():
                    if "pixelWidth" in line: ww=int(line.split()[-1])
                    if "pixelHeight" in line: hh=int(line.split()[-1])
                w, h = ww, hh
    if not w or not h:
        print(f"SKIP unparsed {fn}")
        continue
    outp = os.path.join(tmp, fn.replace("/","_"))
    subprocess.check_call(["sips","-z",str(h),str(w),master,"--out",outp], stdout=subprocess.DEVNULL)
    dest = os.path.join(setdir, fn)
    before = os.path.getsize(dest) if os.path.exists(dest) else 0
    shutil.move(outp, dest)
    after = os.path.getsize(dest)
    print(f"WRITE {label} {dest} {w}x{h} before={before} after={after}")
    updated.append(dest)
print(f"DONE {label} count={len(updated)}")
PY
}

regen_windows_assets() {
  local assets_dir="$1"
  local master="$2"
  local label="$3"
  if [[ ! -d "$assets_dir" ]]; then
    echo "SKIP windows missing $assets_dir"
    return
  fi
  backup_once "$assets_dir"
  declare -A MAP=(
    [StoreLogo.png]="50x50"
    [Square44x44Logo.png]="44x44"
    [Square71x71Logo.png]="71x71"
    [Square150x150Logo.png]="150x150"
    [Square310x310Logo.png]="310x310"
    [Wide310x150Logo.png]="310x150"
  )
  for name in "${!MAP[@]}"; do
    local target="$assets_dir/$name"
    [[ -f "$target" || -d "$assets_dir" ]] || continue
    local dim=${MAP[$name]}
    local ww=${dim%x*} hh=${dim#*x}
    sips -z "$hh" "$ww" "$master" --out "$TMP/$name" >/dev/null
    local before=0
    [[ -f "$target" ]] && before=$(stat -f%z "$target")
    mv -f "$TMP/$name" "$target"
    local after=$(stat -f%z "$target")
    echo "WRITE $label $target ${ww}x${hh} before=$before after=$after"
  done
  # Also refresh any other pngs present at their current dims
  for png in "$assets_dir"/*.png; do
    [[ -f "$png" ]] || continue
    bn=$(basename "$png")
    [[ -n "${MAP[$bn]+x}" ]] && continue
    ow=$(sips -g pixelWidth "$png" 2>/dev/null | awk '/pixelWidth/{print $2}')
    oh=$(sips -g pixelHeight "$png" 2>/dev/null | awk '/pixelHeight/{print $2}')
    sips -z "$oh" "$ow" "$master" --out "$TMP/$bn" >/dev/null
    before=$(stat -f%z "$png")
    mv -f "$TMP/$bn" "$png"
    after=$(stat -f%z "$png")
    echo "WRITE $label $png ${ow}x${oh} before=$before after=$after"
  done
}

echo "=== KNOWN APPICONSETS ==="
# 1 Academy iOS
regen_appiconset "$HOME_U/BlackLabelAcademy/ios/Resources/Assets.xcassets/AppIcon.appiconset" "$ACADEMY_SRC" "academy-ios"
# Academy Mac (any)
while IFS= read -r d; do
  regen_appiconset "$d" "$ACADEMY_SRC" "academy-mac"
done < <(find "$HOME_U/BlackLabelAcademy" -type d -name 'AppIcon.appiconset' 2>/dev/null | grep -v ios/Resources | grep -v "$BAK_TAG" || true)

# 2 Marketing Mac
regen_appiconset "$HOME_U/BlackLabelMarketing/Sources/Assets.xcassets/AppIcon.appiconset" "$MARKETING_SRC" "marketing-mac"
# Marketing iOS if present
[[ -d "$HOME_U/BlackLabelMarketing/Sources/Assets.xcassets/AppIconiOS.appiconset" ]] && \
  regen_appiconset "$HOME_U/BlackLabelMarketing/Sources/Assets.xcassets/AppIconiOS.appiconset" "$MARKETING_SRC" "marketing-ios"

# 3 Real Estate Mac
regen_appiconset "$HOME_U/BlackLabelRealEstate/Sources/Assets.xcassets/AppIcon.appiconset" "$RE_SRC" "realestate-mac"

# 4 Vigil / Home iOS
regen_appiconset "$HOME_U/BlackLabelHome/ios/Assets.xcassets/AppIcon.appiconset" "$VIGIL_SRC" "vigil-ios"
# Home Mac AppIcons
while IFS= read -r d; do
  regen_appiconset "$d" "$VIGIL_SRC" "vigil-mac"
done < <(find "$HOME_U/BlackLabelHome" -type d -name 'AppIcon.appiconset' 2>/dev/null | grep -v '/ios/' | grep -v "$BAK_TAG" || true)

echo "=== WINDOWS MSIX ASSETS ==="
# Real Estate known
regen_windows_assets "$HOME_U/BlackLabelRealEstate/windows/msix/Assets" "$RE_SRC" "re-msix"
regen_windows_assets "$HOME_U/BlackLabelRealEstate/windows/msix-layout/Assets" "$RE_SRC" "re-msix-layout"

# Discover other windows Assets for academy/marketing/vigil/homefront
while IFS= read -r d; do
  case "$d" in
    *RealEstate*) continue ;; # already done
    *[Aa]cademy*) regen_windows_assets "$d" "$ACADEMY_SRC" "academy-win" ;;
    *[Mm]arketing*) regen_windows_assets "$d" "$MARKETING_SRC" "marketing-win" ;;
    *[Vv]igil*|*Home*|*[Hh]omefront*) regen_windows_assets "$d" "$VIGIL_SRC" "vigil-win" ;;
  esac
done < <(find "$HOME_U/BlackLabelAcademy" "$HOME_U/BlackLabelMarketing" "$HOME_U/BlackLabelHome" "$HOME_U/BlackLabelRealEstate" \
  -type d \( -path '*/msix/Assets' -o -path '*/msix-layout/Assets' -o -path '*/windows/*/Assets' \) 2>/dev/null | sort -u)

echo "=== PIXEL PROOF MASTERS ==="
for pair in "academy:$ACADEMY_SRC:$ASC/academy-1024.png" "marketing:$MARKETING_SRC:$ASC/marketing-1024.png" "vigil:$VIGIL_SRC:$ASC/vigil-1024.png" "realestate:$RE_SRC:$ASC/realestate-1024.png"; do
  IFS=: read -r name src asc <<<"$pair"
  echo "-- $name"
  sips -g pixelWidth -g pixelHeight "$src" 2>/dev/null | paste - -
  sips -g pixelWidth -g pixelHeight "$asc" 2>/dev/null | paste - -
  shasum -a 256 "$src" "$asc"
done

echo "=== REPORT FILE $REPORT ==="
echo SUCCESS
