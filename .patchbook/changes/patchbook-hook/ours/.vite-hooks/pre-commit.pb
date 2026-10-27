# patchbook: record hand edits to the build output and rebuild it, before the checks below. Skip it once with PATCHBOOK_HOOK=0 git commit
if [ "$PATCHBOOK_HOOK" != 0 ] && [ -f .patchbook/config.toml ]; then
  if ! command -v patchbook >/dev/null; then
    echo "patchbook isn't installed, so this commit can't record hand edits to the build output." >&2
    echo "Install it with npm install -g @patchbook/cli, or skip it once with PATCHBOOK_HOOK=0 git commit" >&2
    exit 1
  fi
  patchbook hook run || exit 1
fi

vp staged
