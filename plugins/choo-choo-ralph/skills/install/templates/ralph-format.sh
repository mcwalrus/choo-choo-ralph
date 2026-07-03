#!/usr/bin/env bash
# Format pi JSON event stream for readability
# Usage: ralph-format.sh [--verbose]

VERBOSE=false
[[ "$1" == "--verbose" || "$1" == "-v" ]] && VERBOSE=true

# Colors
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
BLUE='\033[34m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
MAGENTA='\033[35m'
GRAY='\033[90m'
WHITE='\033[97m'

# Track tokens for summary
total_input=0
total_output=0

print_wrapped() {
    local prefix="$1"
    local text="$2"
    local max_width=100
    echo "$text" | fold -s -w $max_width | while IFS= read -r line; do
        echo -e "${prefix}${line}"
    done
}

while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    type=$(echo "$line" | jq -r '.type // empty' 2>/dev/null)
    [[ -z "$type" ]] && continue

    case "$type" in
        session)
            # Session header - skip for display
            ;;

        agent_start)
            echo -e "${GRAY}${DIM}Agent starting...${RESET}"
            ;;

        agent_end)
            echo ""
            echo -e "${GREEN}${BOLD}✓ Done${RESET}"
            if $VERBOSE && [[ $total_output -gt 0 ]]; then
                echo -e "${DIM}📊 Tokens: $(printf "%'d" $total_input 2>/dev/null || echo $total_input) total${RESET}"
            fi
            ;;

        turn_start)
            ;;

        turn_end)
            ;;

        message_start)
            ;;

        message_update)
            event_type=$(echo "$line" | jq -r '.assistantMessageEvent.type // empty' 2>/dev/null)

            case "$event_type" in
                text_delta)
                    text=$(echo "$line" | jq -r '.assistantMessageEvent.delta // empty' 2>/dev/null)
                    if [[ -n "$text" ]]; then
                        echo -e "${BLUE}💭${RESET} ${text}"
                    fi
                    ;;
                thinking_delta)
                    if $VERBOSE; then
                        thinking=$(echo "$line" | jq -r '.assistantMessageEvent.delta // empty' 2>/dev/null)
                        if [[ -n "$thinking" ]]; then
                            echo -e "${DIM}${CYAN}🧠${RESET} ${DIM}${thinking}${RESET}"
                        fi
                    fi
                    ;;
            esac
            ;;

        message_end)
            input_tokens=$(echo "$line" | jq -r '.message.usage.input_tokens // 0' 2>/dev/null)
            output_tokens=$(echo "$line" | jq -r '.message.usage.output_tokens // 0' 2>/dev/null)
            total_input=$((total_input + input_tokens))
            total_output=$((total_output + output_tokens))
            ;;

        tool_execution_start)
            tool_name=$(echo "$line" | jq -r '.toolName // empty' 2>/dev/null)

            case "$tool_name" in
                bash)
                    cmd=$(echo "$line" | jq -r '.args.command // empty' 2>/dev/null)
                    if $VERBOSE; then
                        echo -e "${YELLOW}🔧 ${BOLD}${tool_name}${RESET}"
                        print_wrapped "${GRAY}   │ ${RESET}${DIM}" "$cmd"
                    else
                        display_cmd="${cmd}"
                        [[ ${#display_cmd} -gt 60 ]] && display_cmd="${display_cmd:0:57}..."
                        echo -e "${YELLOW}🔧 ${BOLD}${tool_name}${RESET} ${GRAY}${display_cmd}${RESET}"
                    fi
                    ;;
                read)
                    file=$(echo "$line" | jq -r '.args.path // empty' 2>/dev/null)
                    echo -e "${YELLOW}🔧 ${BOLD}${tool_name}${RESET} ${GRAY}${file}${RESET}"
                    ;;
                write)
                    file=$(echo "$line" | jq -r '.args.path // empty' 2>/dev/null)
                    echo -e "${YELLOW}🔧 ${BOLD}${tool_name}${RESET} ${GRAY}${file}${RESET}"
                    ;;
                edit)
                    file=$(echo "$line" | jq -r '.args.path // empty' 2>/dev/null)
                    echo -e "${YELLOW}🔧 ${BOLD}${tool_name}${RESET} ${GRAY}${file}${RESET}"
                    ;;
                *)
                    echo -e "${YELLOW}🔧 ${BOLD}${tool_name}${RESET}"
                    ;;
            esac
            ;;

        tool_execution_update)
            ;;

        tool_execution_end)
            tool_name=$(echo "$line" | jq -r '.toolName // empty' 2>/dev/null)
            is_error=$(echo "$line" | jq -r '.isError // false' 2>/dev/null)

            if [[ "$is_error" == "true" ]]; then
                result=$(echo "$line" | jq -r '.result // empty' 2>/dev/null)
                if $VERBOSE; then
                    echo -e "${MAGENTA}   ✗ ERROR:${RESET}"
                    print_wrapped "${GRAY}   │ ${RESET}${MAGENTA}" "$result"
                else
                    first_line=$(echo "$result" | head -1)
                    [[ ${#first_line} -gt 80 ]] && first_line="${first_line:0:77}..."
                    echo -e "${GRAY}   └─${RESET} ${MAGENTA}✗ ${first_line}${RESET}"
                fi
            else
                case "$tool_name" in
                    bash|read|write|edit)
                        if $VERBOSE; then
                            result=$(echo "$line" | jq -r '.result // empty' 2>/dev/null)
                            [[ -n "$result" ]] && print_wrapped "${GRAY}   │ ${RESET}${DIM}" "$(echo "$result" | head -5)"
                        fi
                        ;;
                esac
            fi
            ;;

        queue_update|compaction_start|compaction_end|auto_retry_start|auto_retry_end)
            ;;
    esac
done