import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import { parseDocument } from 'yaml';

const root = process.cwd();
const excluded = new Set(['.git', 'node_modules', 'outputs', 'private']);
function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap(e => {
    if (excluded.has(e.name)) return [];
    const file = path.join(dir, e.name);
    return e.isDirectory() ? walk(file) : [file];
  });
}
const files = walk(root);
const failures = [];
const check = (condition, message) => { if (!condition) failures.push(message); };
const secretRules = [
  /(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,})/,
  /AKIA[0-9A-Z]{16}/,
  /-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/,
  /(?:password|api[_-]?key|access[_-]?token|client[_-]?secret)\s*[=:]\s*["'][^"'\s]{8,}["']/i
];
function hasSecret(text) { return secretRules.some(rule => rule.test(text)); }
// Prove the checks reject representative fake tokens without committing a token.
assert.equal(hasSecret('gh' + 'p_' + 'A'.repeat(36)), true);
assert.equal(hasSecret('api_key=' + '"' + 'example-value' + '"'), true);
assert.equal(hasSecret('password handling is interactive'), false);

for (const file of files) {
  const relative = path.relative(root, file);
  const content = fs.readFileSync(file, 'utf8');
  check(!hasSecret(content), `${relative}: potential secret; inspect privately`);
  check(!/\.(?:iso|wim|esd|vhdx?|pfx|pem|key|evtx)$/i.test(file), `${relative}: forbidden artifact`);
  if (file.endsWith('.json')) {
    try { JSON.parse(content); } catch (error) { failures.push(`${relative}: ${error.message}`); }
  }
  if (/\.ya?ml$/.test(file)) {
    const doc = parseDocument(content, { uniqueKeys: true });
    for (const error of doc.errors) failures.push(`${relative}: ${error.message}`);
  }
  if (file.endsWith('.md')) {
    for (const match of content.matchAll(/(?<!!)\[[^\]]*\]\(([^)]+)\)/g)) {
      const target = match[1].split(' ')[0].replace(/^<|>$/g, '');
      if (/^(?:https?:|mailto:|#)/.test(target)) continue;
      const local = decodeURIComponent(target.split('#')[0]);
      check(fs.existsSync(path.resolve(path.dirname(file), local)), `${relative}: broken link ${target}`);
    }
  }
}
const config = JSON.parse(fs.readFileSync('sample-data/lab-config.json'));
check(config.domain === 'corp.example.test', 'Example domain must remain fictional');
const example = JSON.parse(fs.readFileSync('sample-data/deployment-example.json'));
check(example.EvidenceType.includes('Fictional'), 'Synthetic reports need an explicit label');
check(example.Checks.every(c => ['Pass', 'Fail', 'Review', 'Unknown'].includes(c.Status)), 'Invalid check status');
const inventory = fs.readFileSync('assets/inventory.csv', 'utf8').trim().split(/\r?\n/);
const columns = inventory[0].split(',');
const requiredColumns = ['AssetID', 'SerialNumber', 'ComputerName', 'AssignedUser', 'OperatingSystem', 'DeviceStatus', 'WarrantyStatus', 'LastCheckIn', 'LifecycleStage'];
check(requiredColumns.every(column => columns.includes(column)), 'Inventory is missing a required field');
const ids = new Set();
for (const row of inventory.slice(1)) {
  const values = row.split(',');
  check(values.length === columns.length, 'Inventory CSV field mismatch');
  check(!ids.has(values[0]), 'Duplicate asset ID'); ids.add(values[0]);
  check(values[1].startsWith('FICTIONAL-'), 'Serial numbers must be fictional');
}
const ticketCount = files.filter(f => /sample-tickets[/\\]LAB-\d+\.md$/.test(f)).length;
check(ticketCount >= 10, 'At least ten fictional tickets required');
if (failures.length) { console.error(failures.join('\n')); process.exitCode = 1; }
else console.log(`PASS: ${files.length} files; relative file links, JSON/YAML, secret checks, sample schemas, ${ticketCount} tickets and asset integrity. XML/PowerShell are checked by Test-PowerShell.ps1.`);
