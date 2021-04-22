#!/usr/bin/env bash
#
# Batch Rename - Edit multiple file names using the text editor.
# Output target file names to temporary files and open it by the text editor.
# After close the file, rename target files based on it.

readonly VERSION="0.1.0"
readonly FIND_EXCLUDE="-regextype posix-egrep ! -regex '[\.]{1,2}'"
readonly LOCKFILE="${TMP}/batch-rename.lock"
readonly FIFOFILE="${TMP}/batch-rename.pipe"

set -u -o pipefail

usage() {
  cat <<_EOT_
Batch Rename version ${VERSION}
Usage: ${0} [OPTIONS]... [--] [FILE]...
Edit the name of FILE(s) at once using the text editor.

Options:
  -e, --editor=EDITOR   use EDITOR
  -d                    edit files in directories
  -f, --force           do not prompt before overwriting
  -n, --no-clobber      do not overwrite an existing file
  -r, --recursive       edit directory recursively
  -v, --verbose         explain what is being done
  -w, --wait=SECONDS    wait SECONDS to receive path from other process.
  -h, --help            display this help and exit
  -V, --version         output version information and exit
  --                    Assign any remaining arguments to FILE(s).
                        OPTION(s) should be set before this.
_EOT_
  exit 1
}

error() {
  echo $* 1>&2
  exit 1
}

# Delete garbage files at teardown
garbage_files=()
teardown() {
  rm -rf "${garbage_files[@]}"
}

dry_run() {
  echo "rename \"${1}\" -> \"${2}\""
}

ipc() {
  if [[ "${seconds}" -gt 0 ]]; then
    if (set -o noclobber; echo "$$" > "${LOCKFILE}") 2> /dev/null; then
      # Receive FILE(s) from other processes
      garbage_files+=("${LOCKFILE}")
      mkfifo "${FIFOFILE}" && garbage_files+=("${FIFOFILE}")
      while timeout "${seconds}" cat "${FIFOFILE}"; do
        :
      done
      rm -rf "${LOCKFILE}" "${FIFOFILE}"
    else
      # Send FILE(s) to the reader process
      while [[ -e "${LOCKFILE}" ]] && [[ ! -e "${FIFOFILE}" ]]; do
        :   # Wait for the FIFOFILE create
      done
      cat - > "${FIFOFILE}"
    fi
  fi
  cat -
}

while getopts ed:fhnrvw:V-: opt; do
  optarg="${OPTARG}"
  [[ "${opt}" == "-" ]] \
    && opt="-${OPTARG%%=*}" \
    && optarg="${OPTARG/${OPTARG%%=*}/}" \
    && optarg="${optarg#=}"
  case "-${opt}" in
    -e|--editor)      EDITOR=${optarg} ;;
    -d)               find_opts="-mindepth 1 -maxdepth 1" ;;
    -f|--force)       mv_opts="-f" ;;
    -n|--no-clobber)  mv_opts="-n" ;;
    -r|--recursive)   find_opts="" ;;
    -x|--dry-run)     readonly xflag=true ;;
    -v|--verbose)     readonly vflag=true ;;
    -w|--wait)
      [[ "${optarg}" -gt 0 ]] \
        && seconds=${optarg} \
        || error "Unexpected SECONDS '${optarg}'"
      ;;
    -V|--version)     echo ${VERSION} ;;
    --)               break ;;
    -h|--help)        usage ;;
    -\?)              usage ;;
    --*)              usage ;;
  esac
done
shift $((OPTIND - 1))

[[ "$#" -gt 0 ]] || usage
"${vflag:-false}" || readonly mv_opts="${mv_opts:-} -v"
"${xflag:-false}" && readonly mv="dry_run" || readonly mv="mv ${mv_opts}"
[[ "$(expr substr $(uname -s) 1 5)" == 'MINGW' ]] \
  && readonly cygpath="cygpath" \
  || readonly cygpath="echo"

trap teardown EXIT
trap 'rc=$?; trap - EXIT; teardown; exit ${rc}' INT PIPE TERM

# Create temporary files
readonly srclist=$(mktemp) && garbage_files+=("${srclist}")
readonly dstlist=$(mktemp) && garbage_files+=("${dstlist}")

# Output target file names to temporary files
readonly lines=$(find "$@" ${find_opts:--maxdepth 0} ${FIND_EXCLUDE} \
  | ipc \
  | sort \
  | tee "${srclist}" "${dstlist}" \
  | wc -l) \
  || exit $?

if [[ "${lines}" -gt 0 ]]; then
  # Open the destination list by EDITOR and wait close it
  ${EDITOR:-nano} "${dstlist}" \
    && [[ "$(wc -l <${dstlist})" -eq "${lines}" ]] \
    || error "number of FILE(s) missmatched"
fi

# Read file names from temporary files and rename target files
diff -y --suppress-common-lines "${srclist}" "${dstlist}" \
  | sed -re 's/\s+\|\s+/\t/' \
  | while IFS=$'\t' read -r src dst; do
    src=$(${cygpath} "${src}")
    dst=$(${cygpath} "${dst}")
    ${mv} "${src}" "${dst}" \
      || error "Unable to rename '${src}' to '${dst}'"
  done
