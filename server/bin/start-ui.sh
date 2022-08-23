#! /usr/bin/env bash
#>------------------------------------------------------------------------------
#>
#> [ start-ui.sh ]
#>
#>    Initialize a Minecraft server with an interactive user interface
#>
#>    If no version number is specified then version 1.19.2 will be started by
#>    default.
#>
#> USAGE:
#>
#>    start-ui.sh <OPTION>
#>    start-ui.sh <INPUT>
#>
#>    where both "INPUT" and "OPTION" are optional; and where "INPUT" is a valid
#>    server version number in the form of ##.##.##; and where "OPTION" is one
#>    of the following:
#>
#>                |
#>    -h, --help  | Print this help text to the terminal
#>                |
#>
#> REFERENCE:
#>
#>    # Java Minecraft server download and execution page (official)
#>    https://www.minecraft.net/en-us/download/server
#>
#>    # Setting up a server (tutorial)
#>    https://minecraft.fandom.com/wiki/Tutorials/Setting_up_a_server
#>
#>    # Recommended launch options for server.jar
#>    https://mcflags.emc.gs
#>
#>------------------------------------------------------------------------------
#_______________________________________________________________________________
# Declare functions
#

    function _help() {
        cat "${sh_path}" \
            | grep --color=never -E '^#[>]' \
            | sed 's/^..//'

        return $?
    }

#_______________________________________________________________________________
# Declare variables and arrays
#

    e_c=2
    here_now=$(readlink -f "${PWD}")
    sh_path=$(readlink -f "${0}")
    sh_file="${sh_path//*\/}"
    sh_root="${sh_path%\/*}"
    sh_base=$(readlink -f "${sh_root}/..")
    sh_base_name="${sh_base//*\/}"
    sh_logs="${sh_base}/logs"
    lib_dir=$(readlink -f "${sh_root}/../lib")
    lib_path=$(readlink -f "${lib_dir}/${sh_base_name}.lib")

    ops_version=""

#_______________________________________________________________________________
# Execute operations
#

    if [[ ! -f "${lib_path}" ]]; then
        ## Kill the script if the related library file is missing
        exit 1
    else
        ## Source the related library file
        source "${lib_path}"
    fi

    case "${1//-}" in
        h|H|help)
            _help
            exit $?
            ;;
        v=*|version=*)
            ops_version="${1//*[=]}"
            ;;
        [0-9]*)
            ops_version="${1//-}"
            ;;
    esac

    echo "Calling library function: mcmanager_server_start --ui" | mcmanager_server_logger -i

    if [[ "x${ops_version}" == "x" ]]; then
        mcmanager_server_start --ui
    else
        mcmanager_server_start --ui --version="${ops_version}"
    fi

    exit $?

#
