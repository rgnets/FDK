#!/bin/bash

# Git commit helper script for RG Nets FDK project
# Usage: ./scripts/commit.sh "type" "message" "description"

TYPE=$1
MESSAGE=$2
DESCRIPTION=$3

if [ -z "$TYPE" ] || [ -z "$MESSAGE" ]; then
    echo "Usage: ./scripts/commit.sh <type> <message> [description]"
    echo ""
    echo "Types:"
    echo "  feat     - A new feature"
    echo "  fix      - A bug fix"
    echo "  docs     - Documentation only changes"
    echo "  style    - Code style changes (formatting, etc)"
    echo "  refactor - Code refactoring"
    echo "  test     - Adding or updating tests"
    echo "  chore    - Maintenance tasks"
    echo "  perf     - Performance improvements"
    echo ""
    echo "Example: ./scripts/commit.sh feat 'Add scanner screen' 'Implemented QR code scanning functionality'"
    exit 1
fi

# Stage all changes
git add -A

# Build commit message
COMMIT_MSG="${TYPE}: ${MESSAGE}"

if [ ! -z "$DESCRIPTION" ]; then
    COMMIT_MSG="${COMMIT_MSG}

${DESCRIPTION}"
fi

# Add co-author
COMMIT_MSG="${COMMIT_MSG}

Co-Authored-By: Claude <noreply@anthropic.com>"

# Make the commit
git commit -m "$COMMIT_MSG"

# Show the result
echo ""
echo "✅ Commit created successfully!"
git log --oneline -1