# OptiFlag Demo Update Guide

Keep your GitHub Pages demo up-to-date with the latest optimization results.

## 🚀 Quick Update (One Command)

```bash
./update_demo.sh
```

This automatically:
- ✅ Backs up current demo
- ✅ Replaces all HTML files with latest reports
- ✅ Commits changes with detailed message
- ✅ Pushes to GitHub
- ✅ Updates live demo in 5-10 minutes

## 📋 Update Workflow

### 1. Generate New HTML Reports
```bash
# Run your optimization
python run_optimizer.py

# Generate fresh HTML reports
python run_html_report.py
```

### 2. Update Demo
```bash
# Standard update (with backup)
./update_demo.sh

# Skip backup (faster)
./update_demo.sh --no-backup

# Force update even if no changes
./update_demo.sh --force
```

### 3. Verify Update
The script will show:
- Number of files updated
- Commit details
- Push confirmation
- Demo URL

## 🔄 What Gets Updated

- **All HTML files** - Completely replaced with new ones
- **Assets folder** - Updated CSS and resources
- **README.md** - Timestamp automatically updated
- **Git history** - Detailed commit message with statistics

## 📊 Update Statistics

Each update commit includes:
- Total HTML file count
- Number of experiments
- Number of flagpole charts
- Generation timestamp from reports

Example commit message:
```
Update demo with latest results - 2024-06-30

Updated statistics:
- HTML files: 553
- Experiments: 11
- Flagpole charts: 541
- Generated: Generated on 2025-06-30 12:42:19
```

## 🛠️ Script Options

### --no-backup
Skip creating backup folder (saves time and space)
```bash
./update_demo.sh --no-backup
```

### --force
Force update even if git detects no changes
```bash
./update_demo.sh --force
```

### --help
Show usage information
```bash
./update_demo.sh --help
```

## 🔍 Troubleshooting

### "No changes detected"
- Check if reports were regenerated: `ls -la data_cut/samples/optimizer_experiments_per_ticker_batched/html_reports/`
- Use `--force` flag to push anyway

### "HTML reports directory not found"
- Run `python run_html_report.py` first
- Check path in script matches your setup

### Push errors
- Script automatically increases git buffer size
- If still failing, try manual push:
  ```bash
  cd optiflag-demo
  git push --force
  ```

## 📁 Backup Management

Backups are created as:
```
optiflag-demo_backup_YYYYMMDD_HHMMSS/
```

To clean old backups:
```bash
# List backups
ls -d optiflag-demo_backup_*

# Remove specific backup
rm -rf optiflag-demo_backup_20240630_120000

# Remove all backups older than 7 days
find . -name "optiflag-demo_backup_*" -mtime +7 -exec rm -rf {} \;
```

## 🔐 Security Notes

- Demo remains public (required for GitHub Pages)
- robots.txt prevents search engine indexing
- No sensitive trading data should be in reports
- Old versions available in git history

## 📈 Best Practices

1. **Regular Updates**: Update after each significant optimization run
2. **Review Before Push**: Check index.html locally first
3. **Keep Backups**: At least one recent backup recommended
4. **Monitor Size**: GitHub Pages has 1GB limit (current: ~19MB)

## 🎯 Complete Workflow Example

```bash
# 1. Run new optimization
python run_optimizer.py --tickers TSLA,AAPL

# 2. Generate reports
python run_html_report.py

# 3. Preview locally (optional)
cd data_cut/samples/optimizer_experiments_per_ticker_batched/html_reports
python -m http.server 8000
# Open http://localhost:8000

# 4. Update demo
cd /Users/yussieik/OptiFlag
./update_demo.sh

# 5. Wait 5-10 minutes, then visit:
# https://yussieik.github.io/optiflag-demo/
```

---

Your demo at https://yussieik.github.io/optiflag-demo/ will always showcase your latest and best optimization results!