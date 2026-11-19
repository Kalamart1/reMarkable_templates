#!/bin/bash

REPO="https://raw.githubusercontent.com/Kalamart1/reMarkable_templates"
BRANCH="master"
XOCHITL="/home/root/.local/share/remarkable/xochitl"
TMP_DIR="/tmp/kalamart-templates"

# Template catalogue: visible name and directory name
TEMPLATE_NAMES=(
    "4mm grid"
    "5mm grid"
    "Checklist"
    "Millimeter paper"
    "Séyès"
    "Webtoon"
)

TEMPLATE_DIRS=(
    "4mm_grid"
    "5mm_grid"
    "checklist"
    "millimeter_paper"
    "seyes"
    "webtoon"
)

cleanup() {
    rm -rf "$TMP_DIR"
}

pause() {
    read -r -p "Press Enter to return to the main menu..." _
}

is_installed() {
    local directory="${TEMPLATE_DIRS[$1]}"
    local variant

    for variant in "$directory" "${directory}_landscape"; do
        if [ -f "$XOCHITL/$variant.content" ] &&
            [ -f "$XOCHITL/$variant.metadata" ] &&
            [ -f "$XOCHITL/$variant.template" ]; then
            return 0
        fi
    done

    return 1
}

# --------------------------------------------------
# Download and install
# --------------------------------------------------

install_template() {
    local index="$1"
    local mode="${2:-install}"
    local name="${TEMPLATE_NAMES[$index]}"
    local directory="${TEMPLATE_DIRS[$index]}"
    local stage="$TMP_DIR/$directory"
    local backup="$TMP_DIR/$directory.backup"
    local filename
    local variant
    local extension
    local available=0
    local failed=0
    local download_index

    local -a files=()
    local -a copied_files=()
    local -a variants=("$directory" "${directory}_landscape")
    local -a available_variants=()
    local -a variant_pids=()
    local -a download_pids=()
    local -a download_files=()

    echo
    echo "Downloading \"$name\"..."

    if [ "$mode" = update ] && ! is_installed "$index"; then
        echo "This template is not installed."
        return 1
    fi

    mkdir -p "$stage" || {
        echo "Error: Could not create temporary directory."
        return 1
    }

    for variant in "${variants[@]}"; do
        filename="$variant.template"
        wget -q --server-response -O "$stage/$filename" \
            "$REPO/$BRANCH/$directory/$filename" 2>"$stage/$variant.log" &
        variant_pids+=("$!")
    done

    for download_index in "${!variants[@]}"; do
        variant="${variants[$download_index]}"
        if ! wait "${variant_pids[$download_index]}"; then
            if grep -Eq '^[[:space:]]*HTTP/[^[:space:]]+ 404([[:space:]]|$)' "$stage/$variant.log"; then
                continue
            fi
            echo "Error: Could not download $variant.template."
            failed=1
            continue
        fi

        available=$((available + 1))
        available_variants+=("$variant")
    done

    if [ "$failed" -ne 0 ]; then
        cleanup
        return 1
    fi

    if [ "$available" -eq 0 ]; then
        echo "Error: No available variants found for $name."
        cleanup
        return 1
    fi

    for variant in "${available_variants[@]}"; do
        if [ "$mode" = install ] &&
            [ -f "$XOCHITL/$variant.content" ] &&
            [ -f "$XOCHITL/$variant.metadata" ] &&
            [ -f "$XOCHITL/$variant.template" ]; then
            continue
        fi

        files+=("$variant.template")
        for extension in content metadata; do
            filename="$variant.$extension"
            wget -q -O "$stage/$filename" \
                "$REPO/$BRANCH/$directory/$filename" &
            download_pids+=("$!")
            download_files+=("$filename")
            files+=("$filename")
        done
    done

    for download_index in "${!download_pids[@]}"; do
        if ! wait "${download_pids[$download_index]}"; then
            echo "Error: Could not download ${download_files[$download_index]}."
            failed=1
        fi
    done

    if [ "$failed" -ne 0 ]; then
        cleanup
        return 1
    fi

    for filename in "${files[@]}"; do
        if [ "$mode" = install ] && [ -e "$XOCHITL/$filename" ]; then
            echo "Error: $filename already exists on the device."
            echo "No files were installed."
            cleanup
            return 1
        fi
    done

    if [ "$mode" = update ]; then
        mkdir -p "$backup" || {
            echo "Error: Could not create update backup."
            cleanup
            return 1
        }

        for filename in "${files[@]}"; do
            if [ -e "$XOCHITL/$filename" ] &&
                ! cp "$XOCHITL/$filename" "$backup/$filename"; then
                echo "Error: Could not back up $filename."
                cleanup
                return 1
            fi
        done
    fi

    for filename in "${files[@]}"; do
        copied_files+=("$filename")
        if ! cp "$stage/$filename" "$XOCHITL/$filename"; then
            echo "Error: Could not copy $filename."

            for filename in "${copied_files[@]}"; do
                if [ "$mode" = update ] && [ -e "$backup/$filename" ]; then
                    cp "$backup/$filename" "$XOCHITL/$filename"
                else
                    rm -f "$XOCHITL/$filename"
                fi
            done

            echo "Installation rolled back."
            cleanup
            return 1
        fi

    done

    cleanup

    if [ "$mode" = update ]; then
        echo "Successfully updated \"$name\"."
    else
        echo "Successfully installed \"$name\"."
    fi
}

# --------------------------------------------------
# Removal
# --------------------------------------------------

remove_template() {
    local index="$1"
    local name="${TEMPLATE_NAMES[$index]}"
    local directory="${TEMPLATE_DIRS[$index]}"

    echo

    if ! rm -f \
        "$XOCHITL/$directory.content" \
        "$XOCHITL/$directory.metadata" \
        "$XOCHITL/$directory.template" \
        "$XOCHITL/${directory}_landscape.content" \
        "$XOCHITL/${directory}_landscape.metadata" \
        "$XOCHITL/${directory}_landscape.template" ||
        ! rm -rf -- \
            "$XOCHITL/$directory.thumbnails" \
            "$XOCHITL/${directory}_landscape.thumbnails"; then
        echo "Error while removing template files."
        return 1
    fi

    echo "Successfully removed \"$name\"."
}

# --------------------------------------------------
# Main menu
# --------------------------------------------------

show_menu() {
    local i
    local number

    clear

    echo "========================================"
    echo "    Kalamart's reMarkable templates"
    echo "========================================"
    echo
    echo "  q. Exit"

    for i in "${!TEMPLATE_NAMES[@]}"; do
        number=$((i + 1))

        if is_installed "$i"; then
            printf "  %d. [Manage ] %s\n" "$number" "${TEMPLATE_NAMES[$i]}"
        else
            printf "  %d. [Install] %s\n" "$number" "${TEMPLATE_NAMES[$i]}"
        fi
    done

    echo
}

# --------------------------------------------------
# Startup checks
# --------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

if [ ! -d "$XOCHITL" ]; then
    echo "Error: Xochitl directory not found."
    exit 1
fi

if [ "${#TEMPLATE_NAMES[@]}" -ne "${#TEMPLATE_DIRS[@]}" ]; then
    echo "Error: Template names and directories do not match."
    exit 1
fi

if ! command -v wget >/dev/null 2>&1; then
    echo "Error: Required command 'wget' not found."
    exit 1
fi

# --------------------------------------------------
# Interactive loop
# --------------------------------------------------

while true; do
    show_menu

    read -r -p "Select an option [q]: " choice
    choice="${choice:-q}"

    if [[ "$choice" =~ ^[Qq]$ ]]; then
        break
    fi

    if [[ ! "$choice" =~ ^[1-9][0-9]*$ ]] ||
        (( 10#$choice > ${#TEMPLATE_NAMES[@]} )); then
        echo
        echo "Invalid selection."
        pause
        continue
    fi

    index=$((10#$choice - 1))
    name="${TEMPLATE_NAMES[$index]}"

    if is_installed "$index"; then
        echo
        echo "Manage template \"$name\":"
        echo "  q. Cancel"
        echo "  1. Update"
        echo "  2. Remove"
        read -r -p "Select an option [q]: " action
        action="${action:-q}"

        case "$action" in
            1) install_template "$index" update ;;
            2) remove_template "$index" ;;
            q) continue ;;
            *) echo "Invalid selection." ;;
        esac
    else
        read -r -p "Install template \"$name\"? [Y/n]: " confirmation
        case "$confirmation" in
            ""|[Yy]|[Yy][Ee][Ss]) install_template "$index" ;;
            [Nn]|[Nn][Oo]) continue ;;
            *) echo "Invalid selection." ;;
        esac
    fi

    pause
done

echo
echo "Restart your reMarkable device in order to apply changes."

cleanup
