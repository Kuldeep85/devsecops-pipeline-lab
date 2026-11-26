'use strict';
// DELIBERATELY VULNERABLE DEMO APP - for scanner practice only. Never deploy it.
const express = require('express');
const _ = require('lodash');

const app = express();
app.use(express.json());

// WEAKNESS 1: secret committed to source (fake value, for the secrets scanner)
const API_KEY = 'f3a9c1e7b2d84a6f9e0c5b7d1a3e8f42';

// Stub "database" so the demo has no native dependencies
const db = { query: (sql) => ({ sql, rows: [] }) };

app.get('/health', (req, res) => res.json({ status: 'ok' }));

// WEAKNESS 2: reflected XSS (user input written straight into HTML)
app.get('/hello', (req, res) => {
  res.send('<h1>Hello ' + req.query.name + '</h1>');
});

// WEAKNESS 3: SQL injection (query built by string concatenation)
app.get('/user', (req, res) => {
  const result = db.query("SELECT * FROM users WHERE name = '" + req.query.name + "'");
  res.json(result);
});

// WEAKNESS 4: old lodash (4.17.15) - known prototype-pollution advisories
app.post('/settings', (req, res) => {
  const defaults = { theme: 'light' };
  res.json(_.merge(defaults, req.body));
});

app.listen(3000, () => console.log('listening on 3000'));
