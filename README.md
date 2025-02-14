# GitHub CLI Extension: `gh-issue-list-develop-fish` (Fish Shell)

An interactive GitHub CLI extension for quick branch creation from GitHub issues.

## Usage

```fish
gh issue-list-develop-fish
```

For easier usage, you can create an alias:

```fish
gh alias set ild issue-list-develop-fish
```

Then simply use: `gh ild`

## Features

- Interactive fuzzy finder using `fzf` over `gh issue list`
- Automatic branch creation using `gh issue develop`

## Requirements

- [`fish`](https://fishshell.com/) – a command line shell for the 90s
- [`gh`](https://cli.github.com/) - GitHub CLI
- [`fzf`](https://github.com/junegunn/fzf) - a command-line fuzzy finder

## Installation

To install this extension, simply run:

```fish
gh extension install minibikini/gh-issue-list-develop-fish
```

## Workflow

1. Lists all open issues from the current repository
2. Allows interactive filtering and selection using `fzf`
3. Creates a development branch for the selected issue

## Notes

- Must be run from within a GitHub repository
- Requires appropriate GitHub permissions
- Branch name is automatically generated based on the issue title

## Similar Projects

- [`gh-workon`](https://github.com/chmouel/gh-workon/) (Bash)
