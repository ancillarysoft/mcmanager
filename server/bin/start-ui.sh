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

    function _logger() {
        # Verbosity handler function (accepts input pipe or direct input)
        ##
        ## Parses out empty lines (only if the input is an incoming pipe)
        ## Prints all outputs to the terminal ( /dev/stdout <-- ¯\_(ツ)_/¯ )
        ## Writes all outputs to the log file ( ../logs/{{shortdate}}.log )
        ##
        ## Positional arguments for direct invocation (non-piped inputs):
        ##  - <TYPE> (e,i,s,w)
        ##

        local run_time="$(date '+%s.%N')"
        local stack_complete=( $(echo ${FUNCNAME[*]}) )
        local stack_last=${stack_complete[-1]}
        local stack_string_a=$(sed 's/ /:/g' <<<"${FUNCNAME[@]}")
        local stack_string_b="${stack_string_a#$FUNCNAME:}"
        local stack_string="${stack_string_b%:main}"
        local log_dir="${sh_logs}"
        local log_name="${run_time:0:4}"
        local log_file="${log_name}.log"
        local log_path="${log_dir}/${log_file}"

        ## Build the log/verbosity message: ${_a}|${_b}|${_c}|${_d}|${_e}
        ##
        ##  _a = Unix timestamp with miliseconds
        ##  _b = Seven-place zerobuffered system process ID (${PPID})
        ##  _c = Primary process name (usually the name of a bash script)
        ##  _d = Type (E=error, I=info, S=success, W=warning)
        ##  _e = Stack trace and message data
        ##

        local _a="${run_time}"
        local _b=$(printf '%07d\n' "${PPID}")

        ## If $sh_file is defined, then use that parent script file name
        ## otherwise, fallback to using the project name instead.
        ##
        ## REFERENCE: https://stackoverflow.com/a/13864829/8672154
        ##

        #if [[ -z "${sh_file+x}" ]]; then
        if [[ "x${sh_file}" != "x" ]]; then
            local _c="${sh_file}"
        else
            local _c="main"
        fi

        if [[ "x${1}" == "x" ]]; then
            local _d=I
        else
            case "${1//-}" in
                e|E|err|error)
                    ## Log message type: error
                    local _d=E
                    shift 1
                    ;;
                i|I|info)
                    ## Log message type: info
                    local _d=I
                    shift 1
                    ;;
                s|S|success)
                    ## Log message type: success
                    local _d=S
                    shift 1
                    ;;
                w|W|warn|warning)
                    ## Log message type: warning
                    local _d=W
                    shift 1
                    ;;
                ''|*)
                    ## default log message type: info
                    local _d=I
                    ;;
            esac
        fi

        if [ -t 0 ]; then
            ## Input type: DIRECT
            local _e="${stack_string}: $@"
            local output="${_a}|${_b}|${_c}|${_d}|${_e}"

            echo "${output}" \
                | tee -a "${log_path}"
        else
            ## Input type: PIPE
            local _e="${stack_string}:"

            ts "${_a}|${_b}|${_c}|${_d}|${_e}" \
                | sed -u '/[[:blank:]]\{1,\}$/d' \
                | tee -a "${log_path}"
        fi

        return $?
    }

    function _run() {
        local run_ec="2"
        local session_dt_a=$(date '+%s.%N')

        if [[ ! -d "${server_dir}" ]]; then
            echo "Server path not found (${server_dir})" | _logger -e
            local run_ec=1
        else
            echo "Starting Minecraft server version ${ops_version}" | _logger -i

            cd "${server_dir}"

            if [[ ! -f "server.jar" ]]; then
                echo "Required jar file not found (${server_jar})" | _logger -e
            else
                mkdir -p logs
                touch logs/gc.log

                # Basic parameters (Memory usage: 1024M)
                # Reference: https://www.minecraft.net/en-us/download/server
                #java -Xmx1024M -Xms1024M -jar server.jar 2>&1 | _logger

                # Advanced parameters (Memory usage: 10G)
                # Reference: https://mcflags.emc.gs

                java \
                    -Xms10G \
                    -Xmx10G \
                    -XX:+UseG1GC \
                    -XX:+ParallelRefProcEnabled \
                    -XX:MaxGCPauseMillis=200 \
                    -XX:+UnlockExperimentalVMOptions \
                    -XX:+DisableExplicitGC \
                    -XX:+AlwaysPreTouch \
                    -XX:G1NewSizePercent=30 \
                    -XX:G1MaxNewSizePercent=40 \
                    -XX:G1HeapRegionSize=8M \
                    -XX:G1ReservePercent=20 \
                    -XX:G1HeapWastePercent=5 \
                    -XX:G1MixedGCCountTarget=4 \
                    -XX:InitiatingHeapOccupancyPercent=15 \
                    -XX:G1MixedGCLiveThresholdPercent=90 \
                    -XX:G1RSetUpdatingPauseTimePercent=5 \
                    -XX:SurvivorRatio=32 \
                    -XX:+PerfDisableSharedMem \
                    -XX:MaxTenuringThreshold=1 \
                    -Dusing.aikars.flags=https://mcflags.emc.gs \
                    -Daikars.new.flags=true \
                    -Xlog:gc*:logs/gc.log:time,uptime:filecount=5,filesize=1M \
                    -jar server.jar 2>&1 | _logger

                if [[ "${PIPESTATUS[@]}" =~ 1 ]]; then local run_ec=1; else local run_ec=0; fi
                local session_dt_b=$(date '+%s.%N')

                echo "Closing server session (exit code ${run_ec})" | _logger -i
                echo "Session start time ..... ${session_dt_a}" | _logger -i
                echo "Session finish time .... ${session_dt_b}" | _logger -i
            fi

            cd "${here_now}"
        fi

        return $run_ec
    }

#_______________________________________________________________________________
# Declare variables and arrays
#

    dt_run=$(date '+%s.%N')
    dt_min="${dt_run//.*}"
    here_now=$(readlink -f "${PWD}")
    u_n=$(whoami)
    u_h="/home/${u_n}"
    sh_path=$(readlink -f "${0}")
    sh_root="${sh_path%\/*}"
    sh_prnt="${sh_root%\/*}"
    sh_logs="${sh_prnt}/logs"
    sh_file="${sh_path//*\/}"
    sh_name="${sh_file%.sh}"
    ops_version=""
    ops_version_default="1.19.2"

#_______________________________________________________________________________
# Execute operations
#

    mkdir -p "${sh_logs}"

    while [[ "$#" -gt 0 ]]; do
        i_n="${1}"
        in_mod="${i_n//-}"
        case "${in_mod}" in
            h|H|help)
                _help
                exit $?
                ;;
            *)
                in_test=$(grep --color=never -E '^([0-9]){1,}\.([0-9]){1,}\.([0-9]){1,}' <<<"${i_n}" &>/dev/null; echo $?)

                if [[ "${in_test}" -eq 0 ]]; then
                    ops_version="${i_n}"
                    echo "Detected valid input: Server version number (${ops_version})" | _logger -i
                else
                    echo "Detected invalid input (${1}); ignoring input" | _logger -w
                fi
                ;;
        esac
        shift 1
    done

    if [[ "x${ops_version}" == "x" ]]; then
        ops_version="${ops_version_default}"
    fi

    server_dir=$(readlink -f "${sh_prnt}/${ops_version}")
    server_jar="${server_dir}/server.jar"

    echo "Derived server directory path: ${server_dir}" | _logger -i
    echo "Derived server jar path: ${server_jar}" | _logger -i

    _run

    exit $?

#
