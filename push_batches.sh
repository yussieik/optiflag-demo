#!/bin/bash

# Push flagpole files in batches
cd optiflag-demo

# Function to push files matching a pattern
push_batch() {
    pattern=$1
    message=$2
    
    echo "Adding files matching: $pattern"
    git add $pattern
    
    if git diff --cached --quiet; then
        echo "No files to commit for pattern: $pattern"
        return
    fi
    
    git commit -m "$message"
    git push
    echo "Pushed: $message"
    echo "---"
}

# Push in batches by experiment
push_batch "flagpoles/TSLA_bayes_iter_5*.html" "Add flagpole charts - iter_5"
push_batch "flagpoles/TSLA_bayes_iter_7*.html" "Add flagpole charts - iter_7"
push_batch "flagpoles/TSLA_bayes_iter_9*.html" "Add flagpole charts - iter_9"
push_batch "flagpoles/TSLA_bayes_iter_10*.html" "Add flagpole charts - iter_10"
push_batch "flagpoles/TSLA_bayes_iter_15*.html" "Add flagpole charts - iter_15"
push_batch "flagpoles/TSLA_bayes_iter_17*.html" "Add flagpole charts - iter_17"
push_batch "flagpoles/TSLA_bayes_iter_18*.html" "Add flagpole charts - iter_18"
push_batch "flagpoles/TSLA_bayes_iter_19*.html" "Add flagpole charts - iter_19"
push_batch "flagpoles/TSLA_bayes_iter_26*.html" "Add flagpole charts - iter_26"
push_batch "flagpoles/TSLA_bayes_iter_28*.html" "Add flagpole charts - iter_28"

# Push any remaining iteration forward test files
push_batch "flagpoles/TSLA_iteration*.html" "Add iteration forward test charts"

echo "All batches pushed successfully!"