# willyskills-repo-tooling

intent: Keep the repo's formatter, linter and root test run out of .agents/skills, where patchbook builds willyskills' skills. They are another repo's build output: formatting them would record hand edits to it, and pstack's scripts follow their own lint rules and run under Bun.

edits:

- file vite.config.ts
