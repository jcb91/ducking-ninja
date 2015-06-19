#!/bin/sh
# adapted from
# https://github.com/miohtama/ztanesh/blob/master/zsh-scripts/bin/setup-sync-sublime-over-dropbox.sh
#
# Set-up Sublime settings + packages sync over a cloud file service like
# Dropbox, or Google Drive
#
# Will sync settings + Installed plug-ins
#

# Note: If there is an existing installation in the specified cloud drive,
# it will replace settings on a local computer

# No Warranty! Use at your own risk.
# Take backup of Library/Application Support/Sublime Text 2 folder first.


CLOUDDRIVE="$HOME/Google Drive"

# Check that cloud folder really exist on this computer
if [ ! -e "$CLOUDDRIVE" ]; then
    echo "Could not find $CLOUDDRIVE"
    exit 1
fi

# Where do we put Sublime settings in our Cloud drive
SYNC_FOLDER="$CLOUDDRIVE/Sublime"


# Where are Sublime settings installed locally?
if [ `uname` = "Darwin" ];then
    SOURCE="$HOME/Library/Application Support/Sublime Text 2"
elif [ `uname` = "Linux" ];then
    SOURCE="$HOME/.config/sublime-text-2"
else
    echo "Unknown operating system"
    exit 1
fi

# Check that local settings really exist on this computer
if [ ! -e "$SOURCE/Packages/" ]; then
    echo "Could not find $SOURCE/Packages/"
    exit 1
fi

# Check for already-symlinked local dir, so that we don't try to install
# twice and screw up
if [ -L "$SOURCE/Packages" ] ; then
    echo "Symlink already exists at $SOURCE/Packages"
    exit 1
fi


# Sync has not been set-up on any computer before?
if [ ! -e "$SYNC_FOLDER" ] ; then
    echo "Setting up cloud sync folder"

    # Creating the folders in separated categories
    mkdir -p "$SYNC_FOLDER/Installed Packages"
    mkdir -p "$SYNC_FOLDER/Packages"

    # Copy the files into their respective folder
    cp -r "$SOURCE/Installed Packages/" "$SYNC_FOLDER/Installed Packages"
    cp -r "$SOURCE/Packages/" "$SYNC_FOLDER/Packages"
fi

# Now that settings are in cloud, delete existing local files
mytempdir=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
echo "copying local settings from $SOURCE to $mytempdir, in case this goes horribly wrong"
cp -r "$SOURCE/Installed Packages" "$mytempdir"
cp -r "$SOURCE/Packages" "$mytempdir"
echo "deleting local settings from $SOURCE"
rm -rf "$SOURCE/Installed Packages"
rm -rf "$SOURCE/Packages"

# Symlink local folders from cloud folder
echo "making symlinks in $SOURCE to point to $SYNC_FOLDER"
ln -s "$SYNC_FOLDER/Installed Packages" "$SOURCE/Installed Packages"
ln -s "$SYNC_FOLDER/Packages" "$SOURCE/Packages"

echo "done!"
