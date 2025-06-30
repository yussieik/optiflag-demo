#!/bin/bash

# OptiFlag Demo Update Script
# This script updates the GitHub Pages demo with the latest HTML reports

set -e  # Exit on error

echo "🔄 OptiFlag Demo Update Script"
echo "=============================="

# Configuration
REPORTS_DIR="data_cut/samples/optimizer_experiments_per_ticker_batched/html_reports"
DEMO_DIR="optiflag-demo"
REPO_NAME="optiflag-demo"
GITHUB_USER=$(gh api user --jq .login 2>/dev/null || echo "")

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."
    
    # Check if gh is authenticated
    if [ -z "$GITHUB_USER" ]; then
        print_error "GitHub CLI not authenticated. Run 'gh auth login' first."
        exit 1
    fi
    
    # Check if HTML reports exist
    if [ ! -d "$REPORTS_DIR" ]; then
        print_error "HTML reports directory not found at $REPORTS_DIR"
        print_error "Generate reports first with: python run_html_report.py"
        exit 1
    fi
    
    # Check if demo directory exists
    if [ ! -d "$DEMO_DIR" ]; then
        print_warning "Demo directory not found. Creating from scratch..."
        return 1
    fi
    
    # Check if it's a git repository
    if [ ! -d "$DEMO_DIR/.git" ]; then
        print_warning "Demo directory exists but is not a git repository"
        return 1
    fi
    
    print_status "Prerequisites checked"
    return 0
}

# Function to backup current demo
backup_current_demo() {
    if [ -d "$DEMO_DIR" ]; then
        BACKUP_NAME="${DEMO_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
        echo "Creating backup: $BACKUP_NAME"
        cp -r "$DEMO_DIR" "$BACKUP_NAME"
        print_status "Backup created"
    fi
}

# Function to count files
count_files() {
    local dir=$1
    local html_count=$(find "$dir" -name "*.html" 2>/dev/null | wc -l | tr -d ' ')
    echo "$html_count"
}

# Function to initialize demo repository
init_demo_repo() {
    echo "Initializing demo repository..."
    
    # Create demo directory
    mkdir -p "$DEMO_DIR"
    cd "$DEMO_DIR"
    
    # Initialize git
    git init
    git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git" 2>/dev/null || true
    git branch -M main
    
    # Create necessary files
    cat > README.md << EOF
# OptiFlag Trading Strategy Optimization Demo

This is a demo of the OptiFlag trading strategy optimization system results.

## Navigation

- Start with \`index.html\` for the main overview
- Click on experiment names to view detailed results
- Each experiment contains multiple flagpole pattern charts

## Last Updated

$(date +"%Y-%m-%d %H:%M:%S")

---

*This is a demo deployment. Not for production use.*
EOF

    touch .nojekyll
    
    cat > robots.txt << EOF
User-agent: *
Disallow: /

# This prevents search engines from indexing the demo content
EOF
    
    cd ..
    print_status "Demo repository initialized"
}

# Function to update demo files
update_demo_files() {
    echo ""
    echo "📊 Updating demo files..."
    
    # Count current files
    OLD_COUNT=$(count_files "$DEMO_DIR")
    
    # Remove old HTML files and assets
    echo "Removing old files..."
    rm -rf "$DEMO_DIR"/*.html "$DEMO_DIR"/experiments "$DEMO_DIR"/flagpoles "$DEMO_DIR"/assets
    
    # Copy new files
    echo "Copying new HTML reports..."
    cp -r "$REPORTS_DIR"/* "$DEMO_DIR/" 2>/dev/null || {
        print_error "Failed to copy files. Check if reports exist."
        exit 1
    }
    
    # Update README with timestamp
    sed -i.bak "s/## Last Updated.*/## Last Updated\n\n$(date +"%Y-%m-%d %H:%M:%S")/" "$DEMO_DIR/README.md"
    rm -f "$DEMO_DIR/README.md.bak"
    
    # Count new files
    NEW_COUNT=$(count_files "$DEMO_DIR")
    
    print_status "Files updated"
    echo "  Old file count: $OLD_COUNT"
    echo "  New file count: $NEW_COUNT"
    
    if [ "$NEW_COUNT" -eq 0 ]; then
        print_error "No HTML files found in the demo directory!"
        exit 1
    fi
}

# Function to commit and push changes
commit_and_push() {
    echo ""
    echo "📤 Committing and pushing changes..."
    
    cd "$DEMO_DIR"
    
    # Configure git if needed
    git config user.name "$GITHUB_USER" 2>/dev/null || true
    git config user.email "$GITHUB_USER@users.noreply.github.com" 2>/dev/null || true
    
    # Add all files
    git add -A
    
    # Check if there are changes
    if git diff --cached --quiet; then
        print_warning "No changes detected. Demo is already up to date."
        return 0
    fi
    
    # Create commit message with statistics
    COMMIT_MSG="Update demo with latest results - $(date +%Y-%m-%d)

Updated statistics:
- HTML files: $(count_files .)
- Experiments: $(ls experiments/*.html 2>/dev/null | wc -l | tr -d ' ')
- Flagpole charts: $(ls flagpoles/*.html 2>/dev/null | wc -l | tr -d ' ')
- Generated: $(grep -o 'Generated on [^<]*' index.html | head -1 || echo 'Unknown')"
    
    git commit -m "$COMMIT_MSG"
    
    # Increase buffer size for large pushes
    git config http.postBuffer 524288000
    
    # Push to GitHub
    echo "Pushing to GitHub..."
    git push -u origin main --force
    
    cd ..
    print_status "Changes pushed successfully"
}

# Function to verify deployment
verify_deployment() {
    echo ""
    echo "🔍 Verifying deployment..."
    
    # Check repository
    if gh repo view "$GITHUB_USER/$REPO_NAME" &>/dev/null; then
        print_status "Repository exists"
    else
        print_error "Repository not found"
        return 1
    fi
    
    # Check GitHub Pages status
    local pages_status=$(gh api "repos/$GITHUB_USER/$REPO_NAME/pages" --jq .status 2>/dev/null || echo "not_found")
    
    if [ "$pages_status" = "built" ]; then
        print_status "GitHub Pages is active and built"
    elif [ "$pages_status" = "building" ]; then
        print_warning "GitHub Pages is currently building (this may take a few minutes)"
    else
        print_warning "GitHub Pages status: $pages_status"
    fi
    
    echo ""
    echo "✅ Demo update complete!"
    echo ""
    echo "🌐 Your demo URL: https://$GITHUB_USER.github.io/$REPO_NAME/"
    echo ""
    echo "📊 Updated content:"
    echo "   - $(count_files "$DEMO_DIR") HTML files"
    echo "   - Last update: $(date)"
    echo ""
    echo "⏱️  Changes will be live in 5-10 minutes"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --no-backup    Skip creating backup of current demo"
    echo "  --force        Force update even if no changes detected"
    echo "  --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Update demo with backup"
    echo "  $0 --no-backup        # Update without backup"
    echo "  $0 --force            # Force update even if no changes"
}

# Parse command line arguments
NO_BACKUP=false
FORCE_UPDATE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-backup)
            NO_BACKUP=true
            shift
            ;;
        --force)
            FORCE_UPDATE=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    echo "GitHub User: $GITHUB_USER"
    echo "Repository: $REPO_NAME"
    echo ""
    
    # Check prerequisites
    if check_prerequisites; then
        # Demo exists, just update
        if [ "$NO_BACKUP" = false ]; then
            backup_current_demo
        fi
    else
        # Demo doesn't exist, create from scratch
        print_warning "Demo not found or invalid. Creating new demo..."
        rm -rf "$DEMO_DIR"
        init_demo_repo
    fi
    
    # Update files
    update_demo_files
    
    # Commit and push
    commit_and_push
    
    # Verify
    verify_deployment
}

# Run main function
main