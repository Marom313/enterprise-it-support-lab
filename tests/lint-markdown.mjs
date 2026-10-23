import fs from 'node:fs';
import path from 'node:path';
import { lint } from 'markdownlint/sync';

function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap(entry => {
    if (['.git', 'node_modules', 'outputs', 'private'].includes(entry.name)) return [];
    const file = path.join(dir, entry.name);
    return entry.isDirectory() ? walk(file) : (file.endsWith('.md') ? [file] : []);
  });
}
const files = walk('.');
const result = lint({ files, config: { default: true, MD013: false, MD024: { siblings_only: true }, MD060: false } });
const failures = Object.entries(result).flatMap(([file, errors]) => errors.map(error => `${file}:${error.lineNumber} ${error.ruleNames[0]} ${error.ruleDescription}${error.errorDetail ? ': ' + error.errorDetail : ''}`));
if (failures.length) { console.error(failures.join('\n')); process.exitCode = 1; }
else console.log(`PASS: Markdown lint on ${files.length} files.`);
