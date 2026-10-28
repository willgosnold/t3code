# willyskills-repo-tooling

intent: Keep the repo's formatter, linter and root test run out of .agents/skills, where patchbook builds willyskills' skills, and keep the formatter out of .patchbook, whose files patchbook writes in its own layout. Both are another tool's output: formatting them would record hand edits to willyskills or fight patchbook on every record, and pstack's scripts follow their own lint rules and run under Bun.

edits:
- file vite.config.ts
