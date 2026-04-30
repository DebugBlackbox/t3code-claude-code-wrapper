#!/bin/bash
set -e

# Block domains via /etc/hosts — runs as root before privilege drop
if [ -n "$BLOCKED_DOMAINS" ]; then
    IFS=',' read -ra _domains <<< "$BLOCKED_DOMAINS"
    for _domain in "${_domains[@]}"; do
        _domain=$(echo "$_domain" | xargs)
        [ -z "$_domain" ] && continue
        echo "0.0.0.0 ${_domain}" >> /etc/hosts
        echo "0.0.0.0 www.${_domain}" >> /etc/hosts
    done
fi

# Write Claude onboarding settings to the target user's home
_home=$([ "${RUN_USER}" = "root" ] && echo /root || echo "/home/${RUN_USER}")
if [ -n "$ANTHROPIC_API_KEY" ]; then
    mkdir -p "${_home}/.claude"
    printf '{"hasCompletedOnboarding":true,"theme":"dark"}' > "${_home}/.claude.json"
    printf '{"hasCompletedOnboarding":true,"theme":"dark"}' > "${_home}/.claude/settings.json"
    [ "${RUN_USER}" != "root" ] && chown -R "${RUN_USER}:${RUN_USER}" "${_home}/.claude" "${_home}/.claude.json"
fi

exec gosu "${RUN_USER}" "$@"
