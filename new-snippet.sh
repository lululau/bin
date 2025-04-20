#!/bin/bash

# Create a new Alfred snippet

list_mode=false
category_list_mode=false
filter=""

# Process options
while getopts "lc" opt; do
    case $opt in
        l)
            list_mode=true
            ;;
        c)
            category_list_mode=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

# Check for mutually exclusive options
if $list_mode && $category_list_mode; then
    echo "Error: Options -l and -c cannot be used together"
    exit 1
fi

# Shift processed options
shift $((OPTIND-1))

# If in list mode and there's an argument, use it as filter
if $list_mode && [ $# -gt 0 ]; then
    filter="$1"
    shift
fi

if [ -z "$ALFRED_PREFERENCES_DIR" ]; then
    ALFRED_PREFERENCES_DIR="$HOME/.alfred"
fi

SNIPPETS_DIR="$ALFRED_PREFERENCES_DIR/Alfred.alfredpreferences/snippets"

# Function to check if string contains uppercase letters
has_uppercase() {
    if [[ "$1" =~ [A-Z] ]]; then
        return 0  # true
    else
        return 1  # false
    fi
}

# Function to convert string to lowercase
to_lowercase() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Function to list only categories
list_categories() {
    if [ ! -d "$SNIPPETS_DIR" ]; then
        echo "No snippets directory found at: $SNIPPETS_DIR"
        exit 1
    fi
    
    echo "Categories:"
    for category in "$SNIPPETS_DIR"/*; do
        if [ -d "$category" ]; then
            basename "$category"
        fi
    done
}

# Function to list snippets in a tree structure
list_snippets() {
    if [ ! -d "$SNIPPETS_DIR" ]; then
        echo "No snippets directory found at: $SNIPPETS_DIR"
        exit 1
    fi
    
    # Check if we should do case-sensitive matching
    case_sensitive=false
    if [ -n "$filter" ] && has_uppercase "$filter"; then
        case_sensitive=true
    fi
    
    echo "Snippets:"
    for category in "$SNIPPETS_DIR"/*; do
        if [ -d "$category" ]; then
            category_name=$(basename "$category")
            category_has_match=false
            
            # Check if category name matches the filter
            if [ -n "$filter" ]; then
                if $case_sensitive; then
                    # Case-sensitive matching for category
                    if [[ "$category_name" == *"$filter"* ]]; then
                        category_has_match=true
                    fi
                else
                    # Case-insensitive matching for category
                    lower_category_name=$(to_lowercase "$category_name")
                    lower_filter=$(to_lowercase "$filter")
                    if [[ "$lower_category_name" == *"$lower_filter"* ]]; then
                        category_has_match=true
                    fi
                fi
            fi
            
            # If category name doesn't match, check if any snippets match
            if [ -n "$filter" ] && ! $category_has_match; then
                while read -r snippet_file; do
                    filename=$(basename "$snippet_file")
                    snippet_name=$(echo "$filename" | sed -E 's/ \[[0-9a-fA-F-]+\]\.json$//')
                    
                    if $case_sensitive; then
                        # Case-sensitive matching
                        if [[ "$snippet_name" == *"$filter"* ]]; then
                            category_has_match=true
                            break
                        fi
                    else
                        # Case-insensitive matching
                        lower_snippet_name=$(to_lowercase "$snippet_name")
                        lower_filter=$(to_lowercase "$filter")
                        if [[ "$lower_snippet_name" == *"$lower_filter"* ]]; then
                            category_has_match=true
                            break
                        fi
                    fi
                done < <(find "$category" -type f -name "*.json")
            else
                # If no filter or category directly matched, show this category
                category_has_match=true
            fi
            
            # Only proceed if this category has matching snippets or matched itself or no filter is applied
            if $category_has_match; then
                echo "├── $category_name"
                
                find "$category" -type f -name "*.json" | while read -r snippet_file; do
                    # Extract just the filename
                    filename=$(basename "$snippet_file")
                    # Extract snippet name without UUID
                    snippet_name=$(echo "$filename" | sed -E 's/ \[[0-9a-fA-F-]+\]\.json$//')
                    
                    # If filter is provided, only display matching snippets
                    if [ -z "$filter" ]; then
                        echo "│   ├── $snippet_name"
                    elif $case_sensitive; then
                        # Case-sensitive matching
                        if [[ "$snippet_name" == *"$filter"* ]]; then
                            echo "│   ├── $snippet_name"
                        fi
                    else
                        # Case-insensitive matching
                        lower_snippet_name=$(to_lowercase "$snippet_name")
                        lower_filter=$(to_lowercase "$filter")
                        if [[ "$lower_snippet_name" == *"$lower_filter"* ]]; then
                            echo "│   ├── $snippet_name"
                        fi
                    fi
                done
            fi
        fi
    done
}

# If in category list mode, show categories and exit
if $category_list_mode; then
    list_categories
    exit 0
fi

# If in list mode, show snippets and exit
if $list_mode; then
    list_snippets
    exit 0
fi

# Regular snippet creation mode
if [ -z "$1" ]; then
    echo "Usage: $0 [-l [filter] | -c] <category>/<snippet-name> [content]"
    echo "  -l: List existing snippets, optionally filtered by the given string"
    echo "  -c: List all categories"
    echo "  If content is not provided as argument, it will be read from stdin"
    echo "  Example: $0 coding/bash-loop"
    echo "  Example: $0 coding/bash-loop 'for i in \"\$@\"; do'"
    exit 1
fi

# Check if the parameter format is correct
if [[ ! "$1" =~ ^[^/]+/[^/]+$ ]]; then
    echo "Error: Parameter format should be 'category/snippet-name'"
    echo "Example: $0 coding/bash-loop"
    exit 1
fi

# Split the parameter into category and snippet name
category=$(echo "$1" | cut -d'/' -f1)
snippet_name=$(echo "$1" | cut -d'/' -f2)

snippet_dir="$SNIPPETS_DIR/$category"

if [ -e "$snippet_dir" -a ! -d "$snippet_dir" ]; then
    echo "Error: '$snippet_dir' exists but is not a directory"
    exit 1
fi

if [ ! -d "$snippet_dir" ]; then
    echo "Creating directory '$snippet_dir'"
    mkdir -p "$snippet_dir"
fi

uid=$(uuidgen)

snippet_file="$snippet_dir/$snippet_name [$uid].json"

# Get snippet content from second argument or open nvim for editing
if [ -n "$2" ]; then
    snippet_content="$2"
else
    # Create a temporary file for editing
    temp_file=$(mktemp)
    
    # Open nvim for editing
    nvim "$temp_file"
    
    # Read the content from temp file
    snippet_content=$(<"$temp_file")
    
    # Remove the temporary file
    rm "$temp_file"
fi

if [ -z "$snippet_content" ]; then
    echo "Error: No snippet content provided"
    exit 1
fi

escaped_snippet_content=$(python -c "import json, sys; print(json.dumps(sys.stdin.read())[1:-1])" <<< "$snippet_content")

cat <<EOF > "$snippet_file"
{
  "alfredsnippet" : {
    "snippet" : "$escaped_snippet_content",
    "dontautoexpand" : true,
    "uid" : "$uid",
    "name" : "$snippet_name",
    "keyword" : "$snippet_name",
  }
}
EOF

echo "Snippet created: $snippet_file"
