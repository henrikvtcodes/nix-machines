
# --------- Move terminal prompt up while preserving content ---------
# https://superuser.com/questions/1389834/can-i-have-the-terminal-prompt-at-the-vertical-middle-of-a-window
# Get ceiling eg: 7/2 = 4
ceiling_divide() {
  ceiling_result=$((($1+$2-1)/$2))
}

clear_rows() {
  POS=$1
  # Insert Empty Rows to push & preserve the content of screen
  for i in {1..$((LINES-POS-1))}; echo
  # Move to POS, after clearing content from POS to end of screen
  tput cup $((POS-1)) 0
}

# Clear quarter
alias ptop='ceiling_divide $LINES 4; clear_rows $ceiling_result'
# Clear half
alias pmid='ceiling_divide $LINES 2; clear_rows $ceiling_result'
# Clear 3/4th
alias pdown='ceiling_divide $((3*LINES)) 4; clear_rows $ceiling_result'
