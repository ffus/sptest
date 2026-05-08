#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME="${0##*/}"
OOKLA_VERSION="${OOKLA_VERSION:-1.2.0}"
BIN_DIR="${BIN_DIR:-/usr/local/bin}"
INSTALL_MARKER="${BIN_DIR}/.speedtest-ookla-installed-by-${SCRIPT_NAME}"
SPEEDTEST_CMD=""
SPEEDTEST_ARGS=()

COLOR_RED=$'\033[31m'
COLOR_GREEN=$'\033[32m'
COLOR_YELLOW=$'\033[33m'
COLOR_BLUE=$'\033[34m'
COLOR_RESET=$'\033[0m'

OS_ID=""
TMP_DIR=""

usage() {
    cat <<EOF
Usage:
  ${SCRIPT_NAME}                 Install if needed, then run Ookla Speedtest
  ${SCRIPT_NAME} [speedtest args] Pass arguments to speedtest
  ${SCRIPT_NAME} -- [args...]     Pass arguments to speedtest when args start with '-u'
  ${SCRIPT_NAME} -u|--uninstall   Uninstall Speedtest installed by this script
  ${SCRIPT_NAME} -h|--help        Show this help

Environment:
  OOKLA_VERSION=${OOKLA_VERSION}  Version used for direct tgz install
  BIN_DIR=${BIN_DIR}              Directory used for direct tgz install
  SPTEST_SERVER_ID=12345          Force a Speedtest server id
  SPTEST_INTERFACE=eth0           Bind test traffic to an interface
  SPTEST_IP=1.2.3.4               Bind test traffic to a local IP address

Alpine Linux needs bash first, for example:
  apk add --no-cache bash
EOF
}

info() {
    printf '%s%s%s\n' "${COLOR_BLUE}" "$*" "${COLOR_RESET}"
}

warn() {
    printf '%s%s%s\n' "${COLOR_YELLOW}" "$*" "${COLOR_RESET}" >&2
}

success() {
    printf '%s%s%s\n' "${COLOR_GREEN}" "$*" "${COLOR_RESET}"
}

die() {
    printf '%sERROR: %s%s\n' "${COLOR_RED}" "$*" "${COLOR_RESET}" >&2
    exit 1
}

have() {
    command -v "$1" >/dev/null 2>&1
}

run_as_root() {
    if (( EUID == 0 )); then
        "$@"
    elif have sudo; then
        sudo "$@"
    else
        die "This action needs root privileges. Re-run as root or install sudo."
    fi
}

cleanup() {
    if [[ -n "${TMP_DIR}" && -d "${TMP_DIR}" ]]; then
        rm -rf "${TMP_DIR}"
    fi
}
trap cleanup EXIT

load_os_release() {
    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        OS_ID="${ID:-}"
    fi
}

is_alpine() {
    [[ "${OS_ID}" == "alpine" ]] || have apk
}

make_tmp_dir() {
    if [[ -z "${TMP_DIR}" ]]; then
        TMP_DIR="$(mktemp -d)"
    fi
}

download() {
    local url="$1"
    local out="$2"

    if have curl; then
        curl -fsSL "${url}" -o "${out}"
    elif have wget; then
        wget -qO "${out}" "${url}"
    else
        die "curl or wget is required to download ${url}"
    fi
}

speedtest_is_ookla() {
    local bin="$1"
    local output=""

    [[ -x "${bin}" ]] || return 1

    output="$("${bin}" -V 2>&1 || true)"
    [[ "${output}" == *Ookla* ]] && return 0

    output="$("${bin}" --version 2>&1 || true)"
    [[ "${output}" == *Ookla* ]]
}

find_ookla_speedtest() {
    local cmd=""

    if have speedtest; then
        cmd="$(command -v speedtest)"
        if speedtest_is_ookla "${cmd}"; then
            printf '%s\n' "${cmd}"
            return 0
        fi
    fi

    if [[ -x "${BIN_DIR}/speedtest" ]] && speedtest_is_ookla "${BIN_DIR}/speedtest"; then
        printf '%s\n' "${BIN_DIR}/speedtest"
        return 0
    fi

    return 1
}

detect_ookla_arch() {
    case "$(uname -m)" in
        x86_64|amd64)
            printf 'x86_64\n'
            ;;
        i386|i486|i586|i686)
            printf 'i386\n'
            ;;
        aarch64|arm64)
            printf 'aarch64\n'
            ;;
        armv7l|armv7*|armhf)
            printf 'armhf\n'
            ;;
        armv6l|armv5*|armel)
            printf 'armel\n'
            ;;
        *)
            die "Unsupported CPU architecture: $(uname -m)"
            ;;
    esac
}

write_install_marker() {
    local url="$1"
    local content

    content="installed_by=${SCRIPT_NAME}
version=${OOKLA_VERSION}
url=${url}
"

    printf '%s' "${content}" | run_as_root tee "${INSTALL_MARKER}" >/dev/null
}

runtime_dependencies_ready() {
    { have curl || have wget; } && have tar && have gzip
}

install_runtime_dependencies() {
    if is_alpine; then
        run_as_root apk add --no-cache bash ca-certificates curl tar gzip libstdc++
        run_as_root apk add --no-cache gcompat >/dev/null 2>&1 || \
            warn "gcompat is not available from apk; continuing because the Speedtest binary may not need it."
        if have update-ca-certificates; then
            run_as_root update-ca-certificates >/dev/null 2>&1 || true
        fi
        return 0
    fi

    if runtime_dependencies_ready; then
        return 0
    fi

    if have apt-get; then
        run_as_root apt-get update
        run_as_root apt-get install -y ca-certificates curl tar gzip
    elif have dnf; then
        run_as_root dnf install -y ca-certificates curl tar gzip
    elif have yum; then
        run_as_root yum install -y ca-certificates curl tar gzip
    elif have zypper; then
        run_as_root zypper --non-interactive install ca-certificates curl tar gzip
    fi

    runtime_dependencies_ready || die "curl or wget, tar, and gzip are required to install the Ookla binary package."
}

install_speedtest_tgz() {
    local arch url archive extracted_bin

    make_tmp_dir
    arch="$(detect_ookla_arch)"
    url="https://install.speedtest.net/app/cli/ookla-speedtest-${OOKLA_VERSION}-linux-${arch}.tgz"
    archive="${TMP_DIR}/ookla-speedtest.tgz"
    extracted_bin="${TMP_DIR}/speedtest"

    info "Installing Ookla Speedtest from the official Linux ${arch} tgz package..."
    install_runtime_dependencies

    download "${url}" "${archive}"
    tar -xzf "${archive}" -C "${TMP_DIR}"

    [[ -x "${extracted_bin}" ]] || die "Downloaded package did not contain an executable speedtest binary."

    run_as_root mkdir -p "${BIN_DIR}"
    run_as_root install -m 0755 "${extracted_bin}" "${BIN_DIR}/speedtest"
    if ! speedtest_is_ookla "${BIN_DIR}/speedtest"; then
        if is_alpine; then
            die "Installed binary cannot run on this Alpine system. Try installing compatibility packages: apk add --no-cache gcompat libstdc++"
        fi
        die "Installed binary cannot run on this system."
    fi
    write_install_marker "${url}"

    case ":${PATH}:" in
        *":${BIN_DIR}:"*) ;;
        *) warn "${BIN_DIR} is not in PATH. This run will use ${BIN_DIR}/speedtest directly." ;;
    esac
}

ensure_speedtest() {
    if SPEEDTEST_CMD="$(find_ookla_speedtest)"; then
        info "Using existing Ookla Speedtest: ${SPEEDTEST_CMD}"
        return 0
    fi

    if have speedtest; then
        warn "Found a speedtest command that is not Ookla's official CLI: $(command -v speedtest)"
        warn "Installing the official Ookla Speedtest CLI."
    fi

    install_speedtest_tgz

    hash -r || true
    SPEEDTEST_CMD="$(find_ookla_speedtest)" || die "Speedtest installation finished, but the official Ookla CLI was not found."
}

uninstall_speedtest() {
    local removed=0

    if [[ -f "${INSTALL_MARKER}" ]]; then
        run_as_root rm -f "${BIN_DIR}/speedtest" "${INSTALL_MARKER}"
        removed=1
    fi

    if (( removed == 1 )); then
        success "Ookla Speedtest uninstalled."
    else
        success "No Ookla Speedtest installation from this script was detected."
        if have speedtest; then
            warn "A speedtest command still exists at $(command -v speedtest); it was not removed because it was not installed by this script."
        fi
    fi
}

args_contain_server_id() {
    local arg

    for arg in "$@"; do
        case "${arg}" in
            -s|--server-id|--server-id=*)
                return 0
                ;;
        esac
    done

    return 1
}

args_contain_interface() {
    local arg

    for arg in "$@"; do
        case "${arg}" in
            -I|--interface|--interface=*)
                return 0
                ;;
        esac
    done

    return 1
}

args_contain_ip() {
    local arg

    for arg in "$@"; do
        case "${arg}" in
            -i|--ip|--ip=*)
                return 0
                ;;
        esac
    done

    return 1
}

build_speedtest_args() {
    local args=("$@")

    SPEEDTEST_ARGS=(--accept-license --accept-gdpr)

    if [[ -n "${SPTEST_SERVER_ID:-}" ]] && ! args_contain_server_id "${args[@]}"; then
        SPEEDTEST_ARGS+=(--server-id "${SPTEST_SERVER_ID}")
    fi

    if [[ -n "${SPTEST_INTERFACE:-}" ]] && ! args_contain_interface "${args[@]}"; then
        SPEEDTEST_ARGS+=(--interface "${SPTEST_INTERFACE}")
    fi

    if [[ -n "${SPTEST_IP:-}" ]] && ! args_contain_ip "${args[@]}"; then
        SPEEDTEST_ARGS+=(--ip "${SPTEST_IP}")
    fi

    SPEEDTEST_ARGS+=("${args[@]}")
}

run_speedtest() {
    local args=("$@")
    local status=0

    ensure_speedtest
    build_speedtest_args "${args[@]}"
    info "Running Ookla Speedtest..."
    "${SPEEDTEST_CMD}" "${SPEEDTEST_ARGS[@]}" || status=$?

    if (( status != 0 )); then
        warn "Ookla Speedtest exited with status ${status}. The CLI was installed and started correctly, but the test failed during network I/O."
        warn "Try another server with: ${SCRIPT_NAME} -- --servers, then ${SCRIPT_NAME} -- --server-id <id>"
        warn "You can also pin a working server with: SPTEST_SERVER_ID=<id> ${SCRIPT_NAME}"
        warn "If this runs inside a container/VPS, also check outbound firewall rules, IPv6 routing, and container network mode."
        return "${status}"
    fi
}

main() {
    load_os_release

    case "${1:-}" in
        -h|--help)
            usage
            ;;
        -u|--uninstall)
            uninstall_speedtest
            ;;
        --)
            shift
            run_speedtest "$@"
            ;;
        *)
            run_speedtest "$@"
            ;;
    esac
}

main "$@"
