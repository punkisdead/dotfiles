#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# For Searching via web browsers

# Define the path to the config file
config_file=$HOME/.config/hypr/UserConfigs/01-UserDefaults.conf

# Check if the config file exists
if [[ ! -f "$config_file" ]]; then
    echo "Error: Configuration file not found!"
    exit 1
fi

# Process the config file in memory, removing the $ and fixing spaces
config_content=$(sed 's/\$//g' "$config_file" | sed 's/ = /=/')

# Source the modified content directly from the variable
eval "$config_content"

# Check if $term is set correctly
if [[ -z "$Search_Engine" ]]; then
    echo "Error: \$Search_Engine is not set in the configuration file!"
    exit 1
fi

# Get search query from walker
query=$(walker --prompt "Enter search query:")

# Check if query is empty
if [ -z "$query" ]; then
    exit 0
fi

# URL encode the query
encoded_query=$(printf "%s" "$query" | jq -s -R -r @uri)

# Perform the search using the user's specified search engine
search_url="$Search_Engine$encoded_query"

# Open the search URL in the default web browser
xdg-open "$search_url"
