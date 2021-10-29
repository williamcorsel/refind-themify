#!/usr/bin/env bash

#Check if root
[[ $EUID -ne 0 ]] && echo "This script must be run as root." && exit 1

#Useful formatting tags
bold=$(tput bold)
normal=$(tput sgr0)

REFIND_THEMES_FOLDER="themes"
BACKGROUND_HOME="src/backgrounds"
THEMES_HOME="src/themes"
FONT_HOME="src/fonts"

# Find backgrounds in folder
backgrounds=()
background_str="Options: "

# Check dependencies

if ! command -v inkscape &> /dev/null
then
    echo "Inkscape not found!"
    exit
fi

if ! command -v optipng &> /dev/null 
then
    echo "Optipng not found!"
    exit
fi

if ! command -v convert &> /dev/null
then
    echo "Convert not found!"
    exit
fi

# Check backgrounds
FILES=$(ls $BACKGROUND_HOME/*.{svg,png} 2>/dev/null)
for file in $FILES
do
    basename=$(basename "$file")
  
    backgrounds+=($basename) # Remove everything after first dot
    background_str+="$basename "
   
done

# Find themes in folder
themes=()
themes_str="Options: "

FOLDERS="$THEMES_HOME/*"
for folder in $FOLDERS
do
    basename=$(basename "$folder")
    themes+=($basename) 
    themes_str+="$basename "
done

# Set install path
echo "Enter rEFInd install location:"
read -e -p "Default - ${bold}/boot/efi/EFI/refind/${normal}: " location
if test -z "$location" 
then
    location="/boot/efi/EFI/refind/"
fi
if test "${location: -1}" != "/" 
then
    location="$location/"
fi
echo

# Select theme
echo "Select a theme:"
read -p "$themes_str: " theme_name
if test -z "$theme_name";
then
    theme_name=${themes[0]}
fi
if [[ " ${themes[*]} " =~ " $theme_name " ]]
then
    theme_path="$THEMES_HOME/$theme_name"
    echo $theme_path
else
    echo "Incorrect choice. Exiting."
    exit 1
fi
echo

# Set background
echo "Pick a background:"
read -p "$background_str: " background_name
if test -z "$background_name";
then
    background_name=${backgrounds[0]}
fi
if [[ "${backgrounds[*]}" =~ "$background_name" ]]
then
    background_path="$BACKGROUND_HOME/$background_name"
    echo $background_path
    if [[ "${background_name##*.}" == "svg" ]]
    then
        background_name="${background_name%.*}.png"
    fi
else
    echo "Incorrect choice. Exiting."
    exit 1
fi
echo

# Set icon size
echo "Pick an icon size:"
read -p "${bold}1: small (128px-48px)${normal}, 2: medium (256px-96px), 3: large (384px-144px), 4: extra-large (512px-192px): " size_select
if test -z "$size_select";
then
    size_select=1
fi
case "$size_select" in
    1)
        size_big="128"
        size_small="48"
        ;;
    2)
        size_big="256"
        size_small="96"
        ;;
    3)
        size_big="384"
        size_small="144"
        ;;
    4)
        size_big="512"
        size_small="192"
        ;;
    *)
        echo "Incorrect choice. Exiting."
        exit 1
        ;;
esac
echo

# Hide UI elements
echo "Hide ui elements:"
read -p "${bold}1: Text only${normal}, 2: All, 3: None: " hide_ui
if test -z "$hide_ui";
then
    hide_ui="1"
fi
echo

# Select font and font size
echo "Pick a font:"
read -p "Default - ${bold}Ubuntu-Mono${normal}: " select_font
if test -z "$select_font";
then
    select_font="Ubuntu-Mono"
fi
echo

echo "Pick a font size:"
read -p "Default - ${bold}14${normal}: " font_size
if test -z "$font_size";
then
    font_size=14
fi
echo

# Generate font
bash src/font2png.sh -f $select_font -s $font_size "$FONT_HOME/$select_font-$font_size.png"

# Generate icons
bash src/render_svg.sh $theme_path $BACKGROUND_HOME $size_big $size_small 

# Generate theme.conf
echo -n "Generating theme file theme.conf"
echo "icons_dir $REFIND_THEMES_FOLDER/$theme_name/icons" > theme.conf
echo "big_icon_size $size_big" >> theme.conf
echo "small_icon_size $size_small" >> theme.conf
echo "banner $REFIND_THEMES_FOLDER/$theme_name/icons/$background_name" >> theme.conf
echo "banner_scale fillscreen" >> theme.conf
echo "selection_big $REFIND_THEMES_FOLDER/$theme_name/icons/selection-big.png" >> theme.conf
echo "selection_small $REFIND_THEMES_FOLDER/$theme_name/icons/selection-small.png" >> theme.conf
echo "font $REFIND_THEMES_FOLDER/$theme_name/font.png" >> theme.conf
case "$hide_ui" in
    1)
        echo "hideui label,hints" >> theme.conf
        ;;
    2)
        echo "hideui label,hints,editor" >> theme.conf
        ;;
esac
echo " - [DONE]"

#Remove previous installs
echo -n "Deleting older installed versions (if any)"
rm -rf "$location/$REFIND_THEMES_FOLDER/$theme_name"
echo " - [DONE]"

#Copy theme setup folders
echo -n "Copying theme to $location"
mkdir -p "$location/$REFIND_THEMES_FOLDER/$theme_name"
cp -r "icons" "$location/$REFIND_THEMES_FOLDER/$theme_name/icons"
cp "$FONT_HOME/$select_font-$font_size.png" "$location/$REFIND_THEMES_FOLDER/$theme_name/font.png"
cp "theme.conf" "$location/$REFIND_THEMES_FOLDER/$theme_name/theme.conf" 
echo " - [DONE]"
echo

#Edit refind.conf - remove older themes
echo "Removing old themes from refind.conf"
echo "Do you have a secondary config file to preserve?"
read -p "(y/${bold}N${normal}): " config_confirm
if test -z "$config_confirm";
then
    config_confirm="n"
fi
case "$config_confirm" in
    y|Y)
        read -p "Enter the name of the config file to be preserved in full eg: manual.conf: " configname
        # Checking for enter key. If so it has the same effect having no files to preserve.
        if [[ $configname == "" ]]
        then
            configname='^#'
        fi
        #Excludes line with entered config file then ^\s*include matches lines starting with any nuber of spaces and then include.
        sed --in-place=".bak" "/$configname/! s/^\s*include/# (disabled) include/" "$location"refind.conf
        ;;
    n|N)
        # ^\s*include matches lines starting with any nuber of spaces and then include.
        sed --in-place=".bak" '/^\s*# (disabled)/d' "$location"refind.conf
        sed --in-place=".bak" 's/^\s*include/# (disabled) include/' "$location"refind.conf
        ;;
    *)
        ;;
esac
echo " - [DONE]"
echo

# Edit refind.conf - add new theme
echo -n "Updating refind.conf"
echo "
include $REFIND_THEMES_FOLDER/$theme_name/theme.conf" | tee -a "$location"refind.conf &> /dev/null
echo " - [DONE]"
echo

# Clean up
echo "Cleanup files:"
read -p "(${bold}Y${normal}/n): " del_confirm
if test -z "$del_confirm";
then
    del_confirm="y"
fi
case "$del_confirm" in
    y|Y)
        echo -n "Cleaning up"
        rm -r icons
        rm theme.conf
        echo " - [DONE]"
        ;;
    *)
        ;;
esac
echo

echo "Finished applying theme $theme_name"
echo "Install path: $location"
echo "Background: $background_name"
echo "Icon size: $size_big - $size_small"
echo "Font: $select_font $font_sizept"
echo "Hide ui: $hide_ui"