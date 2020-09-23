#!/data/data/com.termux/files/usr/bin/bash
## ANSI Colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
DEFAULT_FG="$(printf '\033[39m')"  DEFAULT_BG="$(printf '\033[49m')"

## Directories
PREFIX='/data/data/com.termux/files/usr'
TERMUX_DIR="$HOME/.termux"
COLORS_DIR="$PREFIX/share/termux-style/colors"
FONTS_DIR="$PREFIX/share/termux-style/fonts"

## Banner
banner () {
    clear
    echo "
    ${RED}┌┬┐  ┌─┐  ┬─┐  ┌┬┐  ┬ ┬  ─┐ ┬ ${WHITE}      ┌┬┐  ┬ ┬  ┌─┐  ┌┬┐  ┌─┐
    ${RED} │   ├┤   ├┬┘  │││  │ │  ┌┴┬┘ ${BLUE} ─── ${WHITE}  │   ├─┤  ├┤   │││  ├┤
    ${RED} ┴   └─┘  ┴└─  ┴ ┴  └─┘  ┴ └─ ${WHITE}       ┴   ┴ ┴  └─┘  ┴ ┴  └─┘

    ${BLUE}[${RED}*${BLUE}] ${ORANGE}By: An brush fon"
}

## Script Termination
exit_on_signal_SIGINT () {
    { printf "\n\n%s\n" "    ${BLUE}[${RED}*${BLUE}] ${RED}Script interrupted." 2>&1; echo; reset_color; }
    exit 0
}

exit_on_signal_SIGTERM () {
    { printf "\n\n%s\n" "    ${BLUE}[${RED}*${BLUE}] ${RED}Script terminated." 2>&1; echo; reset_color; }
    exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Reset terminal colors
reset_color() {
	tput sgr0   # reset attributes
	tput op     # reset color
    return
}

## Available color-schemes & fonts
check_files () {
    if [[ "$1" = colors ]]; then
        colors=($(ls $COLORS_DIR))
        echo ${#colors[@]}
    elif [[ "$1" = fonts ]]; then
        fonts=($(ls $FONTS_DIR))
        echo ${#fonts[@]}
    fi
    return
}

total_colors=$(check_files colors)
total_fonts=$(check_files fonts)

## Reload Settings
reload_settings () {
    echo "    ${BLUE}[${RED}*${BLUE}] ${MAGENTA}Reloading Settings..."
    am broadcast --user 0 -a com.termux.app.reload_style com.termux > /dev/null
    { echo "    ${BLUE}[${RED}*${BLUE}] ${GREEN}Applied Successfully."; echo; }
    return
}

## Apply color-schemes
apply_colors () {
    local count=1

    # List the color-schemes
    color_schemes=($(ls $COLORS_DIR))
    for colors in "${color_schemes[@]}"; do
        colors_name=$(echo $colors)
        echo ${ORANGE}"    [$count] ${colors_name%.*}"
        count=$(($count+1))
    done

    # Read user selection
    { echo; read -p ${BLUE}"    [${RED}Pilih warna (1 - $total_colors)${BLUE}]: ${GREEN}" answer; echo; }

    # Apply color-scheme
    if [[ (-n "$answer") && ("$answer" -le $total_colors) ]]; then
        scheme=${color_schemes[(( answer - 1 ))]}
        echo "    ${BLUE}[${RED}*${BLUE}] ${ORANGE}Applying Color Scheme..."
        cp $COLORS_DIR/$scheme $TERMUX_DIR/colors.properties
        { reload_settings; reset_color; exit; }
    else
        echo -n "    ${BLUE}[${RED}!${BLUE}] ${RED}Invalid Option, Try Again."
        { sleep 2; banner; echo; apply_colors; }
    fi
    return
}

## Apply fonts
apply_fonts () {
    local count=1

    # List fonts
    fonts_list=($(ls $FONTS_DIR))
    for fonts in "${fonts_list[@]}"; do
        fonts_name=$(echo $fonts)
        echo ${ORANGE}"    [$count] ${fonts_name%.*}"
        count=$(($count+1))
    done

    # Read user selection
    { echo; read -p ${BLUE}"    [${RED}Select font (1 to $total_fonts)${BLUE}]: ${GREEN}" answer; echo; }

    # Apply fonts
    if [[ (-n "$answer") && ("$answer" -le $total_fonts) ]]; then
        font_ttf=${fonts_list[(( answer - 1 ))]}
        echo "    ${BLUE}[${RED}*${BLUE}] ${ORANGE}Applying Fonts..."
        cp $FONTS_DIR/$font_ttf $TERMUX_DIR/font.ttf
        { reload_settings; reset_color; exit; }
    else
        echo -n "    ${BLUE}[${RED}!${BLUE}] ${RED}Invalid Option, Try Again."
        { sleep 2; banner; echo; apply_fonts; }
    fi
    return
}

## Random style
random_style () {
    echo "    ${BLUE}[${RED}*${BLUE}] ${ORANGE}Setting Random Style..."
    random_scheme=$(ls $COLORS_DIR | shuf -n 1)
    { cp $COLORS_DIR/$random_scheme $TERMUX_DIR/colors.properties; }
    { reload_settings; reset_color; exit; }
}

## Main menu
until [[ "$REPLY" =~ ^[q/Q]$ ]]; do
    banner
    echo "
    ${BLUE}[${RED}c${BLUE}] ${WHITE}Colors ($total_colors)
    ${BLUE}[${RED}f${BLUE}] ${WHITE}Fonts ($total_fonts)
    ${BLUE}[${RED}r${BLUE}] ${WHITE}Random
    ${BLUE}[${RED}q${BLUE}] ${RED}Quit
    "

    { read -p ${BLUE}"    [${RED}Select Option${BLUE}]: ${GREEN}"; echo; }

    if [[ "$REPLY" =~ ^[c/C/f/F/r/R/i/I/a/A/q/Q]$ ]]; then      #validate input
        if [[ "$REPLY" =~ ^[c/C]$ ]]; then
            apply_colors
        elif [[ "$REPLY" =~ ^[f/F]$ ]]; then
            apply_fonts
        elif [[ "$REPLY" =~ ^[r/R]$ ]]; then
            random_style
        fi
    else
        echo -n "    ${BLUE}[${RED}!${BLUE}] ${RED}Invalid Option, Try Again."
        sleep 2
    fi
done
{ echo "    ${BLUE}[${RED}*${BLUE}] ${RED}TERIMA KASIH SUDAH MENGGUNAKAN TOOLS KAMI"; echo; reset_color; exit 0; }
