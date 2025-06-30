#!/bin/bash

# GitHub Pages Deployment using GitHub CLI
# This script deploys the OptiFlag demo directly to GitHub Pages

set -e  # Exit on error

echo "🚀 OptiFlag GitHub Pages Deployment"
echo "==================================="

# Configuration
REPORTS_DIR="data_cut/samples/optimizer_experiments_per_ticker_batched/html_reports"
DEMO_DIR="optiflag-demo"
REPO_NAME="optiflag-demo"
GITHUB_USER=$(gh api user --jq .login)

echo "📋 Deployment Configuration:"
echo "  GitHub User: $GITHUB_USER"
echo "  Repository: $REPO_NAME"
echo "  Demo URL: https://$GITHUB_USER.github.io/$REPO_NAME/"
echo ""

# Function to check if repo exists
check_repo_exists() {
    if gh repo view "$GITHUB_USER/$REPO_NAME" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to deploy
deploy() {
    # Check if this is an update or fresh deployment
    if [ -d "$DEMO_DIR/.git" ] && check_repo_exists; then
        echo "⚠️  Demo already exists. Use ./update_demo.sh to update it."
        echo ""
        echo "To update your demo with new reports:"
        echo "  ./update_demo.sh"
        echo ""
        echo "To force a fresh deployment:"
        echo "  ./deploy_to_github.sh delete"
        echo "  ./deploy_to_github.sh"
        exit 1
    fi
    
    # Prepare demo if not already done
    if [ ! -d "$DEMO_DIR" ]; then
        echo "📁 Preparing demo files..."
        ./deploy_demo.sh
    fi
    
    cd "$DEMO_DIR"
    
    # Initialize git if needed
    if [ ! -d ".git" ]; then
        echo "📝 Initializing git repository..."
        git init
        git add .
        git commit -m "Initial demo deployment"
        git branch -M main
    fi
    
    # Check if repository exists
    if check_repo_exists; then
        echo "⚠️  Repository $REPO_NAME already exists."
        read -p "Do you want to force push to existing repository? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ Deployment cancelled."
            exit 1
        fi
        echo "🔄 Pushing to existing repository..."
        git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git" 2>/dev/null || true
        git push -u origin main --force
    else
        echo "📦 Creating GitHub repository and pushing code..."
        gh repo create "$REPO_NAME" --public --source=. --push
    fi
    
    # Enable GitHub Pages
    echo "🌐 Enabling GitHub Pages..."
    
    # Check if Pages is already enabled
    if gh api "repos/$GITHUB_USER/$REPO_NAME/pages" &>/dev/null; then
        echo "✅ GitHub Pages is already enabled"
    else
        # Enable Pages with main branch
        gh api "repos/$GITHUB_USER/$REPO_NAME/pages" \
            --method POST \
            --field source='{"branch":"main","path":"/"}' \
            || echo "ℹ️  GitHub Pages might already be enabled"
    fi
    
    cd ..
    
    echo ""
    echo "✅ Deployment Complete!"
    echo "=================================="
    echo "🌐 Your demo will be available at:"
    echo "   https://$GITHUB_USER.github.io/$REPO_NAME/"
    echo ""
    echo "⏱️  Note: It may take 5-10 minutes for the site to go live."
    echo ""
    echo "📊 Demo includes:"
    echo "   - $(find "$DEMO_DIR" -name "*.html" | wc -l) HTML files"
    echo "   - Interactive charts with TradingView"
    echo "   - Full experiment results and metrics"
    echo ""
    echo "🔗 View repository: https://github.com/$GITHUB_USER/$REPO_NAME"
}

# Function to update existing deployment
update_deployment() {
    if [ ! -d "$DEMO_DIR/.git" ]; then
        echo "❌ No existing deployment found. Run deploy first."
        exit 1
    fi
    
    echo "🔄 Updating deployment with latest reports..."
    
    # Copy latest files
    rm -rf "$DEMO_DIR"/*.html "$DEMO_DIR"/experiments "$DEMO_DIR"/flagpoles "$DEMO_DIR"/assets
    cp -r "$REPORTS_DIR"/* "$DEMO_DIR/"
    
    cd "$DEMO_DIR"
    git add .
    git commit -m "Update demo with latest results $(date +%Y-%m-%d)" || {
        echo "ℹ️  No changes to deploy"
        exit 0
    }
    git push
    cd ..
    
    echo "✅ Update deployed successfully!"
}

# Function to delete deployment
delete_deployment() {
    echo "⚠️  This will delete the GitHub repository and local files."
    read -p "Are you sure you want to delete the deployment? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Deletion cancelled."
        exit 1
    fi
    
    # Delete GitHub repo
    if check_repo_exists; then
        echo "🗑️  Deleting GitHub repository..."
        gh repo delete "$GITHUB_USER/$REPO_NAME" --yes
    fi
    
    # Delete local files
    if [ -d "$DEMO_DIR" ]; then
        echo "🗑️  Deleting local demo files..."
        rm -rf "$DEMO_DIR"
    fi
    
    echo "✅ Deployment deleted successfully!"
}

# Main menu
case "${1:-deploy}" in
    deploy)
        deploy
        ;;
    update)
        update_deployment
        ;;
    delete)
        delete_deployment
        ;;
    *)
        echo "Usage: $0 {deploy|update|delete}"
        echo ""
        echo "Commands:"
        echo "  deploy - Create new deployment (default)"
        echo "  update - Update existing deployment"
        echo "  delete - Delete deployment and repository"
        exit 1
        ;;
esac