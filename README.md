# homebrew-tools

A Homebrew tap providing macOS utilities by gedalyahreback.

## Usage

Add the tap once, then install any formula from it.

```bash
brew tap gedalyahreback/tools
```

## Formulae

`screenshot-renamer` watches `~/Screenshots` for new screenshots and renames them automatically using GPT-4o vision. It runs as a LaunchAgent in the background and integrates with a native macOS rename dialog.

Install it with the following command.

```bash
brew install screenshot-renamer
```

After installation, follow the caveats printed by Homebrew to store your OpenAI API key and load the background watcher.
