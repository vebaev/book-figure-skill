# Pure-black figure text implementation plan

1. Add a contract-fixture expectation for visible text color `#000000`.
2. Extend the validator to require the new package, token, and semantic-color versions and the black-text rule.
3. Run the validator and confirm the new checks fail against the old implementation.
4. Update the authoritative references, skill instructions, agent prompt, README, and changelog.
5. Run the validator, repository checks, and local-install validation.
6. Commit, push to GitHub, and synchronize the installed `book-figure` skill.
