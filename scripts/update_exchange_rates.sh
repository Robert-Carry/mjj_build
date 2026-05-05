#!/usr/bin/env bash
set -euo pipefail

JSON_FILE="exchange_rates.json"

if [[ -z "${CURRENCYBEACON_API_URL:-}" ]]; then
  echo "CURRENCYBEACON_API_URL 未设置" >&2
  exit 1
fi

API_URL="$CURRENCYBEACON_API_URL"

echo "获取最新汇率数据..."
RATES_JSON=$(curl -sS --fail "$API_URL")

CURRENT_DATE=$(TZ=Asia/Shanghai date '+%Y-%m-%d %H:%M GMT+8')

FORMATTED_JSON=$(echo "$RATES_JSON" | jq -r --arg date "$CURRENT_DATE" '
{
  date: $date,
  rates: (.rates | to_entries | sort_by(.key) | map({
    (.key): (if .value != 0 then
              ((1 / .value) * 100000 | round) / 100000
             else 0 end)
  }) | add)
}
')

echo "$FORMATTED_JSON" > "$JSON_FILE"

echo "汇率文件更新完成: $JSON_FILE"
