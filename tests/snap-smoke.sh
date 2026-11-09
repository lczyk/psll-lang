#!/bin/sh -e
# run every example through an installed psll and diff it against its snapshot.
# stderr is part of the diff, so a ruby warning from the bundled interpreter fails too.

PSLL="${PSLL:-psll}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

_check() {
    local snapshot="$1"
    local name
    name="$(basename "${snapshot}" .txt)"
    name="${name%-*}"
    if "${PSLL}" compile-and-run "${ROOT}/examples/${name}.psll" 2>&1 | diff -u "${snapshot}" -; then
        printf 'ok    %s\n' "${name}"
    else
        printf 'FAIL  %s\n' "${name}" >&2
        return 1
    fi
}

main() {
    local failed=0
    printf 'using %s (%s)\n' "$(command -v "${PSLL}")" "$("${PSLL}" --version)"
    for snapshot in "${ROOT}"/tests/examples_outputs/*.txt; do
        _check "${snapshot}" || failed=1
    done
    exit "${failed}"
}

main "$@"
