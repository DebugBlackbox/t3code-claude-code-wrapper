#!/bin/bash
set -e

# --- Block domains via /etc/hosts ---
if [ -n "$BLOCKED_DOMAINS" ]; then
    IFS=',' read -ra _domains <<< "$BLOCKED_DOMAINS"
    for _domain in "${_domains[@]}"; do
        _domain=$(echo "$_domain" | xargs)
        [ -z "$_domain" ] && continue
        echo "0.0.0.0 ${_domain}" >> /etc/hosts
        echo "0.0.0.0 www.${_domain}" >> /etc/hosts
    done
fi

# --- Write Claude onboarding settings ---
_target_home=$([ "${RUN_AS_ROOT}" = "true" ] && echo /root || getent passwd "$RUN_USER" | cut -d: -f6)

if [ -n "$ANTHROPIC_API_KEY" ]; then
    mkdir -p "${_target_home}/.claude"
    printf '{"hasCompletedOnboarding":true,"theme":"dark"}' > "${_target_home}/.claude.json"
    printf '{"hasCompletedOnboarding":true,"theme":"dark"}' > "${_target_home}/.claude/settings.json"
    [ "${RUN_AS_ROOT}" != "true" ] && chown -R "${RUN_USER}:${RUN_USER}" "${_target_home}/.claude" "${_target_home}/.claude.json"
fi

# --- Drop privileges or stay root ---
if [ "${RUN_AS_ROOT}" = "true" ]; then
    exec "$@"
else
    exec gosu "$RUN_USER" "$@"
fi
