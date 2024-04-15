const fs = require('fs');
const path = require('path');

module.exports = {
  verifyConditions: async (pluginConfig, context) => {
    // Assume commits are stored in a newline-separated file
    const commitPath = path.resolve(process.cwd(), 'filtered-commits.txt');
    const commitData = fs.readFileSync(commitPath, 'utf8');
    const allowedCommits = new Set(commitData.trim().split('\n'));

    context.commits = context.commits.filter(commit => allowedCommits.has(commit.hash));
  }
};
