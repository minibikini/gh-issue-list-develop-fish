# gh-issue-list-develop-fish
#
# A GitHub CLI extension for interactive issue selection
# and branch creation
#
# Full README and source code:
#
#   https://github.com/minibikini/gh-issue-list-develop-fish
#
# USAGE:
#
#   gh issue-list-develop-fish
#
# For easier usage, you can create an alias:
#
#   gh alias set ild issue-list-develop-fish
#
# Then simply use: `gh ild`
#
# DESCRIPTION:
#   List issues interactively and create a branch
#   for the chosen issue.
#
# FEATURES:
#   - Interactive fuzzy finder using `fzf` over `gh issue list`
#   - Automatic branch creation using `gh issue develop`
#
# REQUIREMENTS:
#   - fish (https://fishshell.com/) - a command line shell
#   for the 90s
#   - gh (https://cli.github.com/) - GitHub CLI
#   - fzf (https://github.com/junegunn/fzf) - a command-line
#   fuzzy finder
#
# WORKFLOW:
#   1. Lists all open issues from the current repository
#   2. Allows interactive filtering and selection using `fzf`
#   3. Creates a development branch for the selected issue
#
# NOTES:
#   - Must be run from within a GitHub repository
#   - Requires appropriate GitHub permissions
#   - Branch name is automatically generated based on the issue title

function gh-issue-list-develop-fish --description "Quick branch creation from GitHub issues"
    # Get terminal width
    set -l term_width (tput cols)

    # Calculate column widths based on terminal width
    set -l id_width 6
    set -l updated_width 15
    set -l labels_width 20
    set -l title_width (math "$term_width - $id_width - $labels_width - $updated_width - 4")

    # Define color codes
    set yellow (printf '\033[33m')
    set white (printf '\033[37m')
    set gray (printf '\033[90m')
    set reset (printf '\033[0m')

    # Store header separately
    set header (printf "  $gray%-*s %-*s %-*s %s$reset\n" \
        $id_width "ID" \
        $title_width "TITLE" \
        $labels_width "LABELS" \
        "UPDATED")

    # Get and format the issues
    set issues (gh issue list --json number,title,labels,updatedAt --template '{{range .}}{{printf "%v\t%s\t%s\t%s\n" .number .title (join "," (pluck "name" .labels)) (timeago .updatedAt)}}{{end}}')

    # Process and format each issue
    set formatted_issues
    for issue in $issues
        # Split the issue data
        set -l parts (string split \t $issue)
        set -l number $parts[1]
        set -l title $parts[2]
        set -l labels $parts[3]
        set -l updated $parts[4]

        # Truncate and word wrap the title
        set -l wrapped_title (string shorten -m $title_width "$title")

        # Truncate labels if too long
        set -l formatted_labels (string shorten -m $labels_width "$labels")

        # Format the line
        set -a formatted_issues (printf "  $yellow#%-*s $white%-*s $gray%-*s %s$reset\n" \
            (math "$id_width - 1") $number \
            $title_width $wrapped_title \
            $labels_width $formatted_labels \
            $updated)
    end

    # Calculate height: number of issues + 2 for padding
    set issue_count (count $formatted_issues)
    set fzf_height (math "$issue_count + 2")

    # Use `fzf` for selection - print header first, then pipe formatted issues
    set selected_issue (begin
        echo $header
        printf "%s\n" $formatted_issues
    end | fzf --height=$fzf_height --layout=reverse-list --header-lines=1 --ansi)

    printf "\033[1A\033[2K"
    if test -n "$selected_issue"
        # Match issue number
        set issue_number (string match -r '#([0-9]+)' $selected_issue)[2]

        if test -n "$issue_number"
            gh issue develop "#$issue_number" -c
        end
    end
end
