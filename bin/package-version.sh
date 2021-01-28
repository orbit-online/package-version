#!/bin/bash

set -e

if [ -z "$PROJECT_PATH" ]; then
    find_project_root() {
        local path
        path="$(pwd)"
        while [ "$path" != '/' ] ; do
            if [[ -d "$path/.git" || -f "$path/.env" || -f "$path/package.json" ]]; then
                printf -- '%s' "$path"
                return 0
            fi
            path="$(dirname "$path")"
        done
        return 1
    }
    PROJECT_PATH="$(find_project_root)"
    export PROJECT_PATH
fi

if [ ! -d "$PROJECT_PATH" ]; then
    printf -- 'PROJECT_PATH it must point to a readable directory, got:
- %s
' "$PROJECT_PATH" >&2
    exit 1
fi

package-version() {
    DOC="Utility to guide semver versioning of software packages.

Usage:
  package-version [options] (major|minor|patch) [alpha|beta|rc] [PACKAGE]
  package-version [options] (alpha|beta|rc) [PACKAGE]
  package-version [options] release [PACKAGE]
  package-version [options] [PACKAGE]

Options:
  -q --quiet    Don't report anything but errors
                and remove the package name prefix when displaying the current version.
  -s --silent   Total silence, rely solely on exit code
  -n --dry-run  Displaying what would happen without doing any actual changes,
                bypassing dirty checks as well.

Commands:
  major         Bump the package to the next major version.
  minor         Bump the package to the next minor version.
  patch         Bump the package to the next patch version.
  alpha         Bump the package to the next alpha pre-release version,
                if the pacakge is not currently in pre-release an error is returned.
  beta          Bump the package to the next beta pre-release version,
                if the pacakge is not currently in pre-release an error is returned.
  rc            Bump the package to the next rc pre-release version,
                if the pacakge is not currently in pre-release an error is returned.
  release       Release the non-pre-release version of the pacakge,
                if the package is not currently in pre-release an error is returned.

Modifiers:
  alpha         Add alpha pre-release suffix to the version bump
  beta          Add beta pre-release suffix to the version bump
  rc            Add rc pre-release suffix to the version bump

Packages:
  <NONE>        Assumes the package to manimulate / query version for
                lives in the root of PROJECT_PATH or PROJECT_PATH/package.
  PACKAGE       When PACKAGE is provided the name corresponds to a directory name,
                with a VERSION file that lives within.
                Per default packages are searched for in PROJECT_PATH/packages,
                this behavior can be modified by providing the PACKAGE_VERSION_PATH environment variable.

Examples:
  Bump package from alpha to beta version.
    $ package-version beta                         (e.g. 1.2.5-alpha.4 -> 1.2.5-beta.1)

  Bump rc of a package already in rc pre-release.
    $ package-version rc                           (e.g. 1.2.6-rc.2 -> 1.2.6-rc.3)

  Bump minor version as an alpha pre-release.
    $ package-version minor alpha                  (e.g. 1.2.7 -> 1.3.0-alpha.1)

  Bump major version of the package.
    $ package-version major                        (e.g. 1.2.8 -> 2.0.0)

"
# docopt parser below, refresh this parser with `docopt.sh package-version.sh`
# shellcheck disable=2016,1075
docopt() { parse() { if ${DOCOPT_DOC_CHECK:-true}; then local doc_hash
if doc_hash=$(printf "%s" "$DOC" | (sha256sum 2>/dev/null || shasum -a 256)); then
if [[ ${doc_hash:0:5} != "$digest" ]]; then
stderr "The current usage doc (${doc_hash:0:5}) does not match \
what the parser was generated with (${digest})
Run \`docopt.sh\` to refresh the parser."; _return 70; fi; fi; fi
local root_idx=$1; shift; argv=("$@"); parsed_params=(); parsed_values=()
left=(); testdepth=0; local arg; while [[ ${#argv[@]} -gt 0 ]]; do
if [[ ${argv[0]} = "--" ]]; then for arg in "${argv[@]}"; do
parsed_params+=('a'); parsed_values+=("$arg"); done; break
elif [[ ${argv[0]} = --* ]]; then parse_long
elif [[ ${argv[0]} = -* && ${argv[0]} != "-" ]]; then parse_shorts
elif ${DOCOPT_OPTIONS_FIRST:-false}; then for arg in "${argv[@]}"; do
parsed_params+=('a'); parsed_values+=("$arg"); done; break; else
parsed_params+=('a'); parsed_values+=("${argv[0]}"); argv=("${argv[@]:1}"); fi
done; local idx; if ${DOCOPT_ADD_HELP:-true}; then
for idx in "${parsed_params[@]}"; do [[ $idx = 'a' ]] && continue
if [[ ${shorts[$idx]} = "-h" || ${longs[$idx]} = "--help" ]]; then
stdout "$trimmed_doc"; _return 0; fi; done; fi
if [[ ${DOCOPT_PROGRAM_VERSION:-false} != 'false' ]]; then
for idx in "${parsed_params[@]}"; do [[ $idx = 'a' ]] && continue
if [[ ${longs[$idx]} = "--version" ]]; then stdout "$DOCOPT_PROGRAM_VERSION"
_return 0; fi; done; fi; local i=0; while [[ $i -lt ${#parsed_params[@]} ]]; do
left+=("$i"); ((i++)) || true; done
if ! required "$root_idx" || [ ${#left[@]} -gt 0 ]; then error; fi; return 0; }
parse_shorts() { local token=${argv[0]}; local value; argv=("${argv[@]:1}")
[[ $token = -* && $token != --* ]] || _return 88; local remaining=${token#-}
while [[ -n $remaining ]]; do local short="-${remaining:0:1}"
remaining="${remaining:1}"; local i=0; local similar=(); local match=false
for o in "${shorts[@]}"; do if [[ $o = "$short" ]]; then similar+=("$short")
[[ $match = false ]] && match=$i; fi; ((i++)) || true; done
if [[ ${#similar[@]} -gt 1 ]]; then
error "${short} is specified ambiguously ${#similar[@]} times"
elif [[ ${#similar[@]} -lt 1 ]]; then match=${#shorts[@]}; value=true
shorts+=("$short"); longs+=(''); argcounts+=(0); else value=false
if [[ ${argcounts[$match]} -ne 0 ]]; then if [[ $remaining = '' ]]; then
if [[ ${#argv[@]} -eq 0 || ${argv[0]} = '--' ]]; then
error "${short} requires argument"; fi; value=${argv[0]}; argv=("${argv[@]:1}")
else value=$remaining; remaining=''; fi; fi; if [[ $value = false ]]; then
value=true; fi; fi; parsed_params+=("$match"); parsed_values+=("$value"); done
}; parse_long() { local token=${argv[0]}; local long=${token%%=*}
local value=${token#*=}; local argcount; argv=("${argv[@]:1}")
[[ $token = --* ]] || _return 88; if [[ $token = *=* ]]; then eq='='; else eq=''
value=false; fi; local i=0; local similar=(); local match=false
for o in "${longs[@]}"; do if [[ $o = "$long" ]]; then similar+=("$long")
[[ $match = false ]] && match=$i; fi; ((i++)) || true; done
if [[ $match = false ]]; then i=0; for o in "${longs[@]}"; do
if [[ $o = $long* ]]; then similar+=("$long"); [[ $match = false ]] && match=$i
fi; ((i++)) || true; done; fi; if [[ ${#similar[@]} -gt 1 ]]; then
error "${long} is not a unique prefix: ${similar[*]}?"
elif [[ ${#similar[@]} -lt 1 ]]; then
[[ $eq = '=' ]] && argcount=1 || argcount=0; match=${#shorts[@]}
[[ $argcount -eq 0 ]] && value=true; shorts+=(''); longs+=("$long")
argcounts+=("$argcount"); else if [[ ${argcounts[$match]} -eq 0 ]]; then
if [[ $value != false ]]; then
error "${longs[$match]} must not have an argument"; fi
elif [[ $value = false ]]; then
if [[ ${#argv[@]} -eq 0 || ${argv[0]} = '--' ]]; then
error "${long} requires argument"; fi; value=${argv[0]}; argv=("${argv[@]:1}")
fi; if [[ $value = false ]]; then value=true; fi; fi; parsed_params+=("$match")
parsed_values+=("$value"); }; required() { local initial_left=("${left[@]}")
local node_idx; ((testdepth++)) || true; for node_idx in "$@"; do
if ! "node_$node_idx"; then left=("${initial_left[@]}"); ((testdepth--)) || true
return 1; fi; done; if [[ $((--testdepth)) -eq 0 ]]; then
left=("${initial_left[@]}"); for node_idx in "$@"; do "node_$node_idx"; done; fi
return 0; }; either() { local initial_left=("${left[@]}"); local best_match_idx
local match_count; local node_idx; ((testdepth++)) || true
for node_idx in "$@"; do if "node_$node_idx"; then
if [[ -z $match_count || ${#left[@]} -lt $match_count ]]; then
best_match_idx=$node_idx; match_count=${#left[@]}; fi; fi
left=("${initial_left[@]}"); done; ((testdepth--)) || true
if [[ -n $best_match_idx ]]; then "node_$best_match_idx"; return 0; fi
left=("${initial_left[@]}"); return 1; }; optional() { local node_idx
for node_idx in "$@"; do "node_$node_idx"; done; return 0; }; _command() {
local i; local name=${2:-$1}; for i in "${!left[@]}"; do local l=${left[$i]}
if [[ ${parsed_params[$l]} = 'a' ]]; then
if [[ ${parsed_values[$l]} != "$name" ]]; then return 1; fi
left=("${left[@]:0:$i}" "${left[@]:((i+1))}")
[[ $testdepth -gt 0 ]] && return 0; if [[ $3 = true ]]; then
eval "((var_$1++)) || true"; else eval "var_$1=true"; fi; return 0; fi; done
return 1; }; switch() { local i; for i in "${!left[@]}"; do local l=${left[$i]}
if [[ ${parsed_params[$l]} = "$2" ]]; then
left=("${left[@]:0:$i}" "${left[@]:((i+1))}")
[[ $testdepth -gt 0 ]] && return 0; if [[ $3 = true ]]; then
eval "((var_$1++))" || true; else eval "var_$1=true"; fi; return 0; fi; done
return 1; }; value() { local i; for i in "${!left[@]}"; do local l=${left[$i]}
if [[ ${parsed_params[$l]} = "$2" ]]; then
left=("${left[@]:0:$i}" "${left[@]:((i+1))}")
[[ $testdepth -gt 0 ]] && return 0; local value
value=$(printf -- "%q" "${parsed_values[$l]}"); if [[ $3 = true ]]; then
eval "var_$1+=($value)"; else eval "var_$1=$value"; fi; return 0; fi; done
return 1; }; stdout() { printf -- "cat <<'EOM'\n%s\nEOM\n" "$1"; }; stderr() {
printf -- "cat <<'EOM' >&2\n%s\nEOM\n" "$1"; }; error() {
[[ -n $1 ]] && stderr "$1"; stderr "$usage"; _return 1; }; _return() {
printf -- "exit %d\n" "$1"; exit "$1"; }; set -e; trimmed_doc=${DOC:0:2615}
usage=${DOC:58:218}; digest=3e85c; shorts=(-s -q -n)
longs=(--silent --quiet --dry-run); argcounts=(0 0 0); node_0(){
switch __silent 0; }; node_1(){ switch __quiet 1; }; node_2(){
switch __dry_run 2; }; node_3(){ value PACKAGE a; }; node_4(){ _command major; }
node_5(){ _command minor; }; node_6(){ _command patch; }; node_7(){
_command alpha; }; node_8(){ _command beta; }; node_9(){ _command rc; }
node_10(){ _command release; }; node_11(){ optional 0 1 2; }; node_12(){
optional 11; }; node_13(){ either 4 5 6; }; node_14(){ required 13; }
node_15(){ either 7 8 9; }; node_16(){ optional 15; }; node_17(){ optional 3; }
node_18(){ required 12 14 16 17; }; node_19(){ required 15; }; node_20(){
required 12 19 17; }; node_21(){ required 12 10 17; }; node_22(){ required 12 17
}; node_23(){ either 18 20 21 22; }; node_24(){ required 23; }
cat <<<' docopt_exit() { [[ -n $1 ]] && printf "%s\n" "$1" >&2
printf "%s\n" "${DOC:58:218}" >&2; exit 1; }'; unset var___silent var___quiet \
var___dry_run var_PACKAGE var_major var_minor var_patch var_alpha var_beta \
var_rc var_release; parse 24 "$@"; local prefix=${DOCOPT_PREFIX:-''}
unset "${prefix}__silent" "${prefix}__quiet" "${prefix}__dry_run" \
"${prefix}PACKAGE" "${prefix}major" "${prefix}minor" "${prefix}patch" \
"${prefix}alpha" "${prefix}beta" "${prefix}rc" "${prefix}release"
eval "${prefix}"'__silent=${var___silent:-false}'
eval "${prefix}"'__quiet=${var___quiet:-false}'
eval "${prefix}"'__dry_run=${var___dry_run:-false}'
eval "${prefix}"'PACKAGE=${var_PACKAGE:-}'
eval "${prefix}"'major=${var_major:-false}'
eval "${prefix}"'minor=${var_minor:-false}'
eval "${prefix}"'patch=${var_patch:-false}'
eval "${prefix}"'alpha=${var_alpha:-false}'
eval "${prefix}"'beta=${var_beta:-false}'; eval "${prefix}"'rc=${var_rc:-false}'
eval "${prefix}"'release=${var_release:-false}'; local docopt_i=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_i=2; for ((;docopt_i>0;docopt_i--)); do
declare -p "${prefix}__silent" "${prefix}__quiet" "${prefix}__dry_run" \
"${prefix}PACKAGE" "${prefix}major" "${prefix}minor" "${prefix}patch" \
"${prefix}alpha" "${prefix}beta" "${prefix}rc" "${prefix}release"; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh package-version.sh`

    eval "$(docopt "$@")"

    # shellcheck disable=SC2154
    if $__dry_run; then
        printf -- 'WARNING: RUNNING IN DRY-RUN MODE, NO CHANGES WILL BE MADE\n' >&2
    fi

    local search_paths=()

    resolve_search_paths() {
        if [ -n "$PACKAGE_VERSION_PATH" ]; then
            read_pkg_version_paths
        else
            search_paths+=( "$PROJECT_PATH" )
            [ -d "$PROJECT_PATH/package" ] && search_paths+=( "$PROJECT_PATH/package" )
            [ -d "$PROJECT_PATH/packages" ] && search_paths+=( "$PROJECT_PATH/packages" )
        fi
        return 0
    }

    read_pkg_version_paths() {
        local path
        while IFS= read -r path; do
            [ -z "$path" ] && continue
            if [ ! -e "$path" ]; then
                # shellcheck disable=SC2154
                ! $__silent && printf -- 'Invalid search path defined in PACKAGE_VERSION_PATH environment variable.\n- %s\n' "$path" >&2
                return 1
            fi
            search_paths+=( "$path" )
        done <<< "$(echo -e "${PACKAGE_VERSION_PATH//:/"\n"}")"
        return 0
    }

    local version_path
    set_version_file() {
        local path=$1
        if [ -f "$path" ]; then
            if [[ "$(basename "$path")" != 'VERSION' ]]; then
                ! $__silent && printf -- 'Version files must be called VERSION, got\n- %s\n' "$path" >&2
                return 1
            fi
            version_path="$path"
        else
            ! $__silent && printf -- 'No VERSION file was found in the directory
- %s
' "$path" >&2
            return 1
        fi
    }

    resolve_search_paths

    local package_name search_path
    if [ -n "$PACKAGE" ]; then
        for search_path in "${search_paths[@]}"; do
            if [ -f "$search_path" ]; then
                if [[ "$(basename "$(dirname "$search_path")")" == "$PACKAGE" ]]; then
                    set_version_file "$search_path"
                    package_name="$PACKAGE"
                    break
                fi
            elif [ -d "$search_path" ]; then
                if [ -d "$search_path/$PACKAGE" ]; then
                    set_version_file "$search_path/$PACKAGE/VERSION"
                    package_name="$PACKAGE"
                    break
                elif [[ "$(dirname "$search_path")" == "$PACKAGE" ]]; then
                    set_version_file "$search_path/VERSION"
                    package_name="$PACKAGE"
                    break
                fi
            fi
        done
    else
        for search_path in "${search_paths[@]}"; do
            if [ -f "$search_path" ]; then
                set_version_file "$search_path"
                package_name="$(basename "$(dirname "$search_path")")"
                break
            elif [[ -d "$search_path" && -f "$search_path/VERSION" ]]; then
                set_version_file "$search_path/VERSION"
                if [[ "$(basename "$search_path")" == 'package' ]]; then
                    package_name="$(basename "$(dirname "$search_path")")"
                else
                    package_name="$(basename "$search_path")"
                fi
                break
            fi
        done
    fi

    if [ -z "$version_path" ]; then
        if [ -n "$package_name" ]; then
            ! $__silent && printf -- 'No VERSION file found for package "%s", searched in\n' "$package_name" >&2
        else
            ! $__silent && printf -- 'No VERSION file found, searched in\n' >&2
        fi
        ! $__silent && printf -- '%s\n' "${search_paths[@]}" >&2
        return 1
    fi

    local new_pre_release_name
    # shellcheck disable=SC2154
    if $alpha; then
        new_pre_release_name='alpha'
    elif $beta; then
        new_pre_release_name='beta'
    elif $rc; then
        new_pre_release_name='rc'
    fi

    if ! $__dry_run && [[ -n $(git diff -- "$version_path") ]]; then
        ! $__silent && printf -- 'The VERSION file of the %s package has uncomitted changes,\nplease commit them or reset the changes and try again.\n' "$package_name" >&2
        return 1
    fi
    if ! $__dry_run && [[ -n $(git diff --staged) ]]; then
        ! $__silent && printf -- 'There are staged changes in the git working copy, please unstage the changes and try again.\n' >&2
        return 1
    fi

    local current_major current_minor current_patch current_pre_release
    current_major=$(grep -oP '^\K(\d+)' < "$version_path")
    current_minor=$(grep -oP '^\d+\.\K(\d+)' < "$version_path")
    current_patch=$(grep -oP '^\d+\.\d+\.\K(\d+)' < "$version_path")
    current_pre_release=$(grep -oP '^\d+\.\d+\.\d+-\K(.+)' < "$version_path" 2>/dev/null || printf -- '')

    local current_version current_pre_release_name current_pre_release_version
    if [[ -n "$current_pre_release" ]]; then
        read -r current_version <<< "$(printf -- '%d.%d.%d-%s' "$current_major" "$current_minor" " $current_patch" "$current_pre_release" )"
        current_pre_release_name=$(grep -oP '^\d+\.\d+\.\d+-\K(alpha|beta|rc)' < "$version_path" 2>/dev/null || printf -- '')
        current_pre_release_version=$(grep -oP '^\d+\.\d+\.\d+-\w+\.\K(\d+)' < "$version_path" 2>/dev/null || printf -- '0')
    else
        read -r current_version <<< "$(printf -- '%d.%d.%d' "$current_major" "$current_minor" " $current_patch")"
        # shellcheck disable=SC2154
        if $release; then
            ! $__silent && printf -- 'The package must currently be a pre-release in order to use the pre-release command.\n%s is currently in %s which is not a pre-release.\n' "$package_name" "$current_version" >&2
            return 1
        fi
    fi

    # shellcheck disable=SC2154
    if $major; then
        current_major=$((current_major + 1))
        current_minor=0
        current_patch=0
        current_pre_release_name=alpha
        current_pre_release_version=0
    elif $minor; then
        current_minor=$((current_minor + 1))
        current_patch=0
        current_pre_release_name=alpha
        current_pre_release_version=0
    elif $patch; then
        current_patch=$((current_patch + 1))
        current_pre_release_name=alpha
        current_pre_release_version=0
    elif [ -z "$new_pre_release_name" ] && ! $release; then
        # No command subcommand or modifier was specified
        # Usage: package-version [PACKAGE]
        ! $__silent && ! $__quiet && printf -- '%s: ' "$package_name" >&2
        printf -- '%s\n' "$current_version"
        return 0
    fi

    local new_version
    if [[ -n "$new_pre_release_name" ]]; then
        if [[ "$new_pre_release_name" == "$current_pre_release_name" ]]; then
            current_pre_release_version=$((current_pre_release_version + 1))
        elif [[ "$new_pre_release_name" =~ ^beta|rc$ && "$current_pre_release_name" == 'alpha' ]] || \
             [[ "$new_pre_release_name" = 'rc' && "$current_pre_release_name" =~ ^alpha|beta$ ]]; then
            current_pre_release_version="1"
        else
            if [[ -z "$current_pre_release_name" ]]; then
                ! $__silent && printf -- 'Cannot bump %s pre-release from a non-pre-release without bumping version number as well.\ne.g. by running:\n$ package-version minor alpha %s\n' "$new_pre_release_name" "$PACKAGE" >&2
            else
                ! $__silent && printf -- 'Cannot bump pre-release from %s to %s\nOnly bumping to same or higher version suffix order is allowed.\n' "$current_pre_release_name" "$new_pre_release_name" >&2
            fi
            return 1
        fi
        read -r new_version <<< "$(printf -- '%d.%d.%d-%s.%d' "$current_major" "$current_minor" " $current_patch" "$new_pre_release_name" "$current_pre_release_version" )"
    else
        read -r new_version <<< "$(printf -- '%d.%d.%d' "$current_major" "$current_minor" " $current_patch")"
    fi

    local git_commit_msg git_release_tag
    if [ -n "$PACKAGE" ]; then
        git_commit_msg="Release: ${PACKAGE} v${new_version}"
        git_release_tag="v${new_version}-${PACKAGE}"
    else
        git_commit_msg="Release: v${new_version}"
        git_release_tag="v${new_version}"
    fi

    if ! $__dry_run; then
        printf -- '%s\n' "$new_version" > "$version_path"
        git add -- "$version_path" > /dev/null
        git commit -m "$git_commit_msg" > /dev/null
        git tag "$git_release_tag" > /dev/null
    fi

    ! $__silent && ! $__quiet && printf -- 'Bumped the version of %s from %s -> %sWrote the changes back to the VERSION file, committed the changes with the message:\n\n%s\n\ntagged the commit with:\n\n%s\n\nDon'\''t forget to push both the branch and the tag e.g. by running:\n\n$ git push && git push --tags\n' "$package_name" "$current_version" "$new_version" "$git_commit_msg" "$git_release_tag"
    ! $__silent && $__quiet && printf -- '%s\n' "$new_version"
}

package-version "$@"
