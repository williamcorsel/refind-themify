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

## Create a new theme

1. Create a new subfolder in the `themes` folder with the name of your theme.
2. Create three new subfolders `big`, `small`, `selection` in this theme folder.
3. Place your theme icons in `svg` format in their respective folder. The icon size must have a width and height of 128 px for the big icons and 48 px for the small icons. Use the standard image file names as presented in the included themes.

## Links

* Official [rEFInd website](https://www.rodsbooks.com/refind/)

