#!/bin/bash
cd
ln -sfv .vim/vimrc-`whoami` .vimrc
cd - >&/dev/null
