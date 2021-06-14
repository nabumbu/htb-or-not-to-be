# htb-or-not-to-be

> A Bash Script that interacts with HackTheBox throught its API v4. The HackTheBox client can perform actions such as showing detailed information about a machine, list the active and retired machines of the platform, etc.


## ...STILL TESTING...

IMPORTANT: User must download information throught the following command before using the rest of the command. And it should be executed periodically, in order to be up-to-date of the latest machines.

Download machines information (REQUIRES LOGIN)
```bash
./htbontb -d
```
---
Show machine information
```bash
./htbontb -i <MACHINE-NAME>
```

List active machines
```bash
./htbontb -l active
```

List retired machines
```bash
./htbontb -l retired
```
List machine and sort (<key>--> (level|id|name|...) )
```bash
./htbontb -l <active|retired> -k <key>
```

List machines by OS (<os>--> (Windows|Linux|FreeBSD|Other) )
```bash
./htbontb -l <active|retired> -O <os>
```

Play machine (REQUIRES LOGIN)
```bash
./htbontb -p <MACHINE-NAME>
```

Stop machine (REQUIRES LOGIN)
```bash
./htbontb -s
```

Submit flag (REQUIRES LOGIN)
```bash
./htbontb -l active
```

Update polybar (POLYBAR REQUIRED!!)
```bash
./htbontb -b <MACHINE-NAME>
```

## ..TODO..
- List writeups of a specified machine
- Improve Sort and group list functions
- More efficient code