# skill-usage-ranking

intent: Rank composer skills by how often the user sends them, keeping the counts separate on each device (localStorage on web and desktop, the mobile preferences store on mobile). A use is a sent message containing a known $ skill token, counted once per skill per message and keyed by lowercased name, and it is recorded only after the send is accepted: on web once the turn starts, after every model in a multi-model send accepts, or after a plan follow-up goes out; on mobile once the outbox accepts the message. Ranking is by count, then most recent use: with an empty / or $ query, used skills lead the list ahead of built-in and provider commands and everything else keeps upstream order, while a typed query on web and in the $ picker on both platforms keeps match score first with usage only breaking ties, and mobile's / menu, which has no scores, puts used matches first.

edits:

- file apps/mobile/src/features/threads/ThreadComposer.tsx
- file apps/mobile/src/features/threads/use-composer-command-menu.ts
- file apps/mobile/src/persistence/mobile-preferences.ts
- add apps/mobile/src/state/skill-usage.ts
- file apps/web/src/components/chat/ChatComposer.tsx
- add apps/web/src/components/chat/composerSlashCommandSearch.test.ts
- file apps/web/src/components/chat/composerSlashCommandSearch.ts
- file apps/web/src/components/chat/useComposerMenuItems.ts
- file apps/web/src/components/chat/useComposerSend.ts
- file apps/web/src/providerSkillSearch.test.ts
- file apps/web/src/providerSkillSearch.ts
- add apps/web/src/skillUsageStore.ts
- file docs/user/composer.md
- file docs/user/providers-fx.md
- file packages/client-runtime/package.json
- add packages/client-runtime/src/skillUsage.test.ts
- add packages/client-runtime/src/skillUsage.ts
- file apps/web/src/components/chat/useMultipleModelSend.ts
