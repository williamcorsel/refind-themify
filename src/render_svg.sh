#!/usr/bin/env bash
INKSCAPE=`which inkscape 2> /dev/null`
OPTIPNG=`which optipng 2> /dev/null`

THEME_PATH=$1
BACKGROUND_PATH=$2
BIG_ICON_SIZE=$3
SMALL_ICON_SIZE=$4
OUT_DIR="icons"
DPI=96
SCALE=1

mkdir -p $OUT_DIR

render_icons () {
    SRC_DIR=$1
    OUT_DIR=$2

    for svgfile in $(ls $SRC_DIR | grep .svg)
    do
        # echo $svgfile
        filename=${svgfile%%.*}
        if [ -f "$OUT_DIR/$filename.png" ]
            then
                echo "'$OUT_DIR/$filename.png' already exists"
            else
                echo "Creating... $OUT_DIR/$filename.png"
                $INKSCAPE --export-area-page \
                            --export-overwrite \
                            --export-dpi=$(($SCALE*$DPI)) \
                            --export-filename="$OUT_DIR/$filename.png" $SRC_DIR/$svgfile &> /dev/null \
                &&
                if [[ -x $OPTIPNG ]]
                    then
                        $OPTIPNG -o7 --quiet "$OUT_DIR/$filename.png"
                fi

        fi
    done

    for file in $(ls $SRC_DIR | grep .png)
    do
        file=$(basename "$file")
        echo "Copying $file..."
        cp $SRC_DIR/$file $OUT_DIR/$file
    done
}

render_icons "$THEME_PATH/big" "$OUT_DIR"
render_icons "$THEME_PATH/small" "$OUT_DIR"
render_icons "$THEME_PATH/selection" "$OUT_DIR"
render_icons "$BACKGROUND_PATH" "$OUT_DIR"
