My Windows dotfiles with automated installation of dependencies and configuration of multiple toys to enjoy in your Terminal.

## Requirements

- Windows Terminal (pre-installed with Windows 11)
- PowerShell 7
- Git
- scoop

## How to install

- Clone the repo (I personally prefer to put it under the `~/.config` folder).
- Run the `install.ps1` script file from an elevated `pwsh` prompt (you can use [Sudo for Windows](https://github.com/gerardog/gsudo) if you have it already installed).

## Features

- Centralized and easy configuration management for multiple tools (Windows Terminal, Neovim, Starship, WezTerm and many more!) 
- Automated checks and installation of Dependencies.
- Installation of WSL pre-requisites to be able to use Linux within Windows.

## Documentation

- Check the [Wiki]() if you need more guidance to personalize the dotfiles to your liking.

## Contributions

If you care to contribute to this repo, open a pull request or an issue. Suggestions or questions are welcome on my [Discord]().

## Roadmap

- Add support for .NET Development with Neovim (Syntax Coloring, Intellisense, Compilation and Debugging).
- Automate the installation of Arch Linux in WSL.
- Add dotfiles for Arch Linux.
