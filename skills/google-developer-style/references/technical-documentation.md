# Technical documentation

Read this reference for procedures, UI instructions, code samples, commands, placeholders, and API documentation.

## Procedures

- Use numbered steps for a sequence with two or more actions.
- Write a single-step procedure as one sentence in a bulleted list.
- Introduce a procedure only when the introduction adds context beyond the heading.
- Use one step per action. Split long steps; use substeps when the action genuinely contains a nested sequence.
- State the action first, followed by a command, placeholder definitions, explanation, output, and result as needed.
- Put `Optional:` at the start of an optional step.
- State where the action occurs before the action: _In the console, select..._.
- State a useful goal before its action: _To view logs, select..._. If this sounds optional when it is required, use _View logs: select..._.
- Document the shortest accessible method that suits the audience. If several methods matter, separate them by heading, page, or tab.
- Reference an existing procedure instead of repeating it.
- Put prerequisites and irreversible-action warnings before the relevant steps.

## READMEs

- Explain what the project does and who it is for before describing implementation details.
- Provide the prerequisites and a usable starting example for the intended audience. Explain placeholders and the expected result.
- Make required setup, optional configuration, and relevant limitations explicit.
- Organize around the reader's likely tasks. Adapt to the project; do not add empty sections or impose a universal README template.
- Preserve established terminology and supported behavior. Do not turn an editorial rewrite into new product claims.

## UI instructions

- Describe the goal rather than the widget or gesture when the exact UI detail isn't necessary.
- Refer to visible UI labels in bold and preserve their displayed capitalization unless the UI is inconsistent or all uppercase.
- Don't put quotation marks around UI labels.
- Add the UI element type only when it improves clarity: _the **Name** field_, _the **Save** button_.
- Don't turn labels into verbs or rely on UI slang such as _hamburger icon_.
- Identify a control by its accessible label, not by its color, shape, or screen position.
- For menu paths, use `>` between selections. Ensure rendered HTML provides an accessible interpretation when required.
- Format keyboard keys semantically when the output format supports it.

## Code in text and samples

- Follow the project's language-specific code style before Google documentation formatting.
- Use code font for code entities, commands, flags, filenames, paths, ports, data types, literal values, text input, and command output.
- Don't use code font for product names, ordinary domain names, IP addresses, email addresses, or browser URLs unless they function as code or input.
- Don't add quotation marks around code unless the quotation marks are part of the code.
- Introduce a code sample with a complete sentence that states what the sample demonstrates.
- Keep samples focused on the task, valid, and internally consistent. Wrap long lines near 80 characters when the language and project style allow it.
- Mark omitted code with a comment in the language's syntax, not an ellipsis.
- Explain nonobvious code after the sample instead of interrupting it with prose.

## Commands and placeholders

- Provide a runnable, click-to-copy command for the recommended case when possible.
- Use as few optional arguments as the task requires. Link to command reference material for exhaustive options.
- Don't put shell prompt characters in copyable commands.
- When splitting a command, use the correct continuation character for the shell and align continuation lines.
- Name placeholders descriptively with uppercase words separated by underscores, such as `PROJECT_ID`; don't use `x` or vague names.
- Explain every placeholder near the command, preferably in a consistent list.
- Distinguish user input from example output and introduce output with wording such as _The output is similar to the following:_.

## API and reference content

- Describe what an API element does before implementation details.
- Use consistent grammatical patterns across related entries.
- Make parameter, return value, error, state, and side-effect descriptions explicit.
- Use precise requirement language. Don't write that a value _should be true_ when you mean that the user must set it, the server sets it, or the procedure expects it.
- Keep reference content exhaustive; keep task-oriented content focused on the recommended path.
