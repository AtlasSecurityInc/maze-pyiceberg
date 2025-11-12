#!/bin/bash
set -euo pipefail

# Maze PyIceberg Release Script
# Usage: ./scripts/create-release.sh <version>
# Example: ./scripts/create-release.sh 0.10.0-maze.1

if [ $# -eq 0 ]; then
    echo "Error: Version number required"
    echo "Usage: $0 <version>"
    echo "Example: $0 0.10.0-maze.1"
    exit 1
fi

VERSION=$1
TAG="v${VERSION}"

echo "Creating release for version: ${VERSION}"
echo "Tag: ${TAG}"
echo ""

# Check if we're in the right directory
if [ ! -f "pyproject.toml" ]; then
    echo "Error: Must be run from the maze-pyiceberg root directory"
    exit 1
fi

# Check if tag already exists
if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "Error: Tag ${TAG} already exists"
    exit 1
fi

# Update version in pyproject.toml
echo "Updating version in pyproject.toml..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version = .*/version = \"${VERSION}\"/" pyproject.toml
else
    # Linux
    sed -i "s/^version = .*/version = \"${VERSION}\"/" pyproject.toml
fi

# Show the change
echo "Version updated to:"
grep "^version = " pyproject.toml

# Prompt for release notes
echo ""
echo "Enter release notes (press Ctrl+D when done):"
RELEASE_NOTES=$(cat)

# Commit version change
echo ""
echo "Committing version change..."
git add pyproject.toml
git commit -m "chore: bump version to ${VERSION}"

# Create and push tag
echo "Creating and pushing tag ${TAG}..."
git tag -a "${TAG}" -m "Release ${VERSION}"
git push origin main
git push origin "${TAG}"

# Create GitHub release
echo ""
echo "Creating GitHub release..."
echo "${RELEASE_NOTES}" | gh release create "${TAG}" \
    --title "${TAG}" \
    --notes-file -

echo ""
echo "✅ Release ${VERSION} created successfully!"
echo ""
echo "Next steps:"
echo "1. GitHub Actions will automatically build and publish to GitHub Packages"
echo "2. Monitor the workflow: gh run watch"
echo "3. Update your projects to use maze-pyiceberg==${VERSION}"
