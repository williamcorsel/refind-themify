<img src="etc/screenshot_dark.bmp" align="right" width=300 />

# refind-themify
Easily theme rEFInd using a commandline interface. This repository contains some example themes based on [this](https://github.com/bobafetthotmail/refind-theme-regular) project. The install script has the following options:

* Select theme icon pack.
* Select background image (`png` or `svg`).
* Set icon size.
* Set font.
* Set font size.
* Enable/Disable UI.

## Installation

1. Clone the git repository:
   ```
    git clone https://github.com/williamcorsel/refind-themify.git
    ```
3. Install dependencies: Inkscape, OptiPNG, and ImageMagick.
    ```
    sudo apt-get install inkscape
    sudo apt-get install optipng
    sudo apt-get install imagemagick
    ```
2. Run the install script:
    ```
    sudo ./install.sh
    ```
3. Fill in the script interaction prompts to set the wanted options.

## Usage

The script will ask you to fill in the following options:

1. Set the install path. If your rEFInd install is not placed in the default `/boot/efi/EFI/refind/` location, change this here.

2. Select icons. The script looks for icon themes in the `themes` folder. This folder currently contains some example icons in `svg` format. See [here](THEMES.md) how they look.

3. Select a background image. The script looks for background images (`svg` or `png`) in the `backgrounds` folder. 

4. Select the icon size. A few default values are provided. The `svg` icons will be converted to `png` at the requested icon size.

5. UI options. You can choose to hide certain UI elements for a cleaner look. `text-only` will remove the text hints that are displayed by default. `all` will also remove all of the secondary options. See [here](https://www.rodsbooks.com/refind/configfile.html) for more details.

6. Pick a font & font size. Leaving this empty will use rEFInd's default font. Otherwise a new font image file will be created.

## Create a new theme

1. Create a new subfolder in the `themes` folder with the name of your theme.
2. Create three new subfolders `big`, `small`, `selection` in this theme folder.
3. Place your theme icons in `svg` format in their respective folder. The icon size must have a width and height of 128 px for the big icons and 48 px for the small icons. Use the standard image file names as presented in the included themes.

## Links

* Official [rEFInd website](https://www.rodsbooks.com/refind/)
