#!/bin/bash

# OptiFlag HTML Reports Demo Deployment Script
# This script prepares and deploys the HTML reports for demo purposes

set -e  # Exit on error

echo "OptiFlag Demo Deployment Script"
echo "==============================="

# Configuration
REPORTS_DIR="data_cut/samples/optimizer_experiments_per_ticker_batched/html_reports"
DEMO_DIR="optiflag-demo"
GITHUB_USERNAME=""  # Will be set by user

# Function to check if directory exists
check_reports() {
    if [ ! -d "$REPORTS_DIR" ]; then
        echo "Error: HTML reports directory not found at $REPORTS_DIR"
        exit 1
    fi
    
    # Count HTML files
    HTML_COUNT=$(find "$REPORTS_DIR" -name "*.html" | wc -l)
    echo "Found $HTML_COUNT HTML files to deploy"
}

# Function to prepare demo directory
prepare_demo() {
    echo "Preparing demo directory..."
    
    # Create demo directory if it doesn't exist
    if [ -d "$DEMO_DIR" ]; then
        echo "Demo directory exists. Backing up to ${DEMO_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
        mv "$DEMO_DIR" "${DEMO_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
    fi
    
    mkdir -p "$DEMO_DIR"
    
    # Copy all HTML reports
    echo "Copying HTML reports..."
    cp -r "$REPORTS_DIR"/* "$DEMO_DIR/"
    
    # Create a simple README
    cat > "$DEMO_DIR/README.md" << EOF
# OptiFlag Trading Strategy Optimization Demo

This is a demo of the OptiFlag trading strategy optimization system results.

## Navigation

- Start with \`index.html\` for the main overview
- Click on experiment names to view detailed results
- Each experiment contains multiple flagpole pattern charts

## About

OptiFlag uses Bayesian optimization to find optimal parameters for flagpole pattern detection and trading.

---

*This is a demo deployment. Not for production use.*
EOF

    # Create .nojekyll file to prevent GitHub Pages from processing files
    touch "$DEMO_DIR/.nojekyll"
    
    echo "Demo directory prepared successfully!"
}

# Function to create GitHub repository
create_github_repo() {
    echo ""
    echo "GitHub Deployment Instructions:"
    echo "==============================="
    echo ""
    echo "1. Create a new GitHub repository:"
    echo "   - Go to https://github.com/new"
    echo "   - Repository name: optiflag-demo"
    echo "   - Set as Public (for GitHub Pages)"
    echo "   - Don't initialize with README"
    echo ""
    echo "2. Push the demo files:"
    echo "   cd $DEMO_DIR"
    echo "   git init"
    echo "   git add ."
    echo "   git commit -m 'Initial demo deployment'"
    echo "   git branch -M main"
    echo "   git remote add origin https://github.com/YOUR_USERNAME/optiflag-demo.git"
    echo "   git push -u origin main"
    echo ""
    echo "3. Enable GitHub Pages:"
    echo "   - Go to Settings > Pages"
    echo "   - Source: Deploy from a branch"
    echo "   - Branch: main"
    echo "   - Folder: / (root)"
    echo "   - Click Save"
    echo ""
    echo "4. Access your demo at:"
    echo "   https://YOUR_USERNAME.github.io/optiflag-demo/"
    echo ""
    echo "The deployment usually takes 5-10 minutes to go live."
}

# Function for local preview
local_preview() {
    echo ""
    echo "Local Preview (Optional):"
    echo "========================"
    echo ""
    echo "To preview locally before deploying to GitHub:"
    echo "  cd $DEMO_DIR"
    echo "  python -m http.server 8000"
    echo ""
    echo "Then open: http://localhost:8000"
    echo ""
}

# Main execution
main() {
    echo "Starting deployment preparation..."
    check_reports
    prepare_demo
    create_github_repo
    local_preview
    
    echo ""
    echo "✅ Demo preparation complete!"
    echo "📁 Demo files are ready in: $DEMO_DIR/"
    echo ""
    echo "Next steps: Follow the GitHub deployment instructions above."
}

# Run main function
main