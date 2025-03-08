# Bash Commands

## Disk Space (Disk Usage)

#### df Command
Disk space usage across all mounted filesystems
```
df [options] [filesystem]
```
#### du Command
Identifying which files or directories consume the most disk space on a filesystem.
```
du [options] [file]
```

**`-h`** Display sizes in a human-readable format (e.g., KB, MB, GB).

**`-T`** Display the file system type along with other information.

**`-s`** Display only the total size for each argument (directory or file).


## >> List all Processes <<

#### ps Command
```
$ ps aux
```
a = show processes for all users
u = display the process’s user/owner
x = also show processes not attached to a terminal

## >> List all processes <<
### List by  User
```
$ ps -u username
```
-u : Show all processes by RUID
-U : Display all processes by EUID
```
$ top -U username
```
```
$ pgrep -u username
```

## >> List Processes <<
### List by Name
-Used **aux**
```
ps aux | grep package_name
```
Example;
```
$ ps aux | grep firefox
```
-Used **pgrep**
```
pgrep package_name
```
Example;
```
$ pgrep firefox
```

### List by PID
```
ps -p PID
```
Example;
```
$ ps -p 1234
```
-Used Specific PID;
```
ps aux | grep PID
```
Example;
```
$ ps aux | grep 1234
```

## Control Operations
Useful for stopping misbehaving or unresponsive programs that might otherwise require restarting the system.
```
kill [options] pid…
```
**`-l`** Lists available signals and their corresponding numeric values.

**`-9`** Sends the  **`SIGKILL`**  signal to the target process.

**`pid…`** is the Process IDs (PIDs) of the processes you want to terminate.

### >> Kill Process by Name <<

```
$ sudo pkill apache [or] $ sudo pkill -f /etc/apache/bin/apache
```
```
$ pgrep apache
6123
6230
```
```
$ kill -9 `pgrep apache`
```
```
$ pidof apache
6123 6230
```
```
$ kill -9 `pidof apache`
```
```
$ killall -9 apache
```

#### history Command
Displays a list of recently executed commands within a terminal session.
```
history [options]
```
**`-c`** Clears the command history, deleting all previously executed commands from the history list.

**`-w`** Writes the current history list to the history file  _(~/.bash_history_  by default) and saves any changes made during the session.

#### exit Command
To end a terminal session or script.
```
exit [n]
```
**`[n]`** is an optional argument that specifies the exit status that the shell or script returns after termination.

#### echo Command
Displays text or variables in the terminal as the standard output. It is useful for generating output messages, displaying variable values, or in Bash scripts.

**`echo`** allows users to perform basic string manipulation, create prompts, generate user notifications, and create formatted output. The command is essential for both interactive use and automation.
```
echo [options] [string]
```

**`-n`**  Instructs  **`echo`**  not to print the trailing newline character after displaying the specified text or variable. 
By default,  **`echo`**  adds a newline character at the end of the output.

**`-e`** Enables the interpretation of certain escape sequences within the text or variable being echoed.


#### Pipe Utility
To connect the standard output of one command to the standard input of another, thus enabling the flow of data between commands.
```
[command1] | [command 2]
```

#### Redirect Operator

The redirect operator (**`>`**,  **`<`**,  **`>>`**,  **`2>`**, etc.) is a mechanism that allows users to control the input and output of commands.  **`>`**  redirects the standard output of a command to a file, overwriting its content if the file already exists. The  **`>>`**  operator appends the standard output to the specified file.

**`<`**  operator redirects the standard input of a command from a file. The  **`2>`**  operator redirects standard error messages to a file. These operators enable users to manage data flow, perform file-based operations, and ensure precise error handling.


## >>> Archiving and Compression <<<
```
tar [options] [archive-file] [file | dir...]**
```

**[archive-file]** is the name of the archive file you want to create, extract from, or manipulate. Omitting this causes tar to default to using the standard input/output.
**[file | dir …]** are the files and/or directories you want to include in the archive
### Create tar.gz file
```
tar -cvzf filename.tar.gz /path/to/directory
```

### Extract tar.gz file
```
$ tar -xvf filename.tar.gz /path/to/dir
```

##  List installed packages

### 1. Using dpkg command
```
dpkg --list
```
You can narrow the list by typing the package name after the grep command.
```
$ dpkg --list | grep unzip
ii  unzip                                      6.0-26ubuntu3.1                              amd64        De-archiver for .zip files
```

**Listing Only Application Packages**
```
$ dpkg --get-selections | grep -v uninstall | awk '{print $1}'
```

**Listing System Packages Only**
```
$ dpkg --get-selections | grep -v uninstall | grep linux-image | awk '{print $1}'
```

### 2. Using dpkg-query command
```
dpkg-query -l
```

**List and search for specific packages**
```
dpkg-query -l | grep -i xorg
```
**Count the number of packages installed**
```
sudo dpkg-query -f '${binary:Package}\n' -W | wc -l
```
**List only memory-intensive packages**
```
$ dpkg-query -Wf '${Package}\t${Installed-Size}\n' | sort -n -k 2.2 | grep -v uninstall | awk '$2 > 102400 {print $1}'
```
This command displays a list of packages installed on the system that occupy more than 100 MB of memory

### 3. Using apt command
```
$ apt list --installed
```
**List only upgradeable packages**
```
$ apt list --upgradable
```

### 4. List of all installed packages from dpkg.log
```
$ grep " install " /var/log/dpkg.log
```
Extract the fourth field (which contains the package name) from each line that contains the word "install" in the `dpkg.log` file, and display only the list of package names.
```
$ grep " install " /var/log/dpkg.log | awk '{print $4}'
```
For archived logs: (can access the installation date of the package from the list.)
```
$ zgrep " install " /var/log/dpkg.log.2.gz
```

## Show/Check for Open Ports
The `ss` command replaced the older `netstat` command.
```
sudo ss -ltn
```

**Listening ports belong to Process**
```
$ sudo ss -ltnp
```
**Check with ufw**
```
$ sudo ufw status verbose
```

## >>> Delete User Account <<<
**[Option-1]**
```
sudo userdel -rfRZ <username>
```
**[Option-2]**
```
sudo userdel --remove-home username
```
**[Option-3]**
```
sudo killall -u username && sudo deluser --remove-home -f username
```

### Delete Folder/Directory by exception
```
$ ls myfolder/ | grep -v "test2" | xargs rm -r
```

## Searching and Sorting
### find command
```
find [location] [expression] [options]
```
**[location]** is the directory where the search will begin. If not specified, the search starts from the current directory.
**[expression]** is used to combine multiple search criteria using logical operators (-and, -or, -not). It can be used to create complex search conditions.

### grep Command
```
grep [options] [search pattern] [file]
```
**[search pattern]** is the text or regular expression you're searching for. It can be a simple string or a more complex regular expression.
**[file]** are the files in which you want to search for the pattern. You can specify one or multiple files. If no files are specified, grep reads from standard input.

### sort Command
```
sort [options] [file]
```
## Changing Permissions

### chmod Command
```
chmod [options] [mode] [file]
```
**[options]** -R is recursive mode, -v is verbose display modifies
**[mode]** is the permission mode, use symbolic notation (e.g., u+rwx) or octal notation (e.g., 755).

### chown Command
```
chown [options] owner[:group] file
```
**[options]** -R is recursive mode, -v is verbose display modifies
**owner** is the name or numeric user ID of the new owner you want to assign to the file(s) or directory.
**group** is the name or numeric group ID of the new group you want to assign to the file(s) or directory. Omitting this part keeps the group unchanged.

## Set Time-zone

```
 $ sudo apt install ntpdate sntp
```
