# Security policy

## Reporting a vulnerability

Do not publish credentials, session tokens, personal messages, or a working
exploit in a public issue. Contact the repository owner privately through the
GitHub profile and include only the minimum information needed to reproduce the
problem.

## Secrets used by AFZ_maks2tg

`MAX_TOKEN`, `MAX_DEVICE_ID`, and `TG_BOT_TOKEN` provide access to personal
accounts or messages. Keep them only in `.env` or a secret manager, restrict the
file to the service account (`chmod 600 .env`), and never commit it.

If a secret is disclosed:

1. Revoke and recreate the Telegram token with `@BotFather`.
2. End the affected Max web session and obtain fresh Max credentials.
3. Replace the values on the host and recreate the container.
4. Review logs and repository history for accidental disclosure.

## Supported versions

Security fixes are applied to the latest commit on `main`.
