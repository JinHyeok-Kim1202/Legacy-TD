# Data Validation

Run from the project root:

```bash
npm run validate:data
```

The validator currently checks:
- JSON parseability
- duplicate IDs
- board size and outer-ring path shape
- recipe input/output references
- wave enemy and boss references
- difficulty baseline presence
- the current rule of 2 common draws per round
