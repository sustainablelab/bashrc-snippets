# git-log
alias gitlog='git log --date=short --pretty=format:"- %Cblue %cd %Cred %d %Creset %s"'
alias gitlogs='git log --oneline --stat --date=short --pretty="format:%C(auto)%h %ad: %s"'
alias gitlogf='git log --stat --oneline HEAD..FETCH_HEAD'

# Git SSH just works on Linux.
# But on Windows (MSYS and Cygwin), I need to `gitssh` the first
# time I do Git stuff in a session.
alias gitssh='eval "$(ssh-agent -s)"; ssh-add ~/.ssh/github_key'

