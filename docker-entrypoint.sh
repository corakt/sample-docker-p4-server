#!/usr/bin/env sh
set -eu

# 変数
NAME="${NAME:-master}"
P4PORT="${P4PORT:-1666}"
P4D_SUPER="${P4D_SUPER:-admin}"
P4ROOT="/opt/perforce/servers/${NAME}"
LOG="${P4ROOT}/logs/log"

# 初回起動判定
if [ ! -f "${P4ROOT}/root/db.counters" ]; then
  echo "[INFO] First-time configure for '${NAME}'"

  # パスワード取得
  if [ -f /run/secrets/P4D_SUPER_PASSWD ]; then
    P4D_SUPER_PASSWD="$(cat /run/secrets/P4D_SUPER_PASSWD)"
  else
    echo "[ERROR] /run/secrets/P4D_SUPER_PASSWD not found" >&2
    exit 2
  fi

  # インスタンス作成
  /opt/perforce/sbin/configure-p4d.sh \
    "${NAME}" \
    -p "${P4PORT}" \
    -r "${P4ROOT}" \
    -u "${P4D_SUPER}" \
    -P "${P4D_SUPER_PASSWD}" \
    --unicode -n
else
  echo "[INFO] '${NAME}' already configured. Skipping configure."
fi

# 開始
p4dctl start "${NAME}"

if [ "${1:-start}" = "start" ]; then
  exec tail -F "${LOG}"
fi

exec "$@"