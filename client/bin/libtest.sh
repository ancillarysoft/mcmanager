#! /usr/bin/env bash
#>------------------------------------------------------------------------------
#>
#> [ libtest.sh ]
#>
#>    Script for testing the local bash library (client.lib)
#>
#> USAGE:
#>
#>    libtest.sh <OPTION>
#>
#>    where "OPTION" is an optional input; and where "OPTION" is one of the
#>    following:
#>
#>                |
#>    -h, --help  | Print this help text to the terminal
#>                |
#>
#>------------------------------------------------------------------------------
#_______________________________________________________________________________
# Declare functions
#

    function _help() {
        # General help text printing function
        cat "${sh_path}" \
            | grep -E '^#[>]' \
            | sed 's/^..//'

        return $?
    }

#_______________________________________________________________________________
# Declare variables
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

#_______________________________________________________________________________
# Execute operations
#

    if [[ "${1}" =~ ^-[hH]$ || "${1}" =~ ^-+help$ ]]; then
        ## Capture help text requests
        _help

        exit $e_c
    fi

    if [[ ! -f "${lib_path}" ]]; then
        ## Kill the script if the related library file is missing
        exit 1
    else
        ## Source the related library file
        source "${lib_path}"
    fi

    ## Run library function and capture the subsequent exit code

    e_c=$?

    exit $e_c

#_______________________________________________________________________________
