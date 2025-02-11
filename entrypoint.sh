#!/bin/bash
set -e

if [ -d "/usr/local/share/ca-certificates" ] && [ "$(ls -A /usr/local/share/ca-certificates)" ]; then
  echo "Updating CA certificates..."
  update-ca-certificates
fi

if [ "$#" -eq 0 ]; then
  declare -a COMMAND

  if [ "${VERBOSE,,}" != "false" ]; then
    COMMAND[${#COMMAND[@]}]="-verbose"
  fi

  if [ "${NO_HOT_RELOAD,,}" != "true" ]; then
    COMMAND[${#COMMAND[@]}]="-hotreload"
  fi

  COMMAND[${#COMMAND[@]}]="-hooks"
  COMMAND[${#COMMAND[@]}]="${HOOK_FILE:-hooks.yml}"

  if [ "${HOOK_IS_TEMPLATE,,}" == "true" ]; then
    COMMAND[${#COMMAND[@]}]="-template"
  fi

  header_number=1
  while true; do
    header_name="HEADER_${header_number}"
    if [ -z "${!header_name}" ]; then
        break
    fi

    COMMAND[${#COMMAND[@]}]="-header"
    COMMAND[${#COMMAND[@]}]="${!header_name}"

    ((header_number++))
  done

  if [ -n "${CERT_FILE}" ] && [ -n "${KEY_FILE}" ]; then
    COMMAND[${#COMMAND[@]}]="-cert"
    COMMAND[${#COMMAND[@]}]="${CERT_FILE}"

    COMMAND[${#COMMAND[@]}]="-key"
    COMMAND[${#COMMAND[@]}]="${KEY_FILE}]"
  fi

  if [ -n "${TLS_MIN_VERSION}" ]; then
    COMMAND[${#COMMAND[@]}]="-tls-min-version"
    COMMAND[${#COMMAND[@]}]="${TLS_MIN_VERSION}"
  fi

  if [ -n "${URL_PREFIX}" ]; then
    COMMAND[${#COMMAND[@]}]="-urlprefix"
    COMMAND[${#COMMAND[@]}]="${URL_PREFIX}"
  fi

  if [ "${SECURE,,}" == "true" ]; then
    COMMAND[${#COMMAND[@]}]="-secure"
  fi

  if [ -n "${ALLOWED_HTTP_METHODS}" ]; then
    COMMAND[${#COMMAND[@]}]="-http-methods"
    COMMAND[${#COMMAND[@]}]="${ALLOWED_HTTP_METHODS}"
  fi

  if [ -n "${PORT}" ]; then
    COMMAND[${#COMMAND[@]}]="-port"
    COMMAND[${#COMMAND[@]}]="${PORT}"
  fi

  if [ -n "${X_REQUEST_ID}" ]; then
    COMMAND[${#COMMAND[@]}]="-x-request-id"
    COMMAND[${#COMMAND[@]}]="${X_REQUEST_ID}"
  fi

  if [ -n "${X_REQUEST_ID_LIMIT}" ]; then
    COMMAND[${#COMMAND[@]}]="-x-request-id-limit"
    COMMAND[${#COMMAND[@]}]="${X_REQUEST_ID_LIMIT}"
  fi
else
  echo "Using provided arguments..."
  echo
  COMMAND=("$@")
fi

exec /sbin/tini -- /usr/local/bin/webhook "${COMMAND[@]}"
