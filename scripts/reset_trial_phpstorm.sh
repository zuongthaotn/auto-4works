#!/bin/bash

RESET_STATUS=true

if [ -d "$HOME/.config/JetBrains" ]; then
    cd "$HOME/.config/JetBrains" || exit 1

    DIR=$(find . -maxdepth 1 -type d -iname "*PhpStorm*" | head -n 1)

    if [ -n "$DIR" ]; then
        rm -rf "$HOME/.config/JetBrains/$DIR/options/other.xml"
    else
        echo "No PhpStorm found in ~/.config/JetBrains"
        RESET_STATUS=false
    fi
else
    echo "Folder ~/.config/JetBrains does not exist"
    RESET_STATUS=false
fi


if [ -d "$HOME/.java/.userPrefs/jetbrains" ]; then
    rm -rf "$HOME/.java/.userPrefs/jetbrains"
else
    echo "Folder ~/.java/.userPrefs/jetbrains does not exist"
fi


if [ "$RESET_STATUS" = true ]; then
    echo "The reset PhpStorm trial is done successfully"
else
    echo "The reset PhpStorm trial FAILED"
fi
