# Ruby/Rails based vimfiles and installer

With the support for ruby, git, rvm, rails, rspec and so on.

## Requirements

Vim 7.3 or better
Tested on MacOS and Linux

Introduction to Vim: http://blog.interlinked.org/tutorials/vim_tutorial.html

## Quick Install

	curl https://raw.github.com/srushti/vim-get/master/install.sh -o - | sh

If you want to add another plugin, just edit the plugins.yml file and add the name & url of the source control of the plugin.

## Basic Mappings

The leader is mapped to `,`

**`Esc` is mapped to `jj`**

### In Normal mode (`Esc` or `jj`)

`,w`     - Save all buffers and place the cursor back to sameplace.

`,W`     - Save all buffers and place the cursor back to sameplace.

`,n`     - File browser (NerdTree Toggle)

`,/`     - File browser (NERDTree Find)

`Space`  - Page Down

`Shift + Space`  - Page Down

`Ctrl + Shift + Right` - Goto Next buffer

`Ctrl + Shift + Left` - Goto Previous buffer

`,a`     - Search in files (Ack)

`,f`     - Search open buffers (Fuzzy Finder like Textmate)

`,d`     - close buffer

`,D`     - close all buffers

`,u`     - GUI Undo history (GUndo) (Needs Python version more than 2.4v)

`,,`     - Toggle between last two buffers


### Open/Edit files

`,ew`   - Open/Edit file in the current directory

`,es`   - Open/Edit file in **HORIZONTAL SPLIT**

`,ev`   - Open/Edit file in **VERTICAL SPLIT**

`,et`   - Open/Edit file in **NEW TAB**

### Execute Ruby Specs

`,s`     - Run one spec under the cursor

`,S`     - Run all specs in the current file

`,-`     - Rerun last rake command (most likely the last run spec)

### In Insert mode (`i`)

`jj` - Back to normal mode(or ESC) #

`uu` - Replaces with the charecter `-`

`hh` - Replaces with the charecter `=>`

`aa` - Replaces with the charecter `@`

`<tab>` - auto complete or expand snippet

See `.vimrc` for more.

## Plugins

### ruby (`F5`)

`F5` Executes the current file.

### rails

*So many* good stuff - get to know this plugin!

`,m`     - Jump to model

`,v`     - Jump to view

`,c`     - Jump to controller

#### Test Ruby Specs

`,s`     - Performs `.Rake` from rails plugin => normal `.rake`

`,S`     - Performs `Rake` from rails plugin => normal `rake`

`,-`     - Perform `Rake -` from rails plugin => normal `rake -`

`:help rails`

### coffee-script

CoffeeScript support

    `:CoffeeCompile watch` show compiled js in split

https://github.com/kchmck/vim-coffee-script

### ruby-block

Provides text-objects for Ruby blocks

    `var` (visual around Ruby)

    `vir` (visual inner Ruby)

    `ar` / `ir` (expand/contract selection)

    `cir` (change inner Ruby)

    `dar` (delete around Ruby)

http://vimcasts.org/blog/2010/12/a-text-object-for-ruby-blocks/

### sparkup (`ctrl+e`)

Expand CSS selectors `div.event` in to markup `<div class='event'></div>`

http://net.tutsplus.com/articles/general/quick-tip-even-quicker-markup-with-sparkup/

### fugitive

Git integration

`,gd`    - Git diff

`,gs`    - Git status press `-` to stage file

`,gw`    - Git write

`,ga`    - Git add

`,gb`    - Git blame

`,gco`   - Git checkout

`,gci`   - Git commit

`,gm`    - Git move

`,gr`    - Git remove

`:help fugitive`

http://vimcasts.org/episodes/fugitive-vim---a-complement-to-command-line-git/

### snippets usage (`TAB`)

Snippets, press `TAB` to expand

Examples (in a Ruby file):

`def<tab>`

`.each<tab>`

`.eado<tab>`

`ife<tab>`

### gundo (`,u`)

Navigate changes history tree

http://vimcasts.org/episodes/undo-branching-and-gundo-vim/

### conque

Terminal/Interactive programs

`:Conque zsh`

`:Conque ls`

Note you can also drop back to the terminal using Ctrl+Z, to get
back to Vim with `%1`. This is not a feature of Conque.

### yankring

Shows history of yanked (copied) text

Pressing `ctrl + p` will also cycle through paste history

### ack (`,a`)

Search project for text (aka find in files)

`,a word`

`,a "some words"`

### nerdtree (`,n`)

Project file browser

`,n` opens file browser

`o` / `x` open and close files/folders

`m` menu to move/delete/copy files/folders

`?` Help

I use nerdtree for creating or moving files, but find command-t quicker for
opening files.

### surround (`ys`/`cs`/`ds`)

Allows adding/removing/changing of surroundings

I would highly recommend getting to know this plugin, it is very useful.
Especially when you grok text objects.

*Characters*

`ysiw)`    - surround inner word with `()`

`ysiw(`    - surround inner word with `(  )`

In the above example `iw` can be replaced with any text object or motion.

If you find yourself manually adding surroundings, stop and work out the
correct text object or motion.

`cs"'`     - change surrounding from `"` to `'`

`ds`       - delete surrounding

### Install these vimfiles manually

Note: You will already have a `~/.vim` folder, either delete or move it.

	cp -r ~/.vim ~/.vim.old 2>/dev/null
	rm -fr ~/.vim 2>/dev/null
	rm -f ~/.vimrc 2>/dev/null
	git clone https://github.com/srushti/vim-get.git ~/.vim && cd ~/.vim && rake update

or run:

    curl https://raw.github.com/ravidsrk/vim-get/master/install.sh -o - | sh

#### To update to the latest vimfiles

    cd ~/.vim
    rake preinstall

#### Install Dependacies

*MacOS*

    brew install ack
    brew install ctags

Note: MacOS comes with the BSD version of ctags which is not compatible.

*Ubuntu*

    sudo apt-get install exuberant-ctags
    sudo apt-get install ack-grep
    sudo ln -s /usr/bin/ack-grep /usr/local/bin/ack
