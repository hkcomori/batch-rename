# Batch Rename

[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/hkcomori/batch-rename?label=version)](https://github.com/hkcomori/batch-rename/releases/latest)
[![GitHub](https://img.shields.io/github/license/hkcomori/batch-rename)](https://github.com/hkcomori/batch-rename/blob/main/LICENSE)

**Edit multiple file names using the text editor.**

Output target file names to temporary files and open it by the text editor.
After close the file, rename target files based on it.

## Usage

```
Usage: batch-rename [OPTIONS]... [--] [FILE]...
Edit the name of FILE(s) at once using the text editor.

Options:
  -e, --editor=EDITOR   use EDITOR
  -d                    edit files in directories
  -f, --force           do not prompt before overwriting
  -n, --no-clobber      do not overwrite an existing file
  -r, --recursive       edit directory recursively
  -v, --verbose         explain what is being done
  -h, --help            display this help and exit
  -V, --version         output version information and exit
  --                    Assign any remaining arguments to FILE(s).
                        OPTION(s) should be set before this.
```

## Requirements

### Linux

- Bash 4.2 (or latter)

### Windows

- MinGW or Git for Windows
- Bash 4.2 (or latter)

## Contributions
Contributions are welcomed via PR.

## License
 * [GPLv3](https://github.com/hkcomori/batch-rename/blob/main/LICENSE)