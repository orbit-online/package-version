#!/bin/bash

set -e

if ! type jq &> /dev/null; then
    printf -- 'Missing dependency jq, to install it run the following:\n\nsudo apt install jq\n' >&2
    exit 1
fi

PROJECT_PATH=$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

build-package-version() {
    local jq_filter package_version package_name='package-version'
    package_version="$(head -n1 < "$PROJECT_PATH/packages/$package_name/VERSION")"

    read -r jq_filter < <(printf -- '.name="@orbit-online/%s" | .version="%s" | del(.dependencies,.devDependencies,.private)\n' "$package_name" "$package_version")

    mkdir -p "$PROJECT_PATH/packages/$package_name/bin"
    jq "$jq_filter" < package.json > "$PROJECT_PATH/packages/$package_name/package.json"

    cp "$PROJECT_PATH/bin/package-version."* "$PROJECT_PATH/packages/$package_name/bin/"
    cp "$PROJECT_PATH/LICENSE" "$PROJECT_PATH/packages/$package_name/"
}

clean-package-version() {
    local package_name='package-version'
    git clean -fdX -- "$PROJECT_PATH/packages/$package_name/" > /dev/null
}

clean() {
    clean-package-version "$@"
}

build() {
    build-package-version "$@"
}

clean "$@"
build "$@"
